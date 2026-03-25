package com.paykaribazar.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "shorebird"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // [LOCKED DNA]: Shorebird Native Bridge with MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPatchNumber" -> handlePatchNumber(result)
                "isAvailable" -> handleShorebirdAvailability(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun handlePatchNumber(result: MethodChannel.Result) {
        try {
            // Standard Java Reflection used to avoid kotlin-reflect dependency issues
            val shorebirdClass = Class.forName("dev.shorebird.cauldron.Shorebird")
            val currentPatchField = shorebirdClass.getDeclaredField("currentPatchNumber")
            currentPatchField.isAccessible = true
            val patchNumber = currentPatchField.get(null) as? Int
            
            result.success(patchNumber ?: 0)
        } catch (e: Exception) {
            Log.e("SHOREBIRD_DNA", "Reflection Error: ${e.message}")
            result.success(0)
        }
    }

    private fun handleShorebirdAvailability(result: MethodChannel.Result) {
        try {
            Class.forName("dev.shorebird.cauldron.Shorebird")
            result.success(true)
        } catch (e: Exception) {
            result.success(false)
        }
    }
}