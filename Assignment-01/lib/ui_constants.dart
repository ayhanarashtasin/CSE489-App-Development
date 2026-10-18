import 'package:flutter/material.dart';

/// Flutter's equivalent of shared Android colors and sizes resource files.
abstract final class UiConstants {
  static const primary = Color(0xFF008577);
  static const statusBar = Color(0xFF00695C);
  static const background = Color(0xFFFAFAFA);
  static const keyBackground = Color(0xFFD6D6D6);
  static const foreground = Color(0xFF212121);
  static const fontFamily = 'Roboto';

  static const tabletBreakpoint = 600.0;
  static const portraitMaxWidth = 720.0;
  static const landscapeMaxWidth = 1120.0;
  static const portraitMaxBodyHeight = 640.0;
  static const landscapeMaxBodyHeight = 400.0;

  static const phonePadding = 16.0;
  static const tabletPadding = 32.0;
  static const gap = 8.0;
  static const sectionGap = 24.0;
  static const tabletSectionGap = 32.0;
  static const minimumTouchTarget = 48.0;

  static const titleFontSize = 20.0;
  static const phoneFontSize = 20.0;
  static const tabletFontSize = 24.0;
  static const phoneAmountFontSize = 22.0;
  static const tabletAmountFontSize = 28.0;
  static const lineHeight = 1.3;

  static const phoneNoteHeight = 48.0;
  static const tabletNoteHeight = 64.0;
  static const phoneKeyHeight = 56.0;
  static const tabletKeyHeight = 80.0;
  static const phoneAmountHeight = 48.0;
  static const phoneLandscapeAmountHeight = 40.0;
  static const tabletAmountHeight = 64.0;
}
