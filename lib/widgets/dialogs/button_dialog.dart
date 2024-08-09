import "package:flutter/material.dart";
import 'package:flutter_movies/widgets/buttons/responsive_button.dart';

class ButtonDialog extends StatefulWidget {
  final String message;
  final List<ResponsiveButton> buttons;

  const ButtonDialog({
    super.key,
    required this.message,
    required this.buttons,
  })  : assert(buttons.length > 0);
  @override
  State<ButtonDialog> createState() => _ButtonDialogState();
}

class _ButtonDialogState extends State<ButtonDialog> {
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
              widget.message,
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 36),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.none,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < widget.buttons.length; ++i)
                      ResponsiveButton(
                        key: widget.buttons[i].key,
                        icon: widget.buttons[i].icon,
                        color: widget.buttons[i].color,
                        tooltip: widget.buttons[i].tooltip,
                        autofocus: widget.buttons[i].autofocus,
                        foregroundColor: widget.buttons[i].foregroundColor,
                        label: widget.buttons[i].label,
                        onPressed: widget.buttons[i].onPressed,
                        borders: i == 0
                            ? {Borders.topLeft, Borders.bottomLeft}
                            : i == widget.buttons.length - 1
                                ? {Borders.topRight, Borders.bottomRight}
                                : {},
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
