import 'package:app/service_provider/shared_preferences_provider.dart';
import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'current_camera_settings.g.dart';

class CameraSettings {
  final int? fps;
  final ResolutionPreset? resolution;

  CameraSettings({required this.fps, required this.resolution});
}

const _fpsKey = "fps";
const _resolutionKey = "resolution";

@Riverpod(keepAlive: true)
class CurrentCameraSettings extends _$CurrentCameraSettings {
  CameraSettings _readCurrentSettings(SharedPreferences pref) {
    final fps = pref.getInt(_fpsKey);
    final resolutionValue = pref.getString(_resolutionKey);

    final resolution = ResolutionPreset.values
        .toList()
        .map((r) => (r, r.toString()))
        .firstWhereOrNull(
          (r) => r.$2 == resolutionValue,
        )
        ?.$1;
    return CameraSettings(fps: fps, resolution: resolution);
  }

  @override
  Future<CameraSettings> build() async {
    final pref = ref.read(sharedPreferencesProvider);
    final settings = _readCurrentSettings(pref);
    return settings;
  }

  Future<void> changeSettings(CameraSettings settings) async {
    final pref = ref.read(sharedPreferencesProvider);
    await pref.setInt(_fpsKey, settings.fps!);
    final res = await pref.setString(
      _resolutionKey,
      settings.resolution.toString(),
    );
    state = AsyncData(await build());
  }
}
