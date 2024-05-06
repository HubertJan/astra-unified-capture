import 'dart:async';
import 'dart:convert';

import 'package:mocktail/mocktail.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:typed_data/typed_buffers.dart';

class MockMqttServerClient extends Mock implements MqttServerClient {
  StreamController<MqttReceivedMessage<MqttMessage>>? messageStream;
  var _status = MqttClientConnectionStatus()
    ..state = MqttConnectionState.disconnected;

  @override
  void Function()? onConnected = () {};

  @override
  void Function()? onDisconnected = () {};

  MockMqttServerClient() {
    when(() => subscribe(any(), any())).thenAnswer((_) {
      return Subscription();
    });

    when(() => updates).thenAnswer((invocation) async* {
      if (messageStream
          case StreamController<MqttReceivedMessage<MqttMessage>>
              streamController) {
        await for (final message in streamController.stream) {
          yield [message];
        }
      }
    });
    when(() => connect()).thenAnswer((_) async {
      return _status;
    });

    when(() => connectionStatus).thenAnswer((_) {
      return _status;
    });
  }

  void mockConnectionStatus(MqttConnectionState state) {
    final previousStatus = _status;
    _status = MqttClientConnectionStatus()..state = state;
    switch (_status.state) {
      case (MqttConnectionState.connected)
          when (previousStatus.state != MqttConnectionState.connected):
        messageStream = StreamController<MqttReceivedMessage<MqttMessage>>();
        onConnected?.call();
        break;
      case MqttConnectionState.disconnected
          when (previousStatus.state != MqttConnectionState.disconnected):
        messageStream?.close().then((_) => messageStream = null);
        onDisconnected?.call();
        break;
      default:
        break;
    }
  }

  void mockReceivedMessage(String messageText) {
    messageStream?.add(FakeMqttReceivedMessage.prepareWithMessage(messageText));
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
