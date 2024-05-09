import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class CommandReceiver {
  static const String _targetServerIP = '192.168.2.1';
  void Function(String? recordingId)? onRecordingUpdate;
  final MqttServerClient _client;
  bool _isAutoConnecting = false;
  void Function()? onConnected;
  bool get isAutoConnecting => _isAutoConnecting;

  CommandReceiver({MqttServerClient? client})
      : _client = client ?? MqttServerClient(_targetServerIP, 'camera-app') {
    _client.onConnected = () {
      print("Connected to server");
      _client.subscribe("recording", MqttQos.atMostOnce);
      _client.updates?.listen((event) {
        print("Received message: ${event.last.payload}");
        switch (event.last.payload) {
          case MqttPublishMessage payload:
            final message = utf8.decode(payload.payload.message);
            if (message != "OFF") {
              onRecordingUpdate?.call(message);
            }
            if (message == "OFF") {
              onRecordingUpdate?.call(null);
            }
            break;
        }
      });
      onConnected?.call();
    };
  }

  String get currentTargetServerIP {
    // TODO: Might be lying if different client
    return CommandReceiver._targetServerIP;
  }

  set onDisconnected(void Function()? callback) {
    _client.onDisconnected = callback;
  }

  set onAutoReconnect(void Function()? callback) {
    _client.onAutoReconnect = callback;
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
      if (_client.connectionStatus?.state == MqttConnectionState.connected) {
        return;
      }
      await _client.connect();
    } catch (e) {
      print("Error: $e");
      return;
    }
  }
}
