import 'package:app/service_provider/shared_preferences_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'device_name.g.dart';

const _deviceNameKey = "deviceName";

@riverpod
class DeviceName extends _$DeviceName {
  @override
  Future<String?> build() async {
    return ref.read(sharedPreferencesProvider).getString(_deviceNameKey);
  }

  Future<void> changeName(String deviceName) async {
    // TODO: Might fail
    await ref
        .read(sharedPreferencesProvider)
        .setString(_deviceNameKey, deviceName);
    state = AsyncData(deviceName);
  }
}
