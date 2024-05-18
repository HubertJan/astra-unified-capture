import 'package:app/provider/current_camera_settings.dart';
import 'package:app/provider/device_name.dart';
import 'package:app/provider/recorded_video_uploader.dart';
import 'package:app/services/camera_recorder.dart';
import 'package:app/provider/command_controller.dart';
import 'package:app/provider/network_ip.dart';
import 'package:app/widgets/show_camera_settings_dialog.dart';
import 'package:app/widgets/show_text_input_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_screen_on/keep_screen_on.dart';

class RecordingScreen extends ConsumerStatefulWidget {
  const RecordingScreen({super.key});

  @override
  ConsumerState<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen> {
  CameraRecorder? cameraRecorder;
  bool _isInitial = true;

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
    if (!ref.context.mounted) {
      return;
    }
    if (recorder case CameraRecorder recorder) {
      cameraRecorder = recorder;
      cameraRecorder?.onUploadFileToService = (file, recordingId) async {
        await ref
            .read(recordedVideoUploaderProvider.notifier)
            .addVideo(file, recordingId);
        await ref
            .read(recordedVideoUploaderProvider.notifier)
            .uploadAllNotUploadedVideos();
      };
      ref.read(commandControllerProvider.notifier).turnOnAutoConnect();
      setState(() {});
      return;
    }
    setState(() {});
  }

  void _updateRecorder() {
    if (cameraRecorder case CameraRecorder recorder) {
      ref.listen<ControllerState>(commandControllerProvider, (before, now) {
        if (now case ConnectingControllerState()) {
          return;
        }

        print("Before: ${before?.state}, Now: ${now.state}");
        final wasRecording = switch (before?.state) {
          ConnectedControllerState value => value.recordingState is Recording,
          _ => false
        };

        final isRecording = switch (now.state) {
          ConnectedControllerState value => value.recordingState is Recording,
          _ => false
        };
        if (wasRecording && !isRecording) {
          final recordingId = switch (before?.state) {
            ConnectedControllerState(recordingState: Recording(id: final id)) =>
              id,
            _ => null
          };
          print("Stopping recording now");
          recorder.stopRecording(recordingId!);
        }
        if (!wasRecording && isRecording) {
          print("Starting recording now");
          recorder.startRecording();
        }
      });
    }
  }

  Future<void> _changeName({bool hasToChangeName = false}) async {
    String? userName;
    while (userName == null) {
      userName = await showTextInputDialog(context, "Type in the device name",
          (proposedName) {
        if (proposedName.trim() != proposedName) {
          return Invalid(
              errorMessage: "Name cannot have leading or trailing spaces");
        }
        if (proposedName.isEmpty) {
          return Invalid(errorMessage: "Name cannot be empty");
        }
        if (proposedName.length < 5) {
          return Invalid(
              errorMessage: "Name must be at least 5 characters long");
        }
        return Success();
      });
      if (!hasToChangeName) {
        break;
      }
    }
    if (userName == null) {
      return;
    }
    await ref.read(deviceNameProvider.notifier).changeName(userName);
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitial) {
      KeepScreenOn.turnOn();
      _initializeCameraController();
      _isInitial = false;
      ref.listen(deviceNameProvider, (_, next) async {
        if (next case AsyncData(value: null)) {
          if (!context.mounted) {
            return;
          }
          await _changeName();
        }
      });
    }

    _updateRecorder();

    final controllerState = ref.watch(commandControllerProvider);
    final networkIP = ref.watch(networkIPProvider);
    final deviceName = ref.watch(deviceNameProvider);
    final recordedVideoUploader = ref.watch(recordedVideoUploaderProvider);
    if (deviceName case AsyncData(value: String name)) {
      cameraRecorder?.userName = name;
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Astra Bremen - Record'),
        actions: [
          recordedVideoUploader.maybeMap(
              orElse: () => const SizedBox(),
              data: (count) {
                if (count.value == 0) {
                  return const SizedBox();
                }
                return IconButton(
                  onPressed: () async {
                    await ref
                        .read(recordedVideoUploaderProvider.notifier)
                        .uploadAllNotUploadedVideos();
                  },
                  icon: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_upload,
                        size: 20,
                      ),
                      SizedBox(
                        child: Text(
                          "${count.value} Videos",
                          style: const TextStyle(fontSize: 11),
                        ),
                      )
                    ],
                  ),
                  tooltip: 'Upload not uploaded videos',
                );
              }),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Setup Camera',
            onPressed: () async {
              final currentSettings =
                  await ref.watch(currentCameraSettingsProvider.future);
              if (!context.mounted) {
                return;
              }
              final settings =
                  await showCameraSettingsDialog(context, currentSettings);
              if (settings == null) {
                return;
              }
              await ref
                  .read(currentCameraSettingsProvider.notifier)
                  .changeSettings(settings);
              await cameraRecorder?.changeCameraSettings(
                  resolutionPreset: settings.resolution, fps: settings.fps);
              setState(() {});
              1;
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              const SizedBox(
                height: 30,
              ),
              networkIP.maybeMap(
                data: (ip) =>
                    _DefaultText("This Phone's IP: ${ip.value ?? "No IP"}"),
                orElse: () => const SizedBox(),
              ),
              deviceName.maybeMap(
                data: (name) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _DefaultText("Phone's Name: ${name.value ?? "No Name"}"),
                    TextButton(
                      onPressed: () async {
                        await _changeName(hasToChangeName: false);
                      },
                      child: const Text("Change Name"),
                    )
                  ],
                ),
                orElse: () => const SizedBox(),
              ),
              switch (controllerState.state) {
                DisconnectedControllerState() => Column(
                    children: [
                      const _DefaultText(
                        "Disconnected",
                      ),
                      TextButton(
                        onPressed: () => ref
                            .read(commandControllerProvider.notifier)
                            .turnOnAutoConnect(),
                        child: const _DefaultText(
                          "Try auto connecting",
                        ),
                      )
                    ],
                  ),
                ConnectingControllerState _ => Column(
                    children: [
                      const _DefaultText(
                        "Looking for the server",
                      ),
                      _DefaultText(
                        "Auto Retry: ${controllerState.isAutoConnecting ? "True" : "False"}",
                      ),
                      TextButton(
                        onPressed: () => ref
                            .read(commandControllerProvider.notifier)
                            .turnOffAutoConnect(),
                        child: const _DefaultText(
                          "Give up looking",
                        ),
                      )
                    ],
                  ),
                ConnectedControllerState value => Column(
                    children: [
                      const _DefaultText(
                        "Connected",
                      ),
                      _DefaultText(
                        "Recording: ${value.recordingState}",
                      )
                    ],
                  ),
              },
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Center(
                    child: _cameraPreviewWidget(),
                  ),
                ),
              ),
              Text(
                  "Tip: Please turn off mobile data and connect to the server WIFI. \nThe server should have the following IP: ${ref.read(commandControllerProvider.notifier).targetServerIP}"),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DefaultText extends StatelessWidget {
  final String text;
  const _DefaultText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}
