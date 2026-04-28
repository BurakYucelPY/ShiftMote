package com.example.shiftmote

import android.content.Context
import android.hardware.ConsumerIrManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "shiftmote/ir"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                val irManager =
                    getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager

                when (call.method) {
                    "hasIrEmitter" -> {
                        result.success(irManager?.hasIrEmitter() == true)
                    }
                    "transmit" -> {
                        if (irManager == null || !irManager.hasIrEmitter()) {
                            result.error("NO_IR", "Cihazda IR emitter bulunamadi", null)
                            return@setMethodCallHandler
                        }
                        val frequency = call.argument<Int>("frequency") ?: 38000
                        val pattern = call.argument<List<Int>>("pattern") ?: emptyList()
                        try {
                            irManager.transmit(frequency, pattern.toIntArray())
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("TX_FAIL", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
