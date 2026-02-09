package com.example.app

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.TelephonyManager
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.IOException

class MainActivity : FlutterActivity() {

    private val DEVICE_CHANNEL = "device_collector"
    private val SERVICE_CHANNEL = "background_service"
    private val client = OkHttpClient()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEVICE_CHANNEL)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "collectAndSendDeviceData" -> {
                            collectAndSendDeviceData()
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SERVICE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startService" -> {
                        val intent = Intent(this, LocationService::class.java)
                        ContextCompat.startForegroundService(this, intent)
                        result.success(null)
                    }
                    "stopService" -> {
                        stopService(Intent(this, LocationService::class.java))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun collectAndSendDeviceData() {
        val data = collectDeviceData()
        sendDeviceDataToServer(data)
    }

    private fun sendDeviceDataToServer(data: Map<String, Any?>) {
        val json = JSONObject(data).apply {
            put("timestamp", System.currentTimeMillis())
        }

        val body = json.toString().toRequestBody("application/json".toMediaType())

        val request = Request.Builder()
            .url(AppConstants.DEVICE_ENDPOINT)
            .post(body)
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                println("Failed to send device data: ${e.message}")
            }

            override fun onResponse(call: Call, response: Response) {
                println("Device data sent. Status: ${response.code}")
                response.close()
            }
        })
    }

    private fun collectDeviceData(): Map<String, Any?> {
        val data = HashMap<String, Any?>()

        // Device info
        data["manufacturer"] = Build.MANUFACTURER
        data["model"] = Build.MODEL
        data["manufacturer"] = Build.MANUFACTURER
        data["fingerprint"] = Build.FINGERPRINT
        data["brand"] = Build.BRAND
        data["device"] = Build.DEVICE
        data["product"] = Build.PRODUCT
        data["android_version"] = Build.VERSION.RELEASE
        data["sdk"] = Build.VERSION.SDK_INT

        data["timezone"] = java.util.TimeZone.getDefault().id
        data["language"] = java.util.Locale.getDefault().language
        data["screen_density"] = resources.displayMetrics.density

        // Telephony info
        val tm = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        data["sim_operator"] = tm.simOperatorName
        data["sim_country"] = tm.simCountryIso
        data["network_operator"] = tm.networkOperatorName

        data["phone_number"] = if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.READ_PHONE_STATE
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            try { tm.line1Number } catch (e: Exception) { null }
        } else {
            null
        }

        data["device_id"] = android.provider.Settings.Secure.getString(
            contentResolver,
            android.provider.Settings.Secure.ANDROID_ID
        )

        return data
    }
}