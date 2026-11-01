import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:assignment_2/broadcast_service.dart';
import 'package:assignment_2/main.dart';

/// Plays the role of the Android receivers in MainActivity.kt.
class FakeAndroidBroadcasts {
  MockStreamHandlerEventSink? customReceiver;
  MockStreamHandlerEventSink? batteryReceiver;
  final List<String> sentMessages = [];

  void install(TestDefaultBinaryMessenger messenger) {
    messenger.setMockStreamHandler(
      BroadcastService.customBroadcastChannel,
      MockStreamHandler.inline(
        // Block bodies: the mock replies with whatever these return.
        onListen: (_, sink) {
          customReceiver = sink;
        },
        onCancel: (_) {
          customReceiver = null;
        },
      ),
    );
    messenger.setMockStreamHandler(
      BroadcastService.batteryChannel,
      MockStreamHandler.inline(
        onListen: (_, sink) {
          batteryReceiver = sink;
          sink.success(42); // Sticky broadcast: current level on registration.
        },
        onCancel: (_) {
          batteryReceiver = null;
        },
      ),
    );
    messenger.setMockMethodCallHandler(BroadcastService.methodChannel, (
      call,
    ) async {
      final message = (call.arguments as Map)['message'] as String;
      sentMessages.add(message);
      // Like Android, only a receiver registered at send time gets it.
      customReceiver?.success(message);
      return null;
    });
  }
}

void main() {
  // Installed inside each test (not setUp) so the fake receivers' events run
  // in the test's fake-async zone and are delivered by pump().
  FakeAndroidBroadcasts installFakeAndroid(WidgetTester tester) =>
      FakeAndroidBroadcasts()..install(tester.binding.defaultBinaryMessenger);

  Future<void> openThirdActivityWithMessage(
    WidgetTester tester,
    String message,
  ) async {
    await tester.tap(find.byKey(const Key('proceedButton')));
    await tester.pumpAndSettle();
    expect(find.text('Second Activity (Input)'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('customMessageField')),
      message,
    );
    await tester.tap(find.byKey(const Key('sendBroadcastButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('App renders Home with Broadcast Receiver spinner and Proceed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const Assignment2App());

    expect(find.text('App'), findsOneWidget);
    expect(find.text('Select a broadcast type'), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);
    expect(find.byKey(const Key('proceedButton')), findsOneWidget);
  });

  testWidgets('Drawer shows all four options and sections use one AppBar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const Assignment2App());

    tester.firstState<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();

    expect(find.text('Broadcast Receiver'), findsOneWidget);
    expect(find.text('Image Scale'), findsOneWidget);
    expect(find.text('Video'), findsOneWidget);
    expect(find.text('Audio'), findsOneWidget);

    await tester.tap(find.text('Image Scale'));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Image Scale'),
      ),
      findsOneWidget,
    );
    expect(find.byType(InteractiveViewer), findsOneWidget);
  });

  testWidgets(
    'Third Activity registers the receiver, which receives the text',
    (WidgetTester tester) async {
      final android = installFakeAndroid(tester);
      await tester.pumpWidget(const Assignment2App());
      await openThirdActivityWithMessage(tester, 'Testing Assignment 2');

      // Second Activity only passes the text; the broadcast is sent after the
      // Third Activity has registered its receiver.
      expect(android.sentMessages, ['Testing Assignment 2']);
      expect(android.customReceiver, isNotNull);

      expect(find.text('Third Activity'), findsOneWidget);
      expect(find.text('Custom Broadcast Receiver'), findsOneWidget);
      expect(
        tester
            .widget<Text>(find.byKey(const Key('receivedBroadcastMessageText')))
            .data,
        'Testing Assignment 2',
      );

      await tester.tap(find.text('Back to Home'));
      await tester.pumpAndSettle();

      expect(find.text('Select a broadcast type'), findsOneWidget);
      expect(android.customReceiver, isNull, reason: 'receiver unregistered');
    },
  );

  testWidgets('Third Activity shows only what the receiver delivers', (
    WidgetTester tester,
  ) async {
    final android = installFakeAndroid(tester);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      BroadcastService.methodChannel,
      (_) async => null, // Broadcast sent, but never delivered.
    );

    await tester.pumpWidget(const Assignment2App());
    await openThirdActivityWithMessage(tester, 'Never delivered');

    expect(
      find.text('Receiver registered. Waiting for broadcast...'),
      findsOneWidget,
    );
    expect(find.text('Never delivered'), findsNothing);

    android.customReceiver!.success('Delivered later');
    await tester.pumpAndSettle();

    expect(find.text('Delivered later'), findsOneWidget);
  });

  testWidgets(
    'Battery receiver shows live updates; Third Activity does nothing',
    (WidgetTester tester) async {
      final android = installFakeAndroid(tester);
      await tester.pumpWidget(const Assignment2App());

      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('System battery notification receiver').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('proceedButton')));
      await tester.pumpAndSettle();

      expect(find.text('Second Activity (Battery)'), findsOneWidget);
      expect(find.text('Broadcast: ACTION_BATTERY_CHANGED'), findsOneWidget);
      expect(find.text('Battery: 42%'), findsOneWidget);

      android.batteryReceiver!.success(57);
      await tester.pumpAndSettle();
      expect(find.text('Battery: 57%'), findsOneWidget);

      android.batteryReceiver!.error(code: 'UNAVAILABLE');
      await tester.pumpAndSettle();
      expect(find.text('Unable to read battery level'), findsOneWidget);

      await tester.tap(find.text('Go to Third Activity'));
      await tester.pumpAndSettle();

      expect(find.text('Third Activity'), findsAtLeastNWidgets(1));
      expect(find.textContaining('do nothing here'), findsOneWidget);

      await tester.tap(find.text('Back to Home'));
      await tester.pumpAndSettle();
      expect(android.batteryReceiver, isNull, reason: 'receiver unregistered');
    },
  );
}
