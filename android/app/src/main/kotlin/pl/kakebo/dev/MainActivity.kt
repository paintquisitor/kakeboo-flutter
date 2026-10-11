package pl.kakebo.dev

import com.tom_roush.pdfbox.android.PDFBoxResourceLoader
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.text.PDFTextStripper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.net.Uri
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import java.io.File
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val documentWorker = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        PDFBoxResourceLoader.init(applicationContext)
        val legacy = LegacyAndroidSnapshot(applicationContext)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pl.kakebo/legacy_upgrade")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasLegacyDatabase" -> result.success(legacy.exists())
                    "createLegacySnapshot" -> documentWorker.execute {
                        try {
                            val snapshot = legacy.create()
                            runOnUiThread { result.success(snapshot) }
                        } catch (_: Exception) {
                            // Never expose database contents or paths to a platform log.
                            runOnUiThread { result.error("legacy_migration_failed", "Cannot migrate local data", null) }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pl.kakebo/local_documents")
            .setMethodCallHandler { call, result ->
                if (call.method !in setOf("readPdf", "readReceipt")) {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val path = call.argument<String>("path")
                if (path == null || !File(path).isAbsolute) {
                    result.error("invalid_path", "Expected an absolute local path", null)
                    return@setMethodCallHandler
                }
                if (call.method == "readReceipt") {
                    documentWorker.execute {
                        val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
                        try {
                            val file = File(path)
                            require(file.isFile && file.length() in 1..25L * 1024 * 1024)
                            val image = InputImage.fromFilePath(applicationContext, Uri.fromFile(file))
                            recognizer.process(image)
                                .addOnSuccessListener { text ->
                                    val lines = text.textBlocks.flatMap { it.lines }.mapNotNull { line ->
                                        line.boundingBox?.let { box ->
                                            mapOf("text" to line.text, "left" to box.left,
                                                "top" to box.top, "height" to box.height())
                                        }
                                    }
                                    result.success(lines)
                                }
                                .addOnFailureListener {
                                    result.error("ocr_failed", "Cannot read this image", null)
                                }
                                .addOnCompleteListener { recognizer.close() }
                        } catch (_: Exception) {
                            recognizer.close()
                            runOnUiThread { result.error("ocr_failed", "Cannot read this image", null) }
                        }
                    }
                    return@setMethodCallHandler
                }
                documentWorker.execute {
                    try {
                        val file = File(path)
                        require(file.isFile && file.length() in 1..50L * 1024 * 1024)
                        val pages = PDDocument.load(file).use { document ->
                            require(!document.isEncrypted && document.numberOfPages in 1..500)
                            val stripper = PDFTextStripper().apply { sortByPosition = true }
                            (1..document.numberOfPages).map { page ->
                                stripper.startPage = page
                                stripper.endPage = page
                                stripper.getText(document)
                            }
                        }
                        runOnUiThread { result.success(pages) }
                    } catch (_: Exception) {
                        // Do not expose document contents or personal paths in logs/errors.
                        runOnUiThread { result.error("pdf_read_failed", "Cannot read this PDF", null) }
                    }
                }
            }
    }

    override fun onDestroy() {
        documentWorker.shutdown()
        super.onDestroy()
    }
}
