# CSE 489: Mobile Application Development — Assignment 2

## Overview
This project completes **Assignment 2** for CSE 489: Mobile Application Development (BRAC University).
The application demonstrates:
1. **Navigation Drawer Widget**: Accessible from the App Bar hamburger icon. Each drawer item swaps the body below a single App Bar (fragment-style); the broadcast flow pushes separate screens (activity-style).
2. **Broadcast Receiver Flow**:
   - **First Screen (Spinner / Selection)**: Dropdown selecting either *Custom broadcast receiver* or *System battery notification receiver* with a **Proceed** button.
   - **Second Screen**:
     - *Custom Option*: Input field for plain text, which is passed to the third screen.
     - *Battery Option*: Registers an `ACTION_BATTERY_CHANGED` receiver while the screen is open and shows the battery percentage, updating live whenever it changes.
   - **Third Screen**:
     - *Custom Option*: Registers the custom broadcast receiver (`com.example.assignment_2.CUSTOM_BROADCAST`), sends the passed text as a broadcast, and displays only what the receiver's `onReceive` delivers. The receiver is unregistered when the screen closes.
     - *Battery Option*: Handled with "do nothing here" informational notice as specified in the assignment sheet.
3. **Image Scale**:
   - Loads network image (`https://picsum.photos/id/10/1200/800`).
   - Implements two-finger pinch-to-zoom and pan gestures via `InteractiveViewer`.
   - Includes a reset zoom button, and a Retry button if the image fails to load.
4. **Video Player**:
   - Plays local video (`Data/gemini_generated_video_5418c219.mp4`).
   - Full playback controls: Play/Pause, Rewind 5s, Forward 5s, timeline seek slider, elapsed/total duration.
5. **Audio Player**:
   - Plays local audio (`Data/audio.mp3`).
   - Full playback controls: Play/Pause, Stop, Rewind 5s, Forward 5s, timeline seek slider, elapsed/total duration.

---

## Directory Structure
```
Assignment-02/
├── android/
│   └── app/src/main/
│       ├── AndroidManifest.xml
│       └── kotlin/com/example/assignment_2/
│           └── MainActivity.kt        # Android BroadcastReceivers exposed over platform channels
├── Data/
│   ├── audio.mp3                      # Local audio media asset
│   └── gemini_generated_video_5418c219.mp4  # Local video media asset
├── lib/
│   ├── main.dart                      # App entry point, theme, navigation drawer
│   ├── broadcast_service.dart         # Dart side of the method/event channels
│   ├── broadcast_first_screen.dart    # First screen (spinner + proceed)
│   ├── broadcast_second_screen.dart   # Second screen (custom text input / live battery receiver)
│   ├── broadcast_third_screen.dart    # Third screen (custom receiver / battery no-op)
│   ├── image_scale_screen.dart        # Image pinch gesture screen
│   ├── video_screen.dart              # Video media player
│   └── audio_screen.dart              # Audio media player
├── test/
│   ├── broadcast_service_test.dart    # Unit tests for the broadcast channels
│   ├── media_screens_test.dart        # Widget tests for image, video, and audio players
│   └── widget_test.dart               # Full navigation drawer and broadcast flow tests
├── CSE 489 Assigment L2 v5.pdf        # Assignment 2 Specification
└── pubspec.yaml                       # Dependencies and asset declarations
```

---

## Android Native & Jetpack Architecture
In `android/app/src/main/kotlin/com/example/assignment_2/MainActivity.kt`, each receiver is tied to an `EventChannel`: it is registered when a Flutter screen starts listening and unregistered when that screen closes.
- **Custom Broadcast** (`com.example.assignment_2/custom_broadcast`): a `BroadcastReceiver` for `IntentFilter("com.example.assignment_2.CUSTOM_BROADCAST")`, registered `RECEIVER_NOT_EXPORTED` on Android 13+. The third screen sends the broadcast through the `com.example.assignment_2/broadcast` method channel (`sendBroadcast(Intent(...).setPackage(packageName))`), and `onReceive` forwards the message to Flutter.
- **Battery Receiver** (`com.example.assignment_2/battery`): a `BroadcastReceiver` for `Intent.ACTION_BATTERY_CHANGED` that computes the percentage from `BatteryManager.EXTRA_LEVEL` / `EXTRA_SCALE` on every update. Because the broadcast is sticky, the current level arrives as soon as the receiver is registered.

Broadcast receivers are Android-only. On other platforms the broadcast screens show an error instead of placeholder data.

---

## How to Run

### Prerequisites
- Flutter SDK installed and on PATH (Dart 3.x / Flutter 3.x).
- Android SDK / Device or Emulator.

### Commands
From this directory (`Assignment-02`):
```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run analysis
flutter analyze

# 3. Run all tests
flutter test

# 4. Run application on connected device / emulator
flutter run
```
