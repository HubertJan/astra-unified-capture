import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class CommandReceiver {
  final void Function(bool isRecording) onRecordingUpdate;
  final _client = MqttServerClient('192.168.2.1', 'camera-app');

  CommandReceiver({required this.onRecordingUpdate});

  Future<MqttClientConnectionStatus?> establishConnection() async {
    final result = await _client.connect();
    if (result?.state == MqttConnectionState.connected) {
      _client.subscribe("recording", MqttQos.atMostOnce);
      _client.updates?.listen((event) {
        switch (event.last.payload) {
          case MqttPublishMessage payload:
            final message = utf8.decode(payload.payload.message);
            if (message == "ON") {
              onRecordingUpdate(true);
            }
            if (message == "OFF") {
              onRecordingUpdate(false);
            }
            break;
        }
      });
    }
    return result;
  }
}
