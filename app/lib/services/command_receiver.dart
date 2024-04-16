import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class CommandReceiver {
  void Function(bool isRecording)? onRecordingUpdate;
  final MqttServerClient _client =
      MqttServerClient('192.168.2.1', 'camera-app');
  bool _isAutoConnecting = false;

  bool get isAutoConnecting => _isAutoConnecting;

  set onDisconnected(void Function()? callback) {
    _client.onDisconnected = callback;
  }

  set onConnected(void Function()? callback) {
    _client.onConnected = callback;
  }

  void disconnect() {
    _client.disconnect();
  }

  void turnOnAutoConnect() {
    if (_isAutoConnecting) {
      return;
    }
    _isAutoConnecting = true;
    void tryConnect() {
      if (_isAutoConnecting) {
        connect().then((_) {
          Timer.run(tryConnect);
        });
      }
    }

    Timer.run(tryConnect);
  }

  void turnOffAutoConnect() {
    _isAutoConnecting = false;
  }

  Future<void> connect() async {
    try {
      final result = await _client.connect();
      _client.connectionStatus;
      if (_client.connectionStatus?.state == MqttConnectionState.connected) {
        _isAutoConnecting = false;

        _client.subscribe("recording", MqttQos.atMostOnce);
        _client.updates?.listen((event) {
          switch (event.last.payload) {
            case MqttPublishMessage payload:
              final message = utf8.decode(payload.payload.message);
              if (message == "ON") {
                onRecordingUpdate?.call(true);
              }
              if (message == "OFF") {
                onRecordingUpdate?.call(false);
              }
              break;
          }
        });
      }
    } catch (e) {
      print("Error: $e");
      return;
    }
  }
}
