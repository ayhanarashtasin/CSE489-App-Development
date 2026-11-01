import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:assignment_2/image_scale_screen.dart';
import 'package:assignment_2/audio_screen.dart';
import 'package:assignment_2/video_screen.dart';

/// The media screens are drawer sections, so they're hosted in a Scaffold.
Widget _host(Widget section) => MaterialApp(home: Scaffold(body: section));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'ImageScaleScreen displays pinch gesture hint and InteractiveViewer',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const ImageScaleScreen(
            imageUrl: 'https://picsum.photos/id/10/1200/800',
          ),
        ),
      );

      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(
        find.textContaining('pinch gesture with two fingers'),
        findsOneWidget,
      );
      expect(find.byTooltip('Reset Zoom'), findsOneWidget);
    },
  );

  testWidgets('AudioScreen displays audio title and media controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(const AudioScreen(audioAsset: 'Data/audio.mp3')),
    );

    expect(find.text('audio.mp3'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.stop), findsOneWidget);
    expect(find.byIcon(Icons.replay_5), findsOneWidget);
    expect(find.byIcon(Icons.forward_5), findsOneWidget);
  });

  testWidgets('VideoScreen starts loading the video', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const VideoScreen(
          videoAssetPath: 'Data/gemini_generated_video_5418c219.mp4',
        ),
      ),
    );

    expect(find.text('Loading video media...'), findsOneWidget);
  });
}
