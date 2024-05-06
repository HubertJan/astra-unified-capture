import 'package:app/services/command_receiver.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'command_receiver_provider.g.dart';

@Riverpod(keepAlive: true)
CommandReceiver commandReceiver(CommandReceiverRef ref) {
  return CommandReceiver();
}
