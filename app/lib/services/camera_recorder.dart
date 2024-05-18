import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/services/file_uploader.dart';
import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CameraRecorder {
  CameraController _cameraController;
  String userName = "noname";
  bool _isRecording = false;
  bool _isUsingCameraController = false;
  void Function()? _onStopUsingCameraController;
  void Function(File file, String recordingId)? onUploadFileToService;

  CameraRecorder._({required CameraController cameraController})
      : _cameraController = cameraController;

  static Future<CameraController?> _setupCameraController(
      {required CameraDescription camera,
      ResolutionPreset? resolutionPreset,
      int? fps}) async {
    final cameraController = CameraController(
      camera,
      resolutionPreset ?? ResolutionPreset.veryHigh,
      fps: fps ?? 60,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    return cameraController;
  }

  static Future<CameraRecorder?> setupCameraRecorder(
      {ResolutionPreset? resolutionPreset, int? fps}) async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      return null;
    }
    cameras.firstWhere(
      (element) => element.lensDirection == CameraLensDirection.back,
      orElse: () {
        return cameras.first;
      },
    );

    final cameraController = await _setupCameraController(
      camera: cameras.first,
      resolutionPreset: resolutionPreset,
      fps: fps,
    );
    if (cameraController == null) {
      return null;
    }
    try {
      await cameraController.initialize();
    } on CameraException catch (_) {
      return null;
    }

    return CameraRecorder._(cameraController: cameraController);
  }

  Future<void> changeCameraSettings(
      {ResolutionPreset? resolutionPreset, int? fps}) async {
    final cameraController = await _setupCameraController(
      camera: _cameraController.description,
      resolutionPreset: resolutionPreset,
      fps: fps,
    );
    if (!_isUsingCameraController) {
      final oldController = _cameraController;
      _cameraController = cameraController!;
      await oldController.dispose();
      try {
        await cameraController.initialize();
      } on CameraException catch (_) {}
    } else {
      _onStopUsingCameraController = () async {
        final oldController = _cameraController;
        _cameraController = cameraController!;
        await oldController.dispose();
        try {
          await cameraController.initialize();
        } on CameraException catch (_) {}
      };
    }
  }

  Future<void> startRecording() async {
    if (_isRecording) {
      return;
    }
    _isUsingCameraController = true;
    print("Starting video recording");
    await _cameraController.startVideoRecording();
    _isRecording = true;
  }

  Future<void> stopRecording(String recordingId) async {
    if (!_isRecording) {
      return;
    }
    _isRecording = false;
    print("Stopping video recordings");
    final videoFile = await _cameraController.stopVideoRecording();
    final directory = await getApplicationDocumentsDirectory();
    final fileName = "$userName-${DateTime.now().millisecondsSinceEpoch}";
    final filePath = '${directory.path}/$fileName.mp4';
    print("Saving video to $filePath");
    await videoFile.saveTo(filePath);
    final file = File(filePath);
    onUploadFileToService?.call(file, recordingId);
    _isUsingCameraController = false;
    _onStopUsingCameraController?.call();
  }
}

class CameraRecorderPreview extends StatelessWidget {
  final CameraRecorder recorder;
  const CameraRecorderPreview({super.key, required this.recorder});

  @override
  Widget build(BuildContext context) {
    print(context);
    return CameraPreview(
      recorder._cameraController,
    );
  }
}
