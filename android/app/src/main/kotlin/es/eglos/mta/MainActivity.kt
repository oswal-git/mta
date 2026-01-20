package es.eglos.mta

import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.media.RingtoneManager
import android.net.Uri
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "es.eglos.mta/notifications"

    private var currentRingtone: android.media.Ringtone? = null
    private val scope = kotlinx.coroutines.MainScope()

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "canScheduleExactAlarms" -> {
                    val canSchedule = canScheduleExactAlarms()
                    result.success(canSchedule)
                }
                "openExactAlarmSettings" -> {
                    openExactAlarmSettings()
                    result.success(null)
                }
                "getSystemRingtones" -> {
                    val ringtones = getSystemRingtones()
                    result.success(ringtones)
                }
                "playRingtone" -> {
                    val uriString = call.argument<String>("uri")
                    if (uriString != null) {
                        playRingtone(uriString)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "URI cannot be null", null)
                    }
                }
                "stopRingtone" -> {
                    stopRingtone()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun canScheduleExactAlarms(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarmManager.canScheduleExactAlarms()
        } else {
            true // Versiones anteriores no requieren permiso explícito
        }
    }

    private fun openExactAlarmSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
            startActivity(intent)
        }
    }

    private fun playRingtone(uriString: String) {
        stopRingtone()
        
        try {
            val uri = Uri.parse(uriString)
            currentRingtone = RingtoneManager.getRingtone(context, uri)
            currentRingtone?.play()
            
            // Stop after 5 seconds
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                 if (currentRingtone?.isPlaying == true) {
                     currentRingtone?.stop()
                 }
            }, 5000)
            
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun stopRingtone() {
        try {
            if (currentRingtone?.isPlaying == true) {
                currentRingtone?.stop()
            }
            currentRingtone = null
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun getSystemRingtones(): List<Map<String, String>> {
        val ringtoneManager = RingtoneManager(context)
        ringtoneManager.setType(RingtoneManager.TYPE_NOTIFICATION)
        
        val cursor = ringtoneManager.cursor
        val list = mutableListOf<Map<String, String>>()
        
        try {
            while (cursor.moveToNext()) {
                val title = cursor.getString(RingtoneManager.TITLE_COLUMN_INDEX)
                val id = cursor.getString(RingtoneManager.ID_COLUMN_INDEX)
                val uri = cursor.getString(RingtoneManager.URI_COLUMN_INDEX)
                
                val fullUri = "$uri/$id"
                
                list.add(mapOf(
                    "title" to title,
                    "uri" to fullUri
                ))
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        
        return list
    }
}
