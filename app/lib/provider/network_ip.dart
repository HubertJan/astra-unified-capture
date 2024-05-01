import 'dart:async';

import 'package:app/service_provider/network_info_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:network_info_plus/network_info_plus.dart';
part 'network_ip.g.dart';

@riverpod
class NetworkIP extends _$NetworkIP {
  Future<void> _update() async {
    state = AsyncData(await ref.read(networkInfoProvider).getWifiIP());
    Future.delayed(const Duration(seconds: 5), _update);
  }

  @override
  Future<String?> build() async {
    Timer(const Duration(seconds: 5), () async {
      await _update();
    });

    return await ref.watch(networkInfoProvider).getWifiIP();
  }
}
