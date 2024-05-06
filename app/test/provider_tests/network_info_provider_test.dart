import 'package:app/service_provider/network_info_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks/network_info_mock.dart';
import '../utils/create_container.dart';

void main() {
  test("Check if NetworkInfoProvider is used", () async {
    final mockNetworkInfo = MockNetworkInfo();
    final container = createContainer(
      overrides: [networkInfoProvider.overrideWith((ref) => mockNetworkInfo)],
    );

    when(() => mockNetworkInfo.getWifiIP())
        .thenAnswer((_) async => "192.168.0.1");

    expect(
      await container.read(networkInfoProvider).getWifiIP(),
      equals("192.168.0.1"),
    );
  });
}
