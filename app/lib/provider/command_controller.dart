import 'package:app/provider/network_ip.dart';
import 'package:app/services/command_receiver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'command_controller.g.dart';

sealed class ControllerState {}

class DisconnectedControllerState extends ControllerState {}

class ConnectingControllerState extends ControllerState {
  final bool isAutoConnecting;

  ConnectingControllerState({required this.isAutoConnecting});
}

class ConnectedControllerState extends ControllerState {
  final bool isRecording;

  ConnectedControllerState({required this.isRecording});
}

@riverpod
class CommandController extends _$CommandController {
  final _receiver = CommandReceiver();
  final controllerState = DisconnectedControllerState;

  @override
  ControllerState build() {
    _receiver.onConnected = () {
      state = ConnectedControllerState(isRecording: false);
    };
    _receiver.onAutoReconnect = () {
      state = ConnectingControllerState(isAutoConnecting: true);
    };
    _receiver.onDisconnected = () {
      if (_receiver.isAutoConnecting) {
        state = ConnectingControllerState(isAutoConnecting: true);
        return;
      }
      state = DisconnectedControllerState();
    };
    _receiver.onRecordingUpdate = (isRecording) {
      state = ConnectedControllerState(isRecording: isRecording);
    };
    return DisconnectedControllerState();
  }

  void connect() {
    if (state case DisconnectedControllerState _) {
      state = ConnectingControllerState(
          isAutoConnecting: _receiver.isAutoConnecting);
      _receiver.connect();
    }
  }

  void turnOnAutoConnect() {
    _receiver.turnOnAutoConnect();
    connect();
  }

  void turnOffAutoConnect() {
    if (state
        case DisconnectedControllerState _ || ConnectingControllerState _) {
      state = ConnectingControllerState(isAutoConnecting: true);
    }
    _receiver.turnOffAutoConnect();
  }

  void disconnect() {
    if (state case ConnectedControllerState _) {
      _receiver.disconnect();
      turnOffAutoConnect();
      state = DisconnectedControllerState();
    }
  }
}
