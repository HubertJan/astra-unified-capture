import 'package:app/screens/recording_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// CameraApp is the Main Application.
class CameraApp extends StatelessWidget {
  const CameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(103, 58, 183, 1),
          brightness: Brightness.light,
        ),
      ),
      home: const RecordingScreen(),
    );
  }
}

Future<void> main() async {
  runApp(const ProviderScope(
    child: CameraApp(),
  ));
}
