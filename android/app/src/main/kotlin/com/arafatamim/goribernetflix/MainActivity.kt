package com.example.fluttermovies

import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val CHANNEL = "com.example.fluttermovies"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
        call,
        result ->
      if (call.method == "openPlayer") {
        @Suppress("UNCHECKED_CAST") val args = call.arguments as Map<String, Any>

        val title = args.get("title") as String?
        val size = args.get("size") as Int?
        val streamUri = args.get("streamUri")?.let { Uri.parse(it as String) }
        val mimeType = args.get("mimeType") as String?
        val subtitleUri = args.get("subtitleUri") as String?

        if (streamUri == null && mimeType == null) {
          result.error("streamUri or mimeType not valid", null, null)
        }

        val intent = Intent(Intent.ACTION_VIEW, streamUri)

        if (title != null) {
          intent.putExtra("title", title)
        }

        if (size != null) {
          intent.putExtra("size", size)
        }

        if (subtitleUri != null) {
          intent.putExtra("args", arrayOf(Uri.parse(subtitleUri)))
        }

        startActivity(intent)
      } else {
        result.notImplemented()
      }
    }
  }
}