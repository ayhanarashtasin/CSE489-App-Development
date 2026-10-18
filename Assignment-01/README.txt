VangtiChai - CSE 489: Mobile Application Development, Assignment 1
================================================================

OVERVIEW
Enter a whole Taka amount using the on-screen numeric buttons. The app calculates
the minimum note breakdown using 500, 100, 50, 20, 10, 5, 2, and 1 Taka notes.
All denominations remain visible, including those whose count is zero.

BEHAVIOR
- Digits append on the right: 2, then 23, then 234.
- CLEAR empties the amount and resets all note counts.
- Leading zeros are normalized; zero itself displays as Taka: 0.
- BigInt arithmetic avoids overflow, rounding, and an arbitrary digit limit.
- Long amounts and note columns can be scrolled horizontally to read every digit.
- Portrait: one note column; keypad rows 123 / 456 / 789 / 0 CLEAR.
- Landscape: note columns 500,100,50,20 and 10,5,2,1;
  keypad rows 1234 / 5678 / 90 CLEAR. CLEAR spans two key columns.
- Rotation keeps the amount and recomputes the same note breakdown.
- Flutter restoration saves the entered digits for OS-managed activity/process
  recreation. This is not permanent storage after a force-stop or task removal.
- The reference light theme is retained even if the system uses dark mode.
- Small windows and enlarged accessibility text can scroll vertically.

FLUTTER AND ANDROID REQUIREMENTS
Developed with Flutter 3.47.7 / Dart 3.13.5. pubspec.yaml specifies Dart ^3.13.5.
The installed Flutter SDK defaults to Android API 24 (Android 7.0) minimum and
compile SDK 36. API 21 cannot be enabled just by lowering the Gradle value with
this Flutter SDK; strict Android 5.0 support requires a compatible older SDK or
a native implementation.

Install a compatible Android Studio / Android SDK, the JDK required by the Android
Gradle plugin (use flutter doctor -v to check it), SDK platform 36, build tools,
platform-tools, command-line tools, and an emulator/system image. Run flutter
doctor and accept Android SDK licenses.

RUN AND BUILD
From the project directory, with Flutter on PATH:
  flutter pub get
  flutter devices
  flutter run -d <android-device-id>

For a browser preview without an Android device:
  flutter run -d chrome

Validation commands:
  dart format --output=none --set-exit-if-changed lib test
  flutter analyze
  flutter test
  flutter build apk --debug

The Android app display name is VangtiChai. The existing project/package name
flutter_application_1 is retained to avoid unrelated native project migrations.

LAYOUT IMPLEMENTATION
This assignment uses Flutter, which the specification explicitly allows.
LayoutBuilder and MediaQuery replace native XML alternative layouts. The same
widgets adapt to portrait/landscape and phone/tablet sizes (600dp shortest-side
breakpoint), rather than maintaining four separate copies of the screen.
lib/ui_constants.dart centralizes colors, padding, gaps, text sizes, and layout
limits: the Flutter equivalent of colors.xml and sizes.xml. Native app text is
stored in android/app/src/main/res/values/strings.xml. SafeArea handles OS insets.
No ConstraintLayout dependency, external fonts, or new Dart packages are needed.

SOURCE FILES
  lib/main.dart                    App entry, light theme, restoration scope
  lib/vangti_chai_screen.dart       Stateful screen, custom keypad, adaptive UI
  lib/change_calculator.dart       Integer-only, minimum-note calculation
  lib/ui_constants.dart            Shared visual and dimension constants
  test/change_calculator_test.dart Unit tests and minimum-note verification
  test/widget_test.dart            Input, rotation, restoration, layout, access

VERIFICATION RECORD
Verified on 2026-10-17 with Flutter 3.47.7 / Dart 3.13.5 on Windows:
- dart format --output=none --set-exit-if-changed lib test: passed.
- flutter analyze --no-pub: passed, no issues found.
- flutter test --no-pub: all 34 tests passed.
- flutter build apk --debug --no-pub: passed; installable debug APK is at
  build/app/outputs/flutter-apk/app-debug.apk.
- flutter build web --no-pub: passed; output is build/web. The compiler's Wasm
  dry run also succeeded (a browser runtime test was not performed).
- Rendered and visually checked the four required layouts with Roboto loaded
  using Flutter's headless widget-test renderer (not an Android emulator).

Required configurations passed in widget-test simulation (logical pixels / dp):
  Pixel XL portrait       411 x 731
  Pixel XL landscape      731 x 411
  Nexus 10 portrait       800 x 1280
  Nexus 10 landscape     1280 x 800

Additional configurations passed in widget-test simulation:
  Small phone portrait    360 x 640
  Small phone landscape   640 x 360
  Small tablet portrait   600 x 960
  Small tablet landscape  960 x 600

Other passing checks:
- Exact assignment examples: 6, 68, 688, and 6880.
- All amounts 1 through 1000 checked against an independent minimum-note solver.
- Individual denominations, zero, negative-amount rejection, and 30-digit input.
- Rotation in both directions, continued input, OS-style restoration, and CLEAR.
- 3x system text on the small phone in both orientations, with reduced motion.
- Android touch-target sizes, accessible button labels, and text contrast.
- A dark system setting retains the intended light reference appearance.

ANDROID DEVICE/EMULATOR STATUS
The Android APK build succeeded. Gradle automatically installed missing SDK build
components, including Android platform 36, NDK 28.2.13676358, and CMake 3.22.1.
The SDK now also contains build-tools and platform-tools. Android command-line
tools were still absent at the last directory check.

After SDK setup, one existing emulator profile became discoverable:
Medium_Phone_API_37.0. A headless, read-only, no-snapshot startup was attempted,
but ADB remained offline and device readiness timed out after 180 seconds.
That test emulator was stopped; the app was not installed or run on it.
No physical Android device was connected. Android runtime verification therefore
remains incomplete despite the successful APK build and headless layout checks.

Before submission, run the app on Pixel XL and Nexus 10 emulator profiles in both
orientations. Record those actual runs here; the viewport simulations above do
not satisfy the separate emulator-run task.
