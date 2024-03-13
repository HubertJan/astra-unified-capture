import 'package:app/camera_recorder.dart';
import 'package:app/command_receiver.dart';
import 'package:flutter/material.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  CameraRecorder? cameraRecorder;
  CommandReceiver? commandReceiver;

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

  @override
  void initState() {
    super.initState();
    commandReceiver = CommandReceiver(onRecordingUpdate: onRecordingUpdate);
    _initializeCameraController();
  }

  Future<void> _initializeCameraController() async {
    final recorder = await CameraRecorder.setupCameraRecorder();
    if (recorder case CameraRecorder recorder) {
      cameraRecorder = recorder;
      setState(() {});
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera example'),
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              FutureBuilder(
                future: commandReceiver?.establishConnection(),
                builder: (context, state) {
                  if (state.hasError) {
                    return const Text("Error");
                  }
                  if (!state.hasData) {
                    return const Text("Loading");
                  }
                  return const Text("Connected");
                },
              ),
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
