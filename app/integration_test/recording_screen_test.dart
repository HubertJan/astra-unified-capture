import 'dart:io';
import 'dart:typed_data';

import 'package:app/main.dart';
import 'package:app/service_provider/command_receiver_provider.dart';
import 'package:app/service_provider/network_info_provider.dart';
import 'package:app/services/command_receiver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../test/mocks/mock_mqtt_server_client.dart';
import '../test/mocks/network_info_mock.dart';

class TestFile extends Mock implements File {
  @override
  final String path;

  TestFile(this.path);

  @override
  Future<File> copy(String newPath) async {
    return TestFile(newPath);
  }

  @override
  Uri get uri {
    return Uri.file(path);
  }

  @override
  Future<Uint8List> readAsBytes() {
    return Future.value(Uint8List(0));
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(MqttQos.atMostOnce);
  });
  patrolTest("Connect to server, record one video and store it", ($) async {
    final mqttClient = MockMqttServerClient();
    mqttClient.mockConnectionStatus(MqttConnectionState.connecting);
    final networkInfo = MockNetworkInfo();
    when(() => networkInfo.getWifiIP()).thenAnswer((invocation) async {
      await Future.delayed(Duration.zero);
      return "192.168.2.10";
    });
    await $.pumpWidgetAndSettle(ProviderScope(
      overrides: [
        networkInfoProvider.overrideWithValue(networkInfo),
        commandReceiverProvider
            .overrideWithValue(CommandReceiver(client: mqttClient))
      ],
      child: const CameraApp(),
    ));
    while (await $.native.isPermissionDialogVisible()) {
      await $.native.grantPermissionWhenInUse();
    }
    await $.pumpAndSettle();
    expect(find.textContaining("192.168.2.10"), findsOneWidget);
    expect(find.text('Give up looking'), findsOneWidget);
    mqttClient.mockConnectionStatus(MqttConnectionState.connected);
    mqttClient.mockReceivedMessage("ON");
    await $.pumpAndSettle();
    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('Recording: Recording'), findsOneWidget);
    await Future.delayed(const Duration(seconds: 5));
    await $.pumpAndSettle();
    expect(find.text('Recording: Recording'), findsOneWidget);
    await Future.delayed(const Duration(seconds: 5));
    mqttClient.mockReceivedMessage("OFF");
    await $.pumpAndSettle();
    expect(find.text('Recording: Not Recording'), findsOneWidget);
  });

  patrolTest(
      "Connect to server, record one video, lose connection for a bit, reconnect and store the recorded video",
      ($) async {
    var createdFiles = 0;
    await IOOverrides.runZoned(() async {
      final mqttClient = MockMqttServerClient();
      mqttClient.mockConnectionStatus(MqttConnectionState.connecting);
      final networkInfo = MockNetworkInfo();
      when(() => networkInfo.getWifiIP()).thenAnswer((invocation) async {
        await Future.delayed(Duration.zero);
        return "192.168.2.10";
      });
      await $.pumpWidgetAndSettle(ProviderScope(
        overrides: [
          networkInfoProvider.overrideWithValue(networkInfo),
          commandReceiverProvider
              .overrideWithValue(CommandReceiver(client: mqttClient))
        ],
        child: const CameraApp(),
      ));
      while (await $.native.isPermissionDialogVisible()) {
        await $.native.grantPermissionWhenInUse();
      }
      await $.pumpAndSettle();
      mqttClient.mockConnectionStatus(MqttConnectionState.connected);
      mqttClient.mockReceivedMessage("ON");
      await $.pumpAndSettle();
      mqttClient.mockConnectionStatus(MqttConnectionState.disconnected);
      await $.pumpAndSettle();
      expect(find.textContaining("192.168.2.10"), findsOneWidget);
      mqttClient.mockConnectionStatus(MqttConnectionState.connected);
      mqttClient.mockReceivedMessage("ON");
      await $.pumpAndSettle();
      expect(find.text('Recording: Recording'), findsOneWidget);
      mqttClient.mockReceivedMessage("OFF");
      await Future.delayed(const Duration(seconds: 3));
      await $.pumpAndSettle();
      expect(find.text('Recording: Not Recording'), findsOneWidget);
      expect(createdFiles, 2);
      // Assumes that the video is copied to a new file after being recorded
      // => 2 files are created
    }, createFile: (String path) {
      createdFiles++;
      return TestFile(path);
    });
  });
}
