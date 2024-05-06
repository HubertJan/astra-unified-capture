import 'package:app/provider/network_ip.dart';
import 'package:app/service_provider/command_receiver_provider.dart';
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
  final controllerState = DisconnectedControllerState;

  @override
  ControllerState build() {
    ref.watch(commandReceiverProvider).onAutoReconnect = () {
      state = ConnectingControllerState(isAutoConnecting: true);
    };
    ref.watch(commandReceiverProvider).onDisconnected = () {
      if (ref.read(commandReceiverProvider).isAutoConnecting) {
        state = ConnectingControllerState(isAutoConnecting: true);
        return;
      }
      state = DisconnectedControllerState();
    };
    ref.watch(commandReceiverProvider).onRecordingUpdate = (isRecording) {
      state = ConnectedControllerState(isRecording: isRecording);
    };
    return DisconnectedControllerState();
  }

  void connect() {
    if (state case DisconnectedControllerState _) {
      state = ConnectingControllerState(
          isAutoConnecting: ref.read(commandReceiverProvider).isAutoConnecting);
      ref.read(commandReceiverProvider).connect();
    }
  }

  void turnOnAutoConnect() {
    ref.read(commandReceiverProvider).turnOnAutoConnect();
    connect();
  }

  void turnOffAutoConnect() {
    if (state
        case DisconnectedControllerState _ || ConnectingControllerState _) {
      state = ConnectingControllerState(isAutoConnecting: false);
    }
    ref.read(commandReceiverProvider).turnOffAutoConnect();
    ref.read(commandReceiverProvider).disconnect();
  }

  void disconnect() {
    if (state case ConnectedControllerState _) {
      ref.read(commandReceiverProvider).disconnect();
      turnOffAutoConnect();
      state = DisconnectedControllerState();
    }
  }

  String get targetServerIP {
    return ref.read(commandReceiverProvider).currentTargetServerIP;
  }
}
