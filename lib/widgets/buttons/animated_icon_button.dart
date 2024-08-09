import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedIconButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final Widget label;
  final Duration duration;
  final bool autofocus;
  const AnimatedIconButton({
    this.onPressed,
    required this.icon,
    required this.label,
    this.duration = const Duration(milliseconds: 150),
    this.autofocus = false,
  });
  @override
  AnimatedIconButtonState createState() => AnimatedIconButtonState();
}

class AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late FocusNode _node;

  final _borderRadius = BorderRadius.circular(150);

  bool get expanded => _node.hasFocus;

  @override
  void initState() {
    _node = FocusNode();
    _node.addListener(_onFocusChange);
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(() => setState(() {}));

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _node.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_node.hasFocus) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final curveValue = _controller.drive(CurveTween(curve: Curves.ease)).value;

    if (expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        autofocus: widget.autofocus,
        focusNode: _node,
        borderRadius: _borderRadius,
        onTap: widget.onPressed,
        child: AnimatedContainer(
          constraints: expanded
              ? BoxConstraints.loose(const Size(200, 58))
              : const BoxConstraints.tightFor(height: 58, width: 58),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          duration: widget.duration,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.white.withAlpha(50)),
            borderRadius: (_borderRadius),
          ),
          child: FittedBox(
            fit: BoxFit.fitHeight,
            child: Builder(
              builder: (_) {
                return Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          child: Align(
                            alignment: Alignment.centerRight,
                            widthFactor: curveValue,
                            child: Opacity(
                              opacity: expanded
                                  ? _controller
                                      .drive(CurveTween(curve: Curves.easeIn))
                                      .value
                                  : pow(_controller.value, 13) as double,
                              child: widget.label,
                            ),
                          ),
                        ),
                        if (expanded) const SizedBox(width: 8),
                        widget.icon,
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
