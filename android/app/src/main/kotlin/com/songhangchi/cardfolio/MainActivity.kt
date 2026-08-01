package com.songhangchi.cardfolio

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.StatFs
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "cardfolio/device_settings",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "inspect" -> result.success(inspectDevice())
                "openAppSettings" -> {
                    startActivity(
                        Intent(
                            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                            Uri.parse("package:$packageName"),
                        ),
                    )
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "cardfolio/text_recognition",
        ).setMethodCallHandler { call, result ->
            if (call.method != "recognize") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val path = call.argument<String>("imagePath")
            if (path.isNullOrBlank()) {
                result.error("invalid_path", "图片路径为空", null)
                return@setMethodCallHandler
            }
            val image = try {
                InputImage.fromFilePath(this, Uri.fromFile(java.io.File(path)))
            } catch (error: Exception) {
                result.error("invalid_image", error.message, null)
                return@setMethodCallHandler
            }
            val recognizer = TextRecognition.getClient(
                ChineseTextRecognizerOptions.Builder().build(),
            )
            recognizer.process(image)
                .addOnSuccessListener { text ->
                    result.success(text.text)
                    recognizer.close()
                }
                .addOnFailureListener { error ->
                    result.error("recognition_failed", error.message, null)
                    recognizer.close()
                }
        }
    }

    private fun inspectDevice(): Map<String, Any> {
        val photoPermission = if (Build.VERSION.SDK_INT >= 33) {
            permission(Manifest.permission.READ_MEDIA_IMAGES)
        } else {
            permission(Manifest.permission.READ_EXTERNAL_STORAGE)
        }
        val stats = StatFs(filesDir.absolutePath)
        return mapOf(
            "cameraPermission" to permission(Manifest.permission.CAMERA),
            "photoPermission" to photoPermission,
            "freeBytes" to stats.availableBytes,
            "totalBytes" to stats.totalBytes,
        )
    }

    private fun permission(name: String): String =
        if (checkSelfPermission(name) == PackageManager.PERMISSION_GRANTED) {
            "granted"
        } else {
            "denied"
        }
}
