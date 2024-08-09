import 'package:flutter/material.dart';
import 'package:flutter_movies/widgets/buttons/responsive_button.dart';
import 'package:flutter_movies/widgets/dialogs/button_dialog.dart';
import 'package:flutter_movies/widgets/dialogs/input_dialog.dart';

Future<dynamic> showAdaptiveAlertDialog(
  BuildContext context, {
  required List<ResponsiveButton> buttons,
  required String title,
}) {
  final size = MediaQuery.of(context).size;
  if (size.width > 720) {
    return showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return ButtonDialog(
          message: title,
          buttons: buttons,
        );
      },
    );
  } else {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          actions: [
            for (final button in buttons)
              TextButton.icon(
                key: button.key,
                onPressed: button.onPressed,
                icon: Icon(button.icon),
                label: button.label != null
                    ? Text(button.label!)
                    : const SizedBox.shrink(),
              )
          ],
        );
      },
    );
  }
}

Future<dynamic> showAdaptiveInputDialog(
  BuildContext context, {
  required TextField textField,
  required String title,
  void Function(String? value)? onConfirm,
}) {
  final size = MediaQuery.of(context).size;
  if (size.width > 720) {
    return showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return InputDialog(
          message: title,
          textField: textField,
          onConfirm: onConfirm,
        );
      },
    );
  } else {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                onConfirm?.call(textField.controller?.text);
              },
              child: const Text("Confirm"),
            ),
          ],
          content: textField,
        );
      },
    );
  }
}
