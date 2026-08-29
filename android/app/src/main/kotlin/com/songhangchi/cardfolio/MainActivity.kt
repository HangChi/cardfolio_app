package com.songhangchi.cardfolio

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.StatFs
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
import java.io.File

class MainActivity : FlutterActivity() {
    private val textRecognizerDelegate = lazy {
        TextRecognition.getClient(ChineseTextRecognizerOptions.Builder().build())
    }
    private val textRecognizer by textRecognizerDelegate

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
            val source = File(path)
            if (!source.isFile || !source.canRead()) {
                result.error("invalid_path", "图片文件不存在或无法读取", null)
                return@setMethodCallHandler
            }
            val image = try {
                InputImage.fromFilePath(this, Uri.fromFile(source))
            } catch (error: Exception) {
                result.error("invalid_image", error.message ?: "无法读取图片", null)
                return@setMethodCallHandler
            }
            textRecognizer.process(image)
                .addOnSuccessListener { text ->
                    result.success(text.text)
                }
                .addOnFailureListener { error ->
                    result.error(
                        "recognition_failed",
                        error.message ?: "文字识别服务暂时不可用",
                        null,
                    )
                }
        }
    }

    override fun onDestroy() {
        if (textRecognizerDelegate.isInitialized()) {
            textRecognizer.close()
        }
        super.onDestroy()
    }

    private fun inspectDevice(): Map<String, Any> {
        val stats = StatFs(filesDir.absolutePath)
        return mapOf(
            "cameraPermission" to permission(Manifest.permission.CAMERA),
            // image_picker uses a system picker and receives per-selection URI
            // access, so Cardfolio does not request broad media-library access.
            "photoPermission" to "notRequired",
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
