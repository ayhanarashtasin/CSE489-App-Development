import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui_constants.dart';
import 'vangti_chai_screen.dart';

void main() {
  runApp(const VangtiChaiApp());
}

class VangtiChaiApp extends StatelessWidget {
  const VangtiChaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VangtiChai',
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'vangti_chai',
      themeMode: ThemeMode.light,
      theme: ThemeData(
        fontFamily: UiConstants.fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: UiConstants.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: UiConstants.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: UiConstants.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: UiConstants.fontFamily,
            fontSize: UiConstants.titleFontSize,
            fontWeight: FontWeight.w500,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: UiConstants.statusBar,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.black,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        ),
      ),
      home: const VangtiChaiScreen(),
    );
  }
}
