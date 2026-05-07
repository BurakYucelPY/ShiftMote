package com.example.shiftmote

import android.content.Context
import android.hardware.ConsumerIrManager
import android.os.Build
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "shiftmote/ir"
    private val TAG = "ShiftMoteIR"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                val irManager =
                    getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager

                when (call.method) {
                    "hasIrEmitter" -> {
                        val has = irManager?.hasIrEmitter() == true
                        Log.i(TAG, "hasIrEmitter=$has, manufacturer=${Build.MANUFACTURER} model=${Build.MODEL} api=${Build.VERSION.SDK_INT}")
                        result.success(has)
                    }
                    "carrierFrequencies" -> {
                        try {
                            val ranges = irManager?.carrierFrequencies
                            val list = ranges?.map {
                                mapOf("min" to it.minFrequency, "max" to it.maxFrequency)
                            } ?: emptyList<Map<String, Int>>()
                            Log.i(TAG, "carrierFrequencies=$list")
                            result.success(list)
                        } catch (e: Exception) {
                            Log.e(TAG, "carrierFrequencies hata: ${e.message}")
                            result.error("CF_FAIL", e.message, null)
                        }
                    }
                    "transmit" -> {
                        if (irManager == null) {
                            Log.e(TAG, "transmit: ConsumerIrManager null")
                            result.error("NO_IR", "ConsumerIrManager servisi null", null)
                            return@setMethodCallHandler
                        }
                        if (!irManager.hasIrEmitter()) {
                            Log.e(TAG, "transmit: hasIrEmitter=false")
                            result.error("NO_IR", "Cihazda IR emitter yok", null)
                            return@setMethodCallHandler
                        }
                        val frequency = call.argument<Int>("frequency") ?: 38000
                        val pattern = call.argument<List<Int>>("pattern") ?: emptyList()
                        if (pattern.isEmpty()) {
                            Log.e(TAG, "transmit: pattern bos")
                            result.error("BAD_PATTERN", "Pattern bos", null)
                            return@setMethodCallHandler
                        }
                        // Android tipik olarak ~600 entry'yi destekler. Asarsa kes.
                        val patternArr = if (pattern.size > 600) {
                            Log.w(TAG, "pattern uzunlugu ${pattern.size} → 600'e kesildi")
                            pattern.take(600).toIntArray()
                        } else pattern.toIntArray()

                        // Tasiyici frekans destegini kontrol et — Xiaomi bazen
                        // sadece belirli frekanslari kabul ediyor.
                        try {
                            val ranges = irManager.carrierFrequencies
                            val destekleniyor = ranges?.any {
                                frequency in it.minFrequency..it.maxFrequency
                            } ?: false
                            if (!destekleniyor && ranges != null && ranges.isNotEmpty()) {
                                val rangeStr = ranges.joinToString(", ") {
                                    "${it.minFrequency}-${it.maxFrequency}"
                                }
                                Log.w(TAG, "frekans $frequency destek disinda. Destek: $rangeStr")
                            }
                        } catch (e: Exception) {
                            Log.w(TAG, "carrierFrequencies kontrol edilemedi: ${e.message}")
                        }

                        // Bazi Xiaomi cihazlarda LED ilk seferde uyumuyor.
                        var lastError: Throwable? = null
                        for (i in 0..1) {
                            try {
                                irManager.transmit(frequency, patternArr)
                                Log.i(TAG, "transmit OK freq=$frequency len=${patternArr.size} attempt=${i+1}")
                                result.success(mapOf(
                                    "ok" to true,
                                    "attempt" to (i + 1),
                                    "patternLen" to patternArr.size,
                                    "freq" to frequency,
                                ))
                                return@setMethodCallHandler
                            } catch (e: SecurityException) {
                                lastError = e
                                Log.e(TAG, "transmit SecurityException: ${e.message}")
                                break // izin sorunu, retry isimez
                            } catch (e: Throwable) {
                                lastError = e
                                Log.w(TAG, "transmit attempt ${i+1} failed: ${e.javaClass.simpleName}: ${e.message}")
                                if (i == 0) Thread.sleep(50)
                            }
                        }
                        val ad = lastError?.javaClass?.simpleName ?: "Unknown"
                        val msg = lastError?.message ?: "bilinmeyen hata"
                        result.error("TX_FAIL", "$ad: $msg", null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
