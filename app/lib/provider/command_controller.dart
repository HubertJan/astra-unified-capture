import 'package:app/provider/network_ip.dart';
import 'package:app/services/command_receiver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'command_controller.g.dart';

sealed class ControllerState {}

class DisconnectedControllerState extends ControllerState {}

class ConnectingControllerState extends ControllerState {}

class ConnectedControllerState extends ControllerState {
  final bool isRecording;

  ConnectedControllerState({required this.isRecording});
}

@riverpod
class CommandController extends _$CommandController {
  final _receiver = CommandReceiver();
  final controllerState = DisconnectedControllerState;

  @override
  Future<ControllerState> build() async {
    _receiver.onConnected = () {
      state = AsyncData(ConnectedControllerState(isRecording: false));
    };
    _receiver.onDisconnected = () {
      if (_receiver.isAutoConnecting) {
        return;
      }
      state = AsyncData(DisconnectedControllerState());
    };
    _receiver.onRecordingUpdate = (isRecording) {
      state = AsyncData(ConnectedControllerState(isRecording: isRecording));
    };
    ref.listen(networkIPProvider, (previous, next) {
      if (next.value == null) {
        state = AsyncData(DisconnectedControllerState());
      }
    });
    return DisconnectedControllerState();
  }

  void connect() {
    if (state case AsyncData<DisconnectedControllerState> _) {
      state = AsyncData(ConnectingControllerState());
      _receiver.connect();
    }
  }

  void turnOnAutoConnect() {
    state = AsyncData(ConnectingControllerState());
    _receiver.turnOnAutoConnect();
  }

  void turnOffAutoConnect() {
    state = AsyncData(ConnectingControllerState());
    _receiver.turnOffAutoConnect();
  }

  void disconnect() {
    if (state case AsyncData<ConnectedControllerState> _) {
      _receiver.disconnect();
      turnOffAutoConnect();
      state = AsyncData(DisconnectedControllerState());
    }
  }
}
