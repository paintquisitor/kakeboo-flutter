package pl.kakebo.dev

import android.app.LocaleManager
import android.content.Context
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.os.Build
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.util.Currency
import java.util.Locale
import java.util.UUID
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

/** Reads the old app-private directory only after an in-place APK upgrade. */
internal class LegacyAndroidSnapshot(private val context: Context) {
    private val tables = listOf(
        "monthly_plans", "custom_categories", "planned_items",
        "custom_subcategories", "entries", "monthly_reflections",
    )
    private val source get() = context.getDatabasePath("kakebo.db")

    fun exists(): Boolean = source.isFile

    fun create(): Map<String, Any> {
        require(source.isFile) { "Missing legacy database" }
        val copy = File(context.cacheDir, "legacy-${UUID.randomUUID()}.db")
        val archive = File(context.cacheDir, "legacy-${UUID.randomUUID()}.zip")
        try {
            // An APK update ends the old process. Checkpoint committed WAL pages
            // before closing the connection and copying the main database file.
            SQLiteDatabase.openDatabase(source.path, null, SQLiteDatabase.OPEN_READWRITE).use { db ->
                db.rawQuery("PRAGMA wal_checkpoint(TRUNCATE)", null).use { row ->
                    require(row.moveToFirst() && row.getInt(0) == 0) { "Legacy WAL is busy" }
                }
            }
            require(File("${source.path}-wal").let { !it.exists() || it.length() == 0L }) {
                "Legacy WAL was not checkpointed"
            }
            source.copyTo(copy)
            val originalVersion: Int
            SQLiteDatabase.openDatabase(copy.path, null, SQLiteDatabase.OPEN_READWRITE).use { db ->
                originalVersion = db.version
                LegacyRoomMigrations.migrate(db)
                require(db.version == 11)
                db.rawQuery("PRAGMA integrity_check", null).use { row ->
                    require(row.moveToFirst() && row.getString(0) == "ok") { "Invalid legacy database" }
                }
                db.rawQuery("PRAGMA foreign_key_check", null).use { row ->
                    require(!row.moveToFirst()) { "Broken legacy relations" }
                }
                val rows = JSONObject()
                tables.forEach { table ->
                    rows.put(table, readTable(db.rawQuery("SELECT * FROM $table", null)))
                }
                val manifest = JSONObject()
                    .put("format", 2)
                    .put("createdAt", System.currentTimeMillis())
                    .put("tables", rows)
                    .put("profileSettings", readSettings())
                require(manifest.toString().toByteArray(Charsets.UTF_8).size <= 20 * 1024 * 1024)
                ZipOutputStream(archive.outputStream().buffered()).use { zip ->
                    zip.putNextEntry(ZipEntry("kakebo.json"))
                    zip.write(manifest.toString().toByteArray(Charsets.UTF_8))
                    zip.closeEntry()
                    val receiptNames = mutableSetOf<String>()
                    val entries = rows.getJSONArray("entries")
                    repeat(entries.length()) { index ->
                        val name = entries.getJSONObject(index).optString("receiptName", "")
                        if (name.isNotEmpty() && name != "null") receiptNames.add(name)
                    }
                    // The Kotlin backup includes saved images even when a ledger
                    // entry no longer references them. Preserve those files too.
                    val receiptDir = File(context.filesDir, "receipts")
                    receiptDir.listFiles()?.filter { it.isFile }?.forEach { receiptNames.add(it.name) }
                    var receiptTotal = 0L
                    for (name in receiptNames) {
                        require(name.matches(Regex("[a-f0-9-]{36}\\.img"))) { "Invalid receipt name" }
                        val file = File(context.filesDir, "receipts/$name")
                        require(file.isFile && file.length() in 1..25L * 1024 * 1024) {
                            "Missing receipt image"
                        }
                        receiptTotal += file.length()
                        require(receiptTotal <= 250L * 1024 * 1024)
                        zip.putNextEntry(ZipEntry("receipts/$name"))
                        file.inputStream().use { it.copyTo(zip) }
                        zip.closeEntry()
                    }
                }
            }
            require(archive.length() <= 260L * 1024 * 1024)
            return mapOf("path" to archive.absolutePath, "schemaVersion" to originalVersion)
        } catch (error: Exception) {
            archive.delete()
            throw error
        } finally {
            copy.delete()
            File("${copy.path}-wal").delete()
            File("${copy.path}-shm").delete()
        }
    }

    private fun readTable(cursor: Cursor): JSONArray = cursor.use { rowsCursor ->
        JSONArray().also { rows ->
            while (rowsCursor.moveToNext()) {
                val row = JSONObject()
                for (column in 0 until rowsCursor.columnCount) {
                    val value: Any = when (rowsCursor.getType(column)) {
                        Cursor.FIELD_TYPE_NULL -> JSONObject.NULL
                        Cursor.FIELD_TYPE_INTEGER -> rowsCursor.getLong(column)
                        Cursor.FIELD_TYPE_FLOAT -> rowsCursor.getDouble(column)
                        else -> rowsCursor.getString(column)
                    }
                    row.put(rowsCursor.getColumnName(column), value)
                }
                rows.put(row)
            }
        }
    }

    private fun readSettings(): JSONObject {
        val profile = context.getSharedPreferences("profile_preferences", 0)
        val currencyRaw = context.getSharedPreferences("currency_preferences", 0)
            .getString("currency_code", "PLN") ?: "PLN"
        val currency = runCatching { Currency.getInstance(currencyRaw).currencyCode }.getOrDefault("PLN")
        val theme = context.getSharedPreferences("appearance_preferences", 0)
            .getString("theme_mode", "SYSTEM").let { if (it in listOf("LIGHT", "DARK", "SYSTEM")) it else "SYSTEM" }
        val splash = context.getSharedPreferences("splash_preferences", 0)
            .getString("splash_style", "INK").let { if (it in listOf("INK", "SUN")) it else "INK" }
        val savedLanguage = if (Build.VERSION.SDK_INT >= 33) {
            context.getSystemService(LocaleManager::class.java).applicationLocales.get(0)?.language
        } else {
            context.getSharedPreferences("language_preferences", 0).getString("language_tag", null)
        }
        val language = (savedLanguage ?: Locale.getDefault().language).let { if (it == "en") "en" else "pl" }
        return JSONObject()
            .put("bookName", profile.getString("book_name", "").orEmpty().trim().take(40))
            .put("startTab", profile.getInt("start_tab", 0).coerceIn(0, 3))
            .put("reminderEnabled", profile.getBoolean("reminder_enabled", false))
            .put("reminderHour", profile.getInt("reminder_hour", 20).coerceIn(0, 23))
            .put("reminderMinute", profile.getInt("reminder_minute", 0).coerceIn(0, 59))
            .put("appLock", profile.getBoolean("app_lock", false))
            .put("currency", currency)
            .put("theme", theme)
            .put("splash", splash)
            .put("language", language)
    }
}
