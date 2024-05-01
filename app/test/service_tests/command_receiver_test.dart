import 'dart:convert';

import 'package:app/service_provider/network_info_provider.dart';
import 'package:app/services/command_receiver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:typed_data/typed_buffers.dart';

import '../mocks/mock_mqtt_server_client.dart';
import '../mocks/network_info_mock.dart';
import '../utils/create_container.dart';

class FakeMqttReceivedMessage extends Mock
    implements MqttReceivedMessage<MqttMessage> {}

class FakeMqttPublishPayload extends Mock implements MqttPublishPayload {}

class FakeMqttPublishMessage extends Mock implements MqttPublishMessage {}

void main() {
  setUpAll(() {
    registerFallbackValue(MqttQos.atMostOnce);
  });

  test("Check if NetworkInfoProvider is used", () async {
    final mockClient = MockMqttServerClient();
    final receiver = CommandReceiver(client: mockClient);

    when(() => mockClient.connect()).thenAnswer((_) async {
      final s = MqttClientConnectionStatus();
      s.state = MqttConnectionState.connected;
      return s;
    });

    when(() => mockClient.connectionStatus).thenAnswer((_) {
      final s = MqttClientConnectionStatus();
      s.state = MqttConnectionState.connected;
      return s;
    });

    when(() => mockClient.subscribe(any(), any())).thenAnswer((_) {
      return Subscription();
    });

    bool isRecording = false;
    receiver.onRecordingUpdate = (isRec) {
      isRecording = isRec;
    };
    final msg = FakeMqttReceivedMessage();
    final pubMsg = FakeMqttPublishMessage();
    final payload = FakeMqttPublishPayload();
    when(() => payload.message)
        .thenReturn(Uint8Buffer()..addAll(utf8.encode("ON")));
    when(() => pubMsg.payload).thenReturn(payload);
    when(() => msg.payload).thenReturn(pubMsg);

    when(() => mockClient.updates).thenAnswer((invocation) async* {
      yield [msg];
    });

    await receiver.connect();
    await Future.delayed(Duration.zero);
    expect(isRecording, true);
  });
}
