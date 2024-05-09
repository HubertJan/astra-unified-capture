import 'package:flutter/material.dart';

sealed class ValidationResult {}

class Success extends ValidationResult {
  Success();
}

class Invalid extends ValidationResult {
  final String errorMessage;
  Invalid({required this.errorMessage});
}

Future<String?> showTextInputDialog(
  BuildContext context,
  String hintText,
  ValidationResult Function(String) onValidate,
) async {
  final textFieldController = TextEditingController();
  return showDialog(
      context: context,
      builder: (context) {
        return _TextInputAlertDialog(
          textFieldController: textFieldController,
          onValidate: onValidate,
          hintText: hintText,
        );
      });
}

class _TextInputAlertDialog extends StatefulWidget {
  const _TextInputAlertDialog({
    required this.textFieldController,
    required this.onValidate,
    required this.hintText,
  });

  final TextEditingController textFieldController;
  final ValidationResult Function(String) onValidate;
  final String hintText;

  @override
  State<_TextInputAlertDialog> createState() => _TextInputAlertDialogState();
}

class _TextInputAlertDialogState extends State<_TextInputAlertDialog> {
  String? errorText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('TODO'),
      content: TextField(
        controller: widget.textFieldController,
        decoration: InputDecoration(
          hintText: widget.hintText,
          errorText: errorText,
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('OK'),
          onPressed: () {
            switch (widget.onValidate(widget.textFieldController.text)) {
              case Success():
                Navigator.pop(context, widget.textFieldController.text);
                break;
              case Invalid(errorMessage: final message):
                errorText = message;
                setState(() {});
                break;
            }
          },
        ),
      ],
    );
  }
}
