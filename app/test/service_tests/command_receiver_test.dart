import 'dart:async';

import 'package:app/services/command_receiver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../mocks/mock_mqtt_server_client.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(MqttQos.atMostOnce);
  });

  test("Check if NetworkInfoProvider is used", () async {
    final mockClient = MockMqttServerClient();
    final receiver = CommandReceiver(client: mockClient);

    mockClient.mockConnectionStatus(MqttConnectionState.connected);

    bool isRecording = false;
    receiver.onRecordingUpdate = (recordingId) {
      isRecording = recordingId != null;
    };

    mockClient.mockReceivedMessage("ON");

    await receiver.connect();
    await Future.delayed(Duration.zero);

    expect(isRecording, true);
  });

  test("Check if onRecordingUpdate is triggered with correct values", () async {
    final mockClient = MockMqttServerClient();
    final receiver = CommandReceiver(client: mockClient);
    mockClient.mockConnectionStatus(MqttConnectionState.connected);

    bool isRecording = false;
    receiver.onRecordingUpdate = (recordingId) {
      isRecording = recordingId != null;
    };

    await receiver.connect();
    mockClient.mockStartRecording();
    await Future.delayed(Duration.zero);
    expect(isRecording, true);
    mockClient.mockStopRecording();
    await Future.delayed(Duration.zero);
    expect(isRecording, false);
  });
}
