import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:ticker_text/ticker_text.dart';

class WideTile extends StatefulWidget {
  const WideTile({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.scrollAxis = Axis.vertical,
    this.onTap,
    this.color,
    this.height = 80,
    this.foregroundColor,
    this.mutedForegroundColor,
  });

  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Axis scrollAxis;
  final void Function()? onTap;
  final WidgetStateProperty<Color>? color;
  final WidgetStateProperty<Color>? foregroundColor;
  final WidgetStateProperty<Color>? mutedForegroundColor;
  final double? height;

  @override
  WideTileState createState() => WideTileState();
}

class WideTileState extends State<WideTile>
    with SingleTickerProviderStateMixin {
  late final FocusNode _node;
  late final TickerTextController _tickerTextController;

  bool get _isFocused => _node.hasFocus;
  WidgetStateProperty<Color> get color =>
      widget.color ??
      WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.focused)
            ? const Color(0xDDeaeaea)
            : const Color(0xDD252525),
      );

  WidgetStateProperty<Color> get foregroundColor =>
      widget.foregroundColor ??
      WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.focused)
            ? Colors.black
            : Colors.white.withAlpha(200),
      );
  WidgetStateProperty<Color> get mutedForegroundColor =>
      widget.mutedForegroundColor ??
      WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.focused)
            ? Colors.grey.shade600
            : Colors.grey.shade500,
      );

  @override
  void initState() {
    _node = FocusNode();
    _node.addListener(_onFocusChange);

    _tickerTextController = TickerTextController();

    super.initState();
  }

  void _onFocusChange() {
    if (_node.hasFocus) {
      _tickerTextController.startScroll();
      setState(() {});
    } else {
      _tickerTextController.stopScroll();
      setState(() {});
    }
  }

  void _onTap() {
    _node.requestFocus();
    if (widget.onTap != null) widget.onTap!();
  }

  @override
  void dispose() {
    _node.dispose();
    _tickerTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    if (deviceSize.width > 720) {
      return _buildWide();
    } else {
      return _buildMobile();
    }
  }

  Widget _buildMobile() {
    return ListTile(
      title: Text(widget.title ?? ""),
      subtitle: Text(widget.subtitle ?? ""),
      leading: widget.leading,
      onTap: widget.onTap,
      tileColor: Colors.white.withAlpha(15),
    );
  }

  Widget _buildWide() {
    final title = Align(
      alignment: Alignment.centerLeft,
      child: Text(
        widget.title ?? "",
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.fade,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w400,
              color: _isFocused
                  ? foregroundColor.resolve({WidgetState.focused})
                  : foregroundColor.resolve({}),
              fontSize: 18,
            ),
      ),
    );
    final subtitle = Align(
      alignment: Alignment.topLeft,
      child: TickerText(
        speed: 16,
        scrollDirection: widget.scrollAxis,
        controller: _tickerTextController,
        startPauseDuration: const Duration(seconds: 2),
        endPauseDuration: const Duration(seconds: 4),
        child: Text(
          widget.subtitle ?? "",
          // maxLines: widget.style.subtitleMaxLines,
          softWrap: true,
          overflow: TextOverflow.clip,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _isFocused
                    ? mutedForegroundColor.resolve({WidgetState.focused})
                    : mutedForegroundColor.resolve({}),
                fontSize: 14,
                height: 1,
              ),
        ),
      ),
    );

    return RawMaterialButton(
      focusNode: _node,
      onPressed: _onTap,
      focusColor: Colors.transparent,
      focusElevation: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color:
                _isFocused ? const Color(0xEEEEEEEE) : const Color(0xEE444444),
          ),
          borderRadius: BorderRadius.circular(16),
          color: _isFocused
              ? color.resolve({WidgetState.focused})
              : color.resolve({}),
        ),
        constraints: const BoxConstraints(),
        height: widget.height,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          // crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            // Horizontal items
            Expanded(
              flex: 2,
              child: Center(
                child: widget.leading != null
                    ? widget.leading!
                    : Icon(
                        FeatherIcons.playCircle,
                        color: _isFocused
                            ? foregroundColor.resolve({WidgetState.focused})
                            : foregroundColor.resolve({}),
                      ),
              ),
            ),
            Expanded(
              flex: 10,
              child: Container(
                padding: const EdgeInsets.only(
                  right: 12,
                  top: 12,
                  bottom: 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Vertical items
                    title,
                    widget.scrollAxis == Axis.horizontal
                        ? subtitle
                        : Expanded(child: subtitle)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
