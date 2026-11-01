package com.example.assignment_2

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val receiverStreams = mutableListOf<ReceiverStream>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        MethodChannel(messenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendCustomBroadcast" -> {
                    val intent = Intent(CUSTOM_ACTION)
                        .setPackage(packageName)
                        .putExtra(EXTRA_MESSAGE, call.argument<String>("message") ?: "")
                    sendBroadcast(intent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // Custom broadcast receiver: created when the third screen starts listening.
        val customStream = ReceiverStream(IntentFilter(CUSTOM_ACTION), notExported = true) { intent, events ->
            events.success(intent.getStringExtra(EXTRA_MESSAGE) ?: "")
        }

        // System battery receiver: ACTION_BATTERY_CHANGED is sticky, so the current
        // level arrives immediately on registration and again on every change.
        val batteryStream = ReceiverStream(IntentFilter(Intent.ACTION_BATTERY_CHANGED), notExported = false) { intent, events ->
            val level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
            val scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
            if (level >= 0 && scale > 0) {
                events.success(level * 100 / scale)
            } else {
                events.error("UNAVAILABLE", "Battery level not available.", null)
            }
        }

        EventChannel(messenger, CUSTOM_EVENT_CHANNEL).setStreamHandler(customStream)
        EventChannel(messenger, BATTERY_EVENT_CHANNEL).setStreamHandler(batteryStream)
        receiverStreams += listOf(customStream, batteryStream)
    }

    override fun onDestroy() {
        receiverStreams.forEach { it.onCancel(null) }
        super.onDestroy()
    }

    /** Registers a receiver while Dart listens to the event channel, and unregisters it on cancel. */
    private inner class ReceiverStream(
        private val filter: IntentFilter,
        private val notExported: Boolean,
        private val onBroadcast: (Intent, EventChannel.EventSink) -> Unit,
    ) : EventChannel.StreamHandler {
        private var receiver: BroadcastReceiver? = null

        override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
            onCancel(null)
            val newReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context, intent: Intent) = onBroadcast(intent, events)
            }
            // System broadcasts don't need an export flag; app-private ones must be
            // marked not exported on Android 13+.
            if (notExported && Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(newReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
            } else {
                registerReceiver(newReceiver, filter)
            }
            receiver = newReceiver
        }

        override fun onCancel(arguments: Any?) {
            receiver?.let { unregisterReceiver(it) }
            receiver = null
        }
    }

    companion object {
        private const val METHOD_CHANNEL = "com.example.assignment_2/broadcast"
        private const val CUSTOM_EVENT_CHANNEL = "com.example.assignment_2/custom_broadcast"
        private const val BATTERY_EVENT_CHANNEL = "com.example.assignment_2/battery"
        private const val CUSTOM_ACTION = "com.example.assignment_2.CUSTOM_BROADCAST"
        private const val EXTRA_MESSAGE = "broadcast_message"
    }
}
