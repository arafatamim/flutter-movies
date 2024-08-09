import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:ticker_text/ticker_text.dart';

class Cover extends StatefulWidget {
  final String? image;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final WidgetStateProperty<Color>? color;
  final WidgetStateProperty<Color>? foregroundColor;
  final WidgetStateProperty<Color>? mutedForegroundColor;
  final Function onTap;
  final Function? onFocus;

  const Cover({
    super.key,
    this.image,
    required this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.foregroundColor,
    this.mutedForegroundColor,
    required this.onTap,
    this.onFocus,
  });

  @override
  CoverState createState() => CoverState();
}

class CoverListView extends StatelessWidget {
  final List<Cover> covers;
  final bool showIcon;
  final bool separator;
  final ScrollController? controller;

  const CoverListView(
    this.covers, {
    this.showIcon = false,
    this.separator = true,
    this.controller,
  });
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.separated(
        controller: controller,
        scrollDirection: Axis.horizontal,
        addAutomaticKeepAlives: true,
        itemCount: covers.length,
        shrinkWrap: true,
        separatorBuilder: (context, index) =>
            SizedBox(width: separator ? 12 : 0),
        itemBuilder: (BuildContext context, int index) {
          Cover item = covers[index];
          return Cover(
            title: item.title,
            subtitle: item.subtitle,
            image: item.image,
            icon: showIcon ? item.icon : null,
            color: WidgetStateColor.resolveWith(
              (states) => states.contains(WidgetState.focused)
                  ? Colors.white
                  : Colors.transparent,
            ),
            foregroundColor: WidgetStateColor.resolveWith(
              (states) => states.contains(WidgetState.focused)
                  ? Colors.white
                  : Colors.grey.shade300,
            ),
            mutedForegroundColor: WidgetStateColor.resolveWith(
              (states) => states.contains(WidgetState.focused)
                  ? Colors.grey.shade300
                  : Colors.grey.shade400,
            ),
            onTap: item.onTap,
          );
        },
      ),
    );
  }
}

class CoverState extends State<Cover> with SingleTickerProviderStateMixin {
  late bool _isFocused;
  late FocusNode _node;
  late AnimationController _animationController;
  late TickerTextController _autoScrollController;
  late ColorTween _colorTween;
  late Animation<Color?> _colorTweenAnimation;
  late Tween<double> _borderWidthTween;
  late Animation<double> _borderWidthAnimation;

  WidgetStateProperty<Color> get color =>
      widget.color ?? WidgetStateProperty.all(Colors.white);
  WidgetStateProperty<Color> get foregroundColor =>
      widget.foregroundColor ?? WidgetStateProperty.all(Colors.black);
  WidgetStateProperty<Color> get mutedForegroundColor =>
      widget.mutedForegroundColor ?? WidgetStateProperty.all(Colors.grey);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      key: ValueKey(
        widget.key,
      ), // Necessary otherwise image doesn't change
      onPressed: _onTap,
      focusNode: _node,
      focusColor: Colors.transparent,
      focusElevation: 0,
      child: buildCover(context),
    );
  }

  Widget buildCover(BuildContext context) {
    var posterImage = PosterImage(
      title: widget.title,
      subtitle: widget.subtitle,
      image: widget.image,
      icon: Icon(widget.icon),
    );
    return GestureDetector(
      onTap: _onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Stack(
          children: [
            AnimatedBuilder(
                animation: _borderWidthAnimation,
                builder: (context, child) {
                  return DecoratedBox(
                    position: DecorationPosition.foreground,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: _borderWidthAnimation.value,
                        color: _borderWidthAnimation.value == 0
                            ? Colors.transparent
                            : Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black],
                        begin: Alignment(0, _isFocused ? 0.4 : 0.6),
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: AnimatedBuilder(
                        animation: _colorTweenAnimation,
                        child: posterImage,
                        builder: (context, child) {
                          return ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              /* _isFocused ? Colors.white12 : Colors.transparent, */
                              _colorTweenAnimation.value ?? Colors.transparent,
                              BlendMode.lighten,
                            ),
                            child: child,
                          );
                        }),
                  );
                }),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: _isFocused ? 150 : 180,
                  ),
                  child: TickerText(
                    scrollDirection: Axis.horizontal,
                    speed: 20,
                    startPauseDuration: const Duration(milliseconds: 500),
                    endPauseDuration: const Duration(seconds: 2),
                    controller: _autoScrollController,
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
              bottom: _isFocused ? 28 : 8,
            ),
            if (widget.subtitle != null)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10.0),
                  child: Text(
                    widget.subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                bottom: _isFocused ? 10 : -20,
              ),
            if (widget.icon != null)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                child: Icon(widget.icon, color: Colors.white70),
                right: _isFocused ?  12 : -30,
                bottom: 12,
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _node.dispose();
    _autoScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _isFocused = false;
    _node = FocusNode();
    _node.addListener(_onFocusChange);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _colorTween = ColorTween(
      begin: Colors.transparent,
      end: Colors.white10,
    );
    _colorTweenAnimation = _colorTween.animate(_animationController);

    _borderWidthTween = Tween<double>(begin: 0, end: 2);
    _borderWidthAnimation = _borderWidthTween.animate(_animationController);

    _autoScrollController = TickerTextController();

    super.initState();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _node.hasFocus;
    });

    if (_node.hasFocus) {
      _autoScrollController.startScroll();
      _animationController.forward();
      if (widget.onFocus != null) {
        widget.onFocus!();
      }
    } else {
      _autoScrollController.stopScroll();
      _animationController.reverse();
    }
  }

  void _onTap() {
    _node.requestFocus();
    widget.onTap();
  }
}

class PosterImage extends StatelessWidget {
  final String? image;
  final Icon? icon;
  final String title;
  final String? subtitle;

  const PosterImage({
    super.key,
    this.image,
    this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      return CachedNetworkImage(
        key: Key(image!),
        fadeInDuration: const Duration(milliseconds: 300),
        placeholder: (context, uri) => AspectRatio(
          aspectRatio: 0.6,
          child: Icon(
            icon != null ? icon!.icon : FeatherIcons.video,
            color: Colors.grey,
          ),
        ),
        imageUrl: image!,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        width: 250,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            focal: const Alignment(0, 0),
            focalRadius: 1,
            radius: 0.5,
            center: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
                [title, subtitle ?? ""].join(" ").toUpperCase(),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodyLarge?.apply(
                      color: Colors.grey.shade400,
                      fontSizeFactor: 1.3,
                      heightFactor: 1
                    ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
