import 'package:app/services/camera_recorder.dart';
import 'package:app/provider/command_controller.dart';
import 'package:app/provider/network_ip.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecordingScreen extends ConsumerStatefulWidget {
  const RecordingScreen({super.key});

  @override
  ConsumerState<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen> {
  CameraRecorder? cameraRecorder;
  bool _isInitial = true;

  void onRecordingUpdate(bool shouldBeRecording) {
    if (shouldBeRecording) {
      cameraRecorder?.startRecording();
    } else {
      cameraRecorder?.stopRecording();
    }
  }

  Widget _cameraPreviewWidget() {
    if (cameraRecorder case CameraRecorder cameraRecorder) {
      return CameraRecorderPreview(recorder: cameraRecorder);
    }
    return const Text(
      'Tap a camera',
      style: TextStyle(
        color: Colors.white,
        fontSize: 24.0,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Future<void> _initializeCameraController() async {
    final recorder = await CameraRecorder.setupCameraRecorder();
    if (recorder case CameraRecorder recorder) {
      cameraRecorder = recorder;
      ref.read(commandControllerProvider.notifier).turnOnAutoConnect();
      ref.listen(commandControllerProvider, (before, now) {
        final wasRecording = switch (before) {
          ConnectedControllerState value => value.isRecording,
          _ => false
        };

        final isRecording = switch (now) {
          ConnectedControllerState value => value.isRecording,
          _ => false
        };
        if (wasRecording && !isRecording) {
          cameraRecorder?.stopRecording();
        }
        if (!wasRecording && isRecording) {
          cameraRecorder?.startRecording();
        }
      });
      setState(() {});
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitial) {
      _initializeCameraController();
      _isInitial = false;
    }

    final controllerState = ref.watch(commandControllerProvider);
    final networkIP = ref.watch(networkIPProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera example'),
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              networkIP.maybeMap(
                data: (ip) => Text(ip.value ?? "No IP"),
                orElse: () => const SizedBox(),
              ),
              switch (controllerState) {
                DisconnectedControllerState() => const Text("Error"),
                ConnectingControllerState state => Text(
                    "Loading\n Auto Retry:  ${state.isAutoConnecting ? "True" : "False"}"),
                ConnectedControllerState value =>
                  Text("Connected, Recording: ${value.isRecording}"),
              },
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Center(
                    child: _cameraPreviewWidget(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
