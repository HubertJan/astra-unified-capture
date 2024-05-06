import 'package:network_info_plus/network_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_info_provider.g.dart';

@Riverpod(keepAlive: true)
NetworkInfo networkInfo(NetworkInfoRef ref) {
  return NetworkInfo();
}
