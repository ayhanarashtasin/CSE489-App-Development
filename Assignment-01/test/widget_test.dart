import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/change_calculator.dart';
import 'package:flutter_application_1/main.dart';

Finder keyButton(String digit) => find.byKey(ValueKey('key-$digit'));

Future<void> pumpApp(
  WidgetTester tester, {
  Size size = const Size(411, 731),
  double textScale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
  tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 24);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
    tester.view.resetPadding();
    tester.view.resetViewPadding();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });

  await tester.pumpWidget(const VangtiChaiApp());
  await tester.pumpAndSettle();
}

Future<void> enterDigits(WidgetTester tester, String digits) async {
  for (final digit in digits.split('')) {
    await tester.tap(keyButton(digit));
    await tester.pump();
  }
}

void expectCounts(List<int> counts) {
  for (var index = 0; index < takaDenominations.length; index++) {
    expect(
      find.text('${takaDenominations[index]}: ${counts[index]}'),
      findsOneWidget,
    );
  }
}

void main() {
  testWidgets('starts empty with a custom keypad and all zero counts', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('VangtiChai'), findsOneWidget);
    expect(find.text('Taka:'), findsOneWidget);
    expect(find.byType(TextButton), findsNWidgets(11));
    expect(find.byType(EditableText), findsNothing);
    expectCounts(List.filled(8, 0));
  });

  testWidgets('digits append in order and CLEAR resets every count', (
    tester,
  ) async {
    await pumpApp(tester);

    for (final amount in ['2', '23', '234']) {
      await enterDigits(tester, amount.substring(amount.length - 1));
      expect(find.text('Taka: $amount'), findsOneWidget);
    }
    await tester.tap(keyButton('CLEAR'));
    await tester.pump();

    expect(find.text('Taka:'), findsOneWidget);
    expectCounts(List.filled(8, 0));
  });

  testWidgets('normalizes leading zeros and supports repeated digits', (
    tester,
  ) async {
    await pumpApp(tester);
    await enterDigits(tester, '000688');

    expect(find.text('Taka: 688'), findsOneWidget);
    expectCounts(List.filled(8, 1));
  });

  final sizes = {
    'Pixel XL portrait': const Size(411, 731),
    'Pixel XL landscape': const Size(731, 411),
    'Nexus 10 portrait': const Size(800, 1280),
    'Nexus 10 landscape': const Size(1280, 800),
    'small phone portrait': const Size(360, 640),
    'small phone landscape': const Size(640, 360),
    'small tablet portrait': const Size(600, 960),
    'small tablet landscape': const Size(960, 600),
  };

  for (final entry in sizes.entries) {
    testWidgets('${entry.key} has the correct layout and reachable keys', (
      tester,
    ) async {
      await pumpApp(tester, size: entry.value);
      await enterDigits(tester, '688');

      expectCounts(List.filled(8, 1));
      expect(tester.takeException(), isNull);

      final landscape = entry.value.width > entry.value.height;
      final firstKey = tester.getRect(keyButton('1'));
      final fourthKey = tester.getRect(keyButton('4'));
      final firstNote = tester.getRect(find.byKey(const ValueKey('note-500')));
      final fifthNote = tester.getRect(find.byKey(const ValueKey('note-10')));

      if (landscape) {
        expect(firstKey.top, fourthKey.top);
        expect(firstNote.top, fifthNote.top);
        expect(fifthNote.left, greaterThan(firstNote.left));
      } else {
        expect(fourthKey.top, greaterThan(firstKey.top));
        expect(firstNote.left, fifthNote.left);
        expect(fifthNote.top, greaterThan(firstNote.top));
      }

      final clear = tester.getRect(keyButton('CLEAR'));
      expect(clear.width, greaterThanOrEqualTo(firstKey.width * 2));
      for (final label in [...List.generate(10, (i) => '$i'), 'CLEAR']) {
        final rect = tester.getRect(keyButton(label));
        expect(rect.width, greaterThanOrEqualTo(48));
        expect(rect.height, greaterThanOrEqualTo(48));
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(entry.value.width));
        expect(rect.top, greaterThanOrEqualTo(24));
        expect(rect.bottom, lessThanOrEqualTo(entry.value.height - 24));
      }
    });
  }

  testWidgets('rotation retains the amount and supports continued entry', (
    tester,
  ) async {
    await pumpApp(tester);
    await enterDigits(tester, '688');

    tester.view.physicalSize = const Size(731, 411);
    await tester.pumpAndSettle();
    expect(find.text('Taka: 688'), findsOneWidget);
    expectCounts(List.filled(8, 1));

    await enterDigits(tester, '0');
    expect(find.text('Taka: 6880'), findsOneWidget);
    expectCounts([13, 3, 1, 1, 1, 0, 0, 0]);

    tester.view.physicalSize = const Size(411, 731);
    await tester.pumpAndSettle();
    expect(find.text('Taka: 6880'), findsOneWidget);
    expectCounts([13, 3, 1, 1, 1, 0, 0, 0]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Android restoration retains input and a cleared state', (
    tester,
  ) async {
    await pumpApp(tester);
    await enterDigits(tester, '688');
    await tester.restartAndRestore();
    await tester.pumpAndSettle();

    expect(find.text('Taka: 688'), findsOneWidget);
    expectCounts(List.filled(8, 1));

    await tester.tap(keyButton('CLEAR'));
    await tester.pump();
    await tester.restartAndRestore();
    await tester.pumpAndSettle();

    expect(find.text('Taka:'), findsOneWidget);
    expectCounts(List.filled(8, 0));
  });

  testWidgets('long amounts remain exact without render overflow', (
    tester,
  ) async {
    await pumpApp(tester);
    final digits = List.filled(30, '9').join();
    await enterDigits(tester, digits);

    expect(find.text('Taka: $digits'), findsOneWidget);
    final counts = calculateChange(BigInt.parse(digits));
    for (final entry in counts.entries) {
      expect(find.text('${entry.key}: ${entry.value}'), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(360, 640), const Size(640, 360)]) {
    testWidgets('3x text stays usable at $size with reduced motion', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await pumpApp(tester, size: size, textScale: 3);

      await tester.ensureVisible(keyButton('9'));
      await tester.tap(keyButton('9'));
      await tester.pumpAndSettle();
      expect(find.text('Taka: 9'), findsOneWidget);

      await tester.ensureVisible(keyButton('CLEAR'));
      await tester.tap(keyButton('CLEAR'));
      await tester.pumpAndSettle();
      expect(find.text('Taka:'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('dark system setting retains the reference light theme', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await pumpApp(tester);

    final context = tester.element(find.byType(Scaffold));
    expect(Theme.of(context).brightness, Brightness.light);
    expect(tester.takeException(), isNull);
  });

  testWidgets('buttons have accessible labels, contrast and touch targets', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await pumpApp(tester);

      expect(find.bySemanticsLabel('Clear amount'), findsOneWidget);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    } finally {
      semantics.dispose();
    }
  });
}
