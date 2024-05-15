import 'package:app/provider/current_camera_settings.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

Future<CameraSettings?> showCameraSettingsDialog(
  BuildContext context,
  CameraSettings? currentSettings,
) async {
  ResolutionPreset selectedResolution =
      currentSettings?.resolution ?? ResolutionPreset.high;
  int selectedFramerate = currentSettings?.fps ?? 30;

  return showDialog<CameraSettings>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Camera Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<ResolutionPreset>(
              value: selectedResolution,
              items: const [
                DropdownMenuItem<ResolutionPreset>(
                  value: ResolutionPreset.max,
                  child: Text('Highest Supported'),
                ),
                DropdownMenuItem<ResolutionPreset>(
                  value: ResolutionPreset.ultraHigh,
                  child: Text('2160p'),
                ),
                DropdownMenuItem<ResolutionPreset>(
                  value: ResolutionPreset.veryHigh,
                  child: Text('1080p'),
                ),
                DropdownMenuItem<ResolutionPreset>(
                  value: ResolutionPreset.high,
                  child: Text('720p'),
                ),
                DropdownMenuItem<ResolutionPreset>(
                  value: ResolutionPreset.medium,
                  child: Text('480p'),
                ),
                DropdownMenuItem<ResolutionPreset>(
                  value: ResolutionPreset.low,
                  child: Text('240p'),
                ),
              ],
              onChanged: (value) {
                selectedResolution = value!;
              },
              decoration: const InputDecoration(
                labelText: 'Resolution',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: selectedFramerate,
              items: const [
                DropdownMenuItem<int>(
                  value: 24,
                  child: Text('24 fps'),
                ),
                DropdownMenuItem<int>(
                  value: 30,
                  child: Text('30 fps'),
                ),
                DropdownMenuItem<int>(
                  value: 60,
                  child: Text('60 fps'),
                ),
                DropdownMenuItem<int>(
                  value: 120,
                  child: Text('120 fps'),
                ),
              ],
              onChanged: (value) {
                selectedFramerate = value!;
              },
              decoration: const InputDecoration(
                labelText: 'Framerate',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(CameraSettings(
                resolution: selectedResolution,
                fps: selectedFramerate,
              ));
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}
