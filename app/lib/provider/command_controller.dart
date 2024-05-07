import 'package:app/service_provider/command_receiver_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'command_controller.g.dart';

sealed class ConnectionState {}

class DisconnectedControllerState extends ConnectionState {}

class ConnectingControllerState extends ConnectionState {
  ConnectingControllerState();
}

enum RecordingState {
  recording,
  notRecording,
  unknown;

  @override
  String toString() {
    switch (this) {
      case RecordingState.recording:
        return 'Recording';
      case RecordingState.notRecording:
        return 'Not Recording';
      case RecordingState.unknown:
        return 'Unknown';
    }
  }
}

class ConnectedControllerState extends ConnectionState {
  final RecordingState recordingState;
  ConnectedControllerState(this.recordingState);

  @override
  String toString() {
    return 'Connected: $recordingState';
  }
}

class ControllerState {
  final ConnectionState state;
  final bool isAutoConnecting;

  ControllerState(this.state, this.isAutoConnecting);

  ControllerState copyWith({ConnectionState? state, bool? isAutoConnecting}) {
    return ControllerState(
        state ?? this.state, isAutoConnecting ?? this.isAutoConnecting);
  }
}

@riverpod
class CommandController extends _$CommandController {
  final controllerState = DisconnectedControllerState;

  @override
  ControllerState build() {
    ref.watch(commandReceiverProvider).onAutoReconnect = () {
      state = state.copyWith(
          state: ConnectingControllerState(), isAutoConnecting: true);
    };
    ref.watch(commandReceiverProvider).onDisconnected = () {
      if (ref.read(commandReceiverProvider).isAutoConnecting) {
        state = state.copyWith(state: ConnectingControllerState());
        return;
      }
      state = state.copyWith(state: DisconnectedControllerState());
    };
    ref.watch(commandReceiverProvider).onRecordingUpdate = (isRecording) {
      state = state.copyWith(
          state: ConnectedControllerState(isRecording
              ? RecordingState.recording
              : RecordingState.notRecording));
    };
    ref.watch(commandReceiverProvider).onConnected = () {
      state = state.copyWith(
          state: ConnectedControllerState(RecordingState.unknown));
    };
    return ControllerState(ConnectingControllerState(), false);
  }

  void connect() {
    if (state case DisconnectedControllerState _) {
      state = state.copyWith(state: ConnectingControllerState());
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
      state = state.copyWith(isAutoConnecting: false);
    }
    ref.read(commandReceiverProvider).turnOffAutoConnect();
    ref.read(commandReceiverProvider).disconnect();
  }

  void disconnect() {
    if (state case ConnectedControllerState _) {
      ref.read(commandReceiverProvider).disconnect();
      turnOffAutoConnect();
      state = state.copyWith(state: DisconnectedControllerState());
    }
  }

  String get targetServerIP {
    return ref.read(commandReceiverProvider).currentTargetServerIP;
  }
}
