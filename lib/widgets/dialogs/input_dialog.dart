import "package:flutter/material.dart";
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_movies/widgets/buttons/pill_button.dart';

class InputDialog extends StatelessWidget {
  final String message;
  final TextField textField;
  final void Function(String? value)? onConfirm;

  const InputDialog({
    super.key,
    required this.message,
    required this.textField,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          transform: const GradientRotation(90 * 3.14 / 180), // turn 90 degrees
          colors: [
            Colors.transparent,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      padding: const EdgeInsets.all(96.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 36),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    child: textField,
                  ),
                ),
                const SizedBox(width: 16),
                PillButton(
                  icon: const Icon(FeatherIcons.check),
                  onPressed: () {
                    onConfirm?.call(textField.controller?.text);
                  },
                  label: "Confirm",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
