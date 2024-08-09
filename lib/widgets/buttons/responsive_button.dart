import 'package:flutter/material.dart';

enum Borders { topLeft, topRight, bottomLeft, bottomRight, all }

class IndicatorPainter extends CustomPainter {
  final Color color;

  const IndicatorPainter({
    this.color = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    // canvas.drawCircle(const Offset(0, 25), 6, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-32, 21, 64, 5),
        const Radius.circular(6)
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(IndicatorPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(IndicatorPainter oldDelegate) => false;
}

class ResponsiveButton extends StatefulWidget {
  final WidgetStateProperty<Color>? color;
  final WidgetStateProperty<Color>? foregroundColor;
  final Set<Borders> borders;
  final double? borderRadius;
  final String? label;
  final String? tooltip;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool active;
  final bool autofocus;

  const ResponsiveButton({
    super.key,
    this.color,
    this.foregroundColor,
    this.tooltip,
    this.borders = const {Borders.all},
    this.borderRadius,
    this.label,
    this.onPressed,
    this.icon,
    this.active = false,
    this.autofocus = false,
  });

  @override
  ResponsiveButtonState createState() => ResponsiveButtonState();
}

class ResponsiveButtonState<T extends ResponsiveButton>
    extends State<ResponsiveButton> with TickerProviderStateMixin {
  WidgetStateProperty<Color> get color =>
      widget.color ??
      WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.focused)
            ? Colors.white
            : Colors.black.withAlpha(150),
      );
  WidgetStateProperty<Color> get foregroundColor =>
      widget.foregroundColor ??
      WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.focused)
            ? Colors.black
            : Colors.white.withAlpha(200),
      );

  late Color primaryColor;
  late Color textColor;

  final FocusNode _focusNode = FocusNode();
  late final _borderRadius = widget.borderRadius ?? 6.0;

  @override
  void initState() {
    _focusNode.addListener(_onFocusChange);
    primaryColor = color.resolve({});
    textColor = foregroundColor.resolve({});
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() {
        primaryColor = color.resolve({WidgetState.focused});
        textColor = foregroundColor.resolve({WidgetState.focused});
      });
    } else {
      setState(() {
        primaryColor = color.resolve({});
        textColor = foregroundColor.resolve({});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    if (deviceSize.width > 720) {
      return _buildTvButton();
    } else {
      return _buildMobileButton();
    }
  }

  Widget _buildTvButton() {
    return Stack(
      alignment: Alignment.center,
      children: [
        RawMaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          constraints: const BoxConstraints.tightFor(),
          autofocus: widget.autofocus,
          focusNode: _focusNode,
          onPressed: widget.onPressed,
          splashColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: widget.borders.contains(Borders.all)
                  ? BorderRadius.circular(_borderRadius)
                  : BorderRadius.only(
                      topLeft: widget.borders.contains(Borders.topLeft)
                          ? Radius.circular(_borderRadius)
                          : Radius.zero,
                      topRight: widget.borders.contains(Borders.topRight)
                          ? Radius.circular(_borderRadius)
                          : Radius.zero,
                      bottomLeft: widget.borders.contains(Borders.bottomLeft)
                          ? Radius.circular(_borderRadius)
                          : Radius.zero,
                      bottomRight: widget.borders.contains(Borders.bottomRight)
                          ? Radius.circular(_borderRadius)
                          : Radius.zero,
                    ),
              color: primaryColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon!,
                    color: textColor,
                    size: 14,
                  ),
                ],
                if (widget.label != null) ...[
                  const SizedBox(width: 6),
                  Center(
                    child: Text(
                      widget.label!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.apply(color: textColor),
                    ),
                  )
                ]
              ],
            ),
          ),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: widget.active ? 1 : 0,
          child: CustomPaint(
            painter: IndicatorPainter(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileButton() {
    if (widget.icon != null && widget.label == null) {
      return IconButton(
        onPressed: widget.onPressed,
        icon: Icon(widget.icon!),
        tooltip: widget.tooltip ?? widget.label,
      );
    } else {
      return TextButton(
        onPressed: widget.onPressed,
        child: Text(
          widget.label!,
        ),
      );
    }
  }
}
