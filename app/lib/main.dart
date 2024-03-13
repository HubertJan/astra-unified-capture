import 'package:app/recording_screen.dart';
import 'package:flutter/material.dart';

/// CameraApp is the Main Application.
class CameraApp extends StatelessWidget {
  const CameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RecordingScreen(),
    );
  }
}

Future<void> main() async {
  runApp(const CameraApp());
}
