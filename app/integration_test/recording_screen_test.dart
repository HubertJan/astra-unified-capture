import 'package:app/main.dart';
import 'package:app/provider/network_ip.dart';
import 'package:app/service_provider/network_info_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../test/mocks/mock_mqtt_server_client.dart';
import '../test/mocks/network_info_mock.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(MqttQos.atMostOnce);
  });
  patrolTest("TODO", ($) async {
    final mqttClient = MockMqttServerClient();
    final networkInfo = MockNetworkInfo();
    when(() => networkInfo.getWifiIP()).thenAnswer((invocation) async {
      await Future.delayed(Duration.zero);
      return "192.168.2.10";
    });
    await $.pumpWidgetAndSettle(ProviderScope(
      overrides: [
        networkInfoProvider.overrideWithValue(networkInfo),
      ],
      child: const CameraApp(),
    ));
    while (await $.native.isPermissionDialogVisible()) {
      await $.native.grantPermissionWhenInUse();
    }
    await $.pump();
    mqttClient.mockConnectionStatus(MqttConnectionState.connecting);
    await Future.delayed(Duration.zero);

    expect(find.textContaining("192.168.2.10"), findsOneWidget);
    expect(find.text('Give up looking'), findsOneWidget);
    final button = find.text('Give up looking');
    await $.tap(button);
    await $.pumpAndSettle();
    true;
  });
}
