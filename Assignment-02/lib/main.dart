import 'package:flutter/material.dart';

import 'broadcast_first_screen.dart';
import 'image_scale_screen.dart';
import 'video_screen.dart';
import 'audio_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Assignment2App());
}

class Assignment2App extends StatelessWidget {
  const Assignment2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSE 489 Assignment 2',
      debugShowCheckedModeBanner: true,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
        ),
      ),
      home: const MainDrawerScreen(),
    );
  }
}

class MainDrawerScreen extends StatefulWidget {
  const MainDrawerScreen({super.key});

  @override
  State<MainDrawerScreen> createState() => _MainDrawerScreenState();
}

class _MainDrawerScreenState extends State<MainDrawerScreen> {
  static const _sections = [
    'Broadcast Receiver',
    'Image Scale',
    'Video',
    'Audio',
  ];

  int _selectedIndex = 0;

  void _onSelectItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop(); // Close drawer
  }

  // Each section is body content only, so the drawer's AppBar is the only one.
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 1:
        return const ImageScaleScreen();
      case 2:
        return const VideoScreen();
      case 3:
        return const AudioScreen();
      default:
        return const BroadcastFirstScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'App' : _sections[_selectedIndex]),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 48),
            for (var i = 0; i < _sections.length; i++)
              ListTile(
                title: Text(_sections[i], style: const TextStyle(fontSize: 16)),
                selected: _selectedIndex == i,
                onTap: () => _onSelectItem(i),
              ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }
}
