import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CameraRecorder {
  final CameraController _cameraController;
  bool _isRecording = false;

  CameraRecorder._({required CameraController cameraController})
      : _cameraController = cameraController;

  static Future<CameraRecorder?> setupCameraRecorder() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      return null;
    }
    final cameraController = CameraController(
      cameras.first,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await cameraController.initialize();
    } on CameraException catch (_) {
      return null;
    }

    return CameraRecorder._(cameraController: cameraController);
  }

  Future<void> startRecording() async {
    if (_isRecording) {
      return;
    }
    _cameraController.startVideoRecording();
    _isRecording = true;
  }

  Future<void> stopRecording() async {
    if (!_isRecording) {
      return;
    }
    _isRecording = false;
    _cameraController.stopVideoRecording();
  }
}

class CameraRecorderPreview extends StatelessWidget {
  final CameraRecorder recorder;
  const CameraRecorderPreview({super.key, required this.recorder});

  @override
  Widget build(BuildContext context) {
    return CameraPreview(
      recorder._cameraController,
    );
  }
}
