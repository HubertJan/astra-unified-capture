import 'dart:async';
import 'package:app/service_provider/network_info_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_ip.g.dart';

@Riverpod(keepAlive: true)
class NetworkIP extends _$NetworkIP {
  var _isDisposed = false;
  Future<void> _update() async {
    final ip = await ref.read(networkInfoProvider).getWifiIP();
    if (_isDisposed) {
      return;
    }
    state = AsyncData(ip);
    Future.delayed(const Duration(seconds: 5), _update);
  }

  @override
  Future<String?> build() async {
    final timer = Timer(const Duration(seconds: 5), () async {
      await _update();
    });
    ref.onDispose(() {
      _isDisposed = true;
      timer.cancel();
    });
    return await ref.watch(networkInfoProvider).getWifiIP();
  }
}
