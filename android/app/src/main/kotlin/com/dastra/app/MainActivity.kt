package com.dastra.app

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import android.webkit.MimeTypeMap

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.dastra.app/file_utils"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openFile" -> {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        openFile(path, result)
                    } else {
                        result.error("INVALID_PATH", "Path is null", null)
                    }
                }
                "openFolder" -> {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        openFolder(path, result)
                    } else {
                        result.error("INVALID_PATH", "Path is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun openFile(path: String, result: MethodChannel.Result) {
        try {
            val file = File(path)
            if (!file.exists()) {
                result.error("FILE_NOT_FOUND", "File does not exist", null)
                return
            }
            
            val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", file)
            
            val extension = file.extension
            val mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension) ?: "*/*"
            
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, mimeType)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            
            startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("OPEN_FILE_ERROR", e.message, null)
        }
    }

    private fun openFolder(path: String, result: MethodChannel.Result) {
        try {
            val file = File(path)
            if (!file.exists()) {
                result.error("FOLDER_NOT_FOUND", "Folder does not exist", null)
                return
            }
            
            val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", file)
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, "vnd.android.document/directory")
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            
            startActivity(Intent.createChooser(intent, "Open Folder"))
            result.success(true)
        } catch (e: Exception) {
            // Fallback for some devices
            try {
                val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", File(path))
                val intent = Intent(Intent.ACTION_VIEW).apply {
                    setDataAndType(uri, "*/*")
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(intent)
                result.success(true)
            } catch (e2: Exception) {
                result.error("OPEN_FOLDER_ERROR", e2.message, null)
            }
        }
    }
}
