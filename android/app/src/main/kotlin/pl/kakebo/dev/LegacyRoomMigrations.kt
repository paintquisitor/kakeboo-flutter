package pl.kakebo.dev

import android.database.sqlite.SQLiteDatabase

/** SQL from app/.../KakeboDatabase.kt. Run only on a closed source copy. */
internal object LegacyRoomMigrations {
    fun migrate(copy: SQLiteDatabase) {
        require(copy.version in 1..11) { "Unsupported legacy schema" }
        if (copy.version == 11) return
        copy.setForeignKeyConstraintsEnabled(false)
        try {
            copy.beginTransaction()
            try {
                var version = copy.version
                while (version < 11) {
                    when (version) {
                        1 -> migration1to2(copy)
                        2 -> migration2to3(copy)
                        3 -> migration3to4(copy)
                        4 -> migration4to5(copy)
                        5 -> migration5to6(copy)
                        6 -> migration6to7(copy)
                        7 -> migration7to8(copy)
                        8 -> migration8to9(copy)
                        9 -> migration9to10(copy)
                        10 -> migration10to11(copy)
                        else -> error("Unsupported legacy schema")
                    }
                    version++
                    copy.version = version
                }
                copy.setTransactionSuccessful()
            } finally {
                copy.endTransaction()
            }
        } finally {
            copy.setForeignKeyConstraintsEnabled(true)
        }
    }

    private fun migration1to2(db: SQLiteDatabase) {
                db.execSQL("""
                    CREATE TABLE IF NOT EXISTS monthly_plans (
                        month TEXT NOT NULL PRIMARY KEY,
                        savingsGrosz INTEGER NOT NULL,
                        resolutions TEXT NOT NULL
                    )
                """.trimIndent())
                db.execSQL("""
                    CREATE TABLE IF NOT EXISTS planned_items (
                        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                        month TEXT NOT NULL,
                        type TEXT NOT NULL,
                        title TEXT NOT NULL,
                        amountGrosz INTEGER NOT NULL,
                        dateEpochDay INTEGER NOT NULL,
                        FOREIGN KEY(month) REFERENCES monthly_plans(month) ON UPDATE NO ACTION ON DELETE CASCADE
                    )
                """.trimIndent())
                db.execSQL("CREATE INDEX IF NOT EXISTS index_planned_items_month ON planned_items(month)")
    }

    private fun migration2to3(db: SQLiteDatabase) {
                db.execSQL("ALTER TABLE entries ADD COLUMN subcategory TEXT")
                db.execSQL("CREATE INDEX index_entries_type_dateEpochDay ON entries(type, dateEpochDay)")
    }

    private fun migration3to4(db: SQLiteDatabase) {
                // SQLite wymaga przebudowania tabeli, aby dodać klucz obcy.
                db.execSQL("""
                    CREATE TABLE entries_new (
                        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                        amountGrosz INTEGER NOT NULL, type TEXT NOT NULL,
                        dateEpochDay INTEGER NOT NULL, note TEXT NOT NULL,
                        subcategory TEXT, plannedItemId INTEGER,
                        FOREIGN KEY(plannedItemId) REFERENCES planned_items(id) ON UPDATE NO ACTION ON DELETE SET NULL
                    )
                """.trimIndent())
                db.execSQL("INSERT INTO entries_new (id, amountGrosz, type, dateEpochDay, note, subcategory) SELECT id, amountGrosz, type, dateEpochDay, note, subcategory FROM entries")
                db.execSQL("DROP TABLE entries")
                db.execSQL("ALTER TABLE entries_new RENAME TO entries")
                db.execSQL("CREATE INDEX index_entries_type_dateEpochDay ON entries(type, dateEpochDay)")
                db.execSQL("CREATE INDEX index_entries_plannedItemId ON entries(plannedItemId)")
    }

    private fun migration4to5(db: SQLiteDatabase) {
                db.execSQL("""
                    CREATE TABLE IF NOT EXISTS monthly_reflections (
                        month TEXT NOT NULL PRIMARY KEY,
                        successes TEXT NOT NULL,
                        improvements TEXT NOT NULL,
                        nextMonth TEXT NOT NULL
                    )
                """.trimIndent())
    }

    private fun migration5to6(db: SQLiteDatabase) {
                db.execSQL("ALTER TABLE entries ADD COLUMN receiptName TEXT")
    }

    private fun migration6to7(db: SQLiteDatabase) {
                db.execSQL("CREATE TABLE custom_categories (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT NOT NULL, nameKey TEXT NOT NULL)")
                db.execSQL("CREATE UNIQUE INDEX index_custom_categories_nameKey ON custom_categories(nameKey)")
                db.execSQL("""CREATE TABLE custom_subcategories (
                    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, categoryId INTEGER NOT NULL,
                    name TEXT NOT NULL, nameKey TEXT NOT NULL,
                    FOREIGN KEY(categoryId) REFERENCES custom_categories(id) ON UPDATE NO ACTION ON DELETE RESTRICT)
                """.trimIndent())
                db.execSQL("CREATE UNIQUE INDEX index_custom_subcategories_categoryId_nameKey ON custom_subcategories(categoryId, nameKey)")
                db.execSQL("ALTER TABLE entries ADD COLUMN customSubcategoryId INTEGER REFERENCES custom_subcategories(id) ON UPDATE NO ACTION ON DELETE RESTRICT")
                db.execSQL("CREATE INDEX index_entries_customSubcategoryId ON entries(customSubcategoryId)")
    }

    private fun migration7to8(db: SQLiteDatabase) {
                db.execSQL("ALTER TABLE custom_categories ADD COLUMN icon TEXT NOT NULL DEFAULT 'WALLET'")
    }

    private fun migration8to9(db: SQLiteDatabase) {
                // Consolidate clear equivalents. Unmatched historical entries become uncategorized;
                // amounts, receipts, plan links and custom categories stay intact.
                db.execSQL("""
                    UPDATE entries SET subcategory = CASE subcategory
                        WHEN 'SUPERMARKET' THEN 'FOOD'
                        WHEN 'FOOD_SHOPS' THEN 'FOOD'
                        WHEN 'PHARMACY' THEN 'HEALTH_MEDICINE'
                        WHEN 'HEALTH' THEN 'HEALTH_MEDICINE'
                        WHEN 'CHILDCARE' THEN 'CHILDREN'
                        WHEN 'TAXIS' THEN 'TRANSPORT'
                        WHEN 'NEWSPAPERS' THEN 'BOOKS'
                        WHEN 'MUSIC' THEN 'MEDIA'
                        WHEN 'SHOWS' THEN 'PERFORMANCES'
                        WHEN 'HOBBY_OTHER' THEN 'HOBBY_ACTIVITIES'
                        WHEN 'RESTAURANTS' THEN 'DINING'
                        WHEN 'TAKEAWAY' THEN 'DINING'
                        WHEN 'PUBS' THEN 'DINING'
                        WHEN 'CAFES' THEN 'DINING'
                        WHEN 'PHONE_TOPUP' THEN NULL
                        WHEN 'NEEDS_OTHER' THEN NULL
                        WHEN 'GIFTS' THEN NULL
                        WHEN 'OPTIONAL_OTHER' THEN NULL
                        WHEN 'FILMS' THEN NULL
                        WHEN 'PARTIES' THEN NULL
                        WHEN 'OUTINGS_OTHER' THEN NULL
                        WHEN 'ELECTRONICS' THEN NULL
                        WHEN 'HOME_EQUIPMENT' THEN NULL
                        ELSE subcategory END
                    WHERE subcategory IS NOT NULL
                """.trimIndent())
    }

    private fun migration9to10(db: SQLiteDatabase) {
                db.execSQL("ALTER TABLE planned_items ADD COLUMN recurrence TEXT NOT NULL DEFAULT 'MONTHLY'")
                db.execSQL("ALTER TABLE planned_items ADD COLUMN recurrenceAnchorMonth TEXT NOT NULL DEFAULT ''")
                db.execSQL("UPDATE planned_items SET recurrenceAnchorMonth = month")
    }

    private fun migration10to11(db: SQLiteDatabase) {
                db.execSQL("ALTER TABLE planned_items ADD COLUMN icon TEXT NOT NULL DEFAULT ''")
    }
}
