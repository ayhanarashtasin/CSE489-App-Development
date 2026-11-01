import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Bridges the Android broadcast receivers in `MainActivity.kt` to Dart.
class BroadcastService {
  static const MethodChannel methodChannel = MethodChannel(
    'com.example.assignment_2/broadcast',
  );
  static const EventChannel customBroadcastChannel = EventChannel(
    'com.example.assignment_2/custom_broadcast',
  );
  static const EventChannel batteryChannel = EventChannel(
    'com.example.assignment_2/battery',
  );

  // An EventChannel supports one native listener at a time, so all screens
  // share these streams. Android registers the receiver when the first
  // listener subscribes and unregisters it when the last one cancels.
  static final Stream<String> _customBroadcasts = customBroadcastChannel
      .receiveBroadcastStream()
      .map((event) => event as String);
  static final Stream<int> _batteryLevels = batteryChannel
      .receiveBroadcastStream()
      .map((event) => event as int);

  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static UnsupportedError get _unsupported =>
      UnsupportedError('Broadcast receivers are only available on Android.');

  /// Messages received by the custom broadcast receiver. The receiver is
  /// registered while this stream has a listener.
  static Stream<String> get customBroadcasts =>
      _isAndroid ? _customBroadcasts : Stream.error(_unsupported);

  /// Battery percentages from `ACTION_BATTERY_CHANGED`. The current level
  /// arrives as soon as the receiver is registered, then on every change.
  static Stream<int> get batteryLevels =>
      _isAndroid ? _batteryLevels : Stream.error(_unsupported);

  /// Sends the app-private custom broadcast carrying [message].
  static Future<void> sendCustomBroadcast(String message) async {
    if (!_isAndroid) throw _unsupported;
    await methodChannel.invokeMethod<void>('sendCustomBroadcast', {
      'message': message,
    });
  }
}
