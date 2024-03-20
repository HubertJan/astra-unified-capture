import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:network_info_plus/network_info_plus.dart';
part 'network_ip.g.dart';

@riverpod
class NetworkIP extends _$NetworkIP {
  final info = NetworkInfo();

  Future<void> _update() async {
    state = AsyncData(await info.getWifiIP());
    Future.delayed(const Duration(seconds: 5), _update);
  }

  @override
  Future<String?> build() async {
    Timer(const Duration(seconds: 5), () async {
      await _update();
    });

    return await info.getWifiIP();
  }
}
