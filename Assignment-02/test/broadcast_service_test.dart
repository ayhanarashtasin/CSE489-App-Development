import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:assignment_2/broadcast_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  group('BroadcastService', () {
    test('sendCustomBroadcast passes the message to Android', () async {
      MethodCall? sent;
      messenger.setMockMethodCallHandler(BroadcastService.methodChannel, (
        call,
      ) async {
        sent = call;
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(
          BroadcastService.methodChannel,
          null,
        ),
      );

      await BroadcastService.sendCustomBroadcast('Hello BRAC CSE 489');

      expect(sent?.method, 'sendCustomBroadcast');
      expect(sent?.arguments, {'message': 'Hello BRAC CSE 489'});
    });

    test('batteryLevels emits every level the receiver gets', () async {
      messenger.setMockStreamHandler(
        BroadcastService.batteryChannel,
        MockStreamHandler.inline(
          onListen: (_, sink) {
            sink
              ..success(80)
              ..success(79);
          },
        ),
      );

      expect(await BroadcastService.batteryLevels.take(2).toList(), [80, 79]);
    });

    test('reports an error instead of fake data on other platforms', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      await expectLater(
        BroadcastService.batteryLevels.first,
        throwsUnsupportedError,
      );
      await expectLater(
        BroadcastService.customBroadcasts.first,
        throwsUnsupportedError,
      );
      await expectLater(
        BroadcastService.sendCustomBroadcast('Hello'),
        throwsUnsupportedError,
      );
    });
  });
}
