import 'dart:convert';

import 'package:mocktail/mocktail.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:typed_data/typed_buffers.dart';

class MockMqttServerClient extends Mock implements MqttServerClient {
  void mockConnectionStatus(MqttConnectionState state) {
    when(() => connect()).thenAnswer((_) async {
      final s = MqttClientConnectionStatus();
      s.state = state;
      return s;
    });

    when(() => connectionStatus).thenAnswer((_) {
      final s = MqttClientConnectionStatus();
      s.state = state;
      return s;
    });
  }

  MockMqttServerClient() {
    when(() => subscribe(any(), any())).thenAnswer((_) {
      return Subscription();
    });
  }
}

class FakeMqttReceivedMessage extends Mock
    implements MqttReceivedMessage<MqttMessage> {
  FakeMqttReceivedMessage();

  factory FakeMqttReceivedMessage.prepareWithMessage(String messageContent) {
    final message = FakeMqttReceivedMessage();
    final publishMessage = FakeMqttPublishMessage();
    final payload = FakeMqttPublishPayload();
    when(() => payload.message)
        .thenReturn(Uint8Buffer()..addAll(utf8.encode(messageContent)));
    when(() => publishMessage.payload).thenReturn(payload);
    when(() => message.payload).thenReturn(publishMessage);
    return message;
  }
}

class FakeMqttPublishPayload extends Mock implements MqttPublishPayload {}

class FakeMqttPublishMessage extends Mock implements MqttPublishMessage {}
