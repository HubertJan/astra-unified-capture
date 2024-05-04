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
    receiver.onRecordingUpdate = (isRec) {
      isRecording = isRec;
    };

    when(() => mockClient.updates).thenAnswer((invocation) async* {
      yield [FakeMqttReceivedMessage.prepareWithMessage("ON")];
    });

    await receiver.connect();
    await Future.delayed(Duration.zero);
    expect(isRecording, true);
  });

  test("Check if onRecordingUpdate is triggered with correct values", () async {
    final mockClient = MockMqttServerClient();
    final receiver = CommandReceiver(client: mockClient);
    mockClient.mockConnectionStatus(MqttConnectionState.connected);

    bool isRecording = false;
    receiver.onRecordingUpdate = (isRec) {
      isRecording = isRec;
    };

    final messageStream = StreamController();
    when(() => mockClient.updates).thenAnswer((invocation) async* {
      await for (final message in messageStream.stream) {
        yield [message];
      }
    });

    await receiver.connect();
    messageStream.add(FakeMqttReceivedMessage.prepareWithMessage("ON"));
    await Future.delayed(Duration.zero);
    expect(isRecording, true);
    messageStream.add(FakeMqttReceivedMessage.prepareWithMessage("OFF"));
    await Future.delayed(Duration.zero);
    expect(isRecording, false);
  });
}
