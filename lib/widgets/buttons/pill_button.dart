import 'package:flutter/material.dart';

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    this.label,
    this.fontSize = 16,
    required this.icon,
    required this.onPressed,
  });

  final String? label;
  final Icon icon;
  final void Function() onPressed;
  final double fontSize;

  final borderSide = const BorderSide(
    width: 1,
    color: Colors.white24,
  );

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      fillColor: Colors.white10,
      elevation: 0,
      hoverElevation: 0,
      focusElevation: 0,
      highlightElevation: 0,
      constraints: const BoxConstraints(),
      shape: label != null
          ? RoundedRectangleBorder(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(360),
                right: Radius.circular(360),
              ),
              side: borderSide,
            )
          : CircleBorder(side: borderSide),
      child: Padding(
        padding: label != null
            ? const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 20,
              )
            : const EdgeInsets.all(14),
        child: Row(
          children: [
            icon,
            if (label != null) ...[
              const SizedBox(width: 8),
              Text(
                label!,
                style: TextStyle(fontSize: fontSize),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
