import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_movies/models/models.dart';

class SeasonTab extends StatefulWidget {
  final Season season;
  final WidgetStateProperty<Color>? color;
  final WidgetStateProperty<Color>? foregroundColor;
  final bool active;
  final Function? onTap;
  final Function? onFocus;

  const SeasonTab({
    super.key,
    required this.season,
    this.color,
    this.foregroundColor,
    this.active = false,
    this.onTap,
    this.onFocus,
  });

  @override
  SeasonTabState createState() => SeasonTabState();
}

class SeasonTabState extends State<SeasonTab>
    with SingleTickerProviderStateMixin {
  late FocusNode _node;
  late AnimationController _controller;
  late Animation<double> _animation;

  bool get focused => _node.hasFocus;
  WidgetStateProperty<Color> get primaryColor =>
      widget.color ?? WidgetStateProperty.all(Colors.white);
  WidgetStateProperty<Color> get foregroundColor =>
      widget.foregroundColor ?? WidgetStateProperty.all(Colors.black);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      key: ValueKey(widget.season.id),
      onPressed: _onTap,
      focusNode: _node,
      focusColor: Colors.transparent,
      focusElevation: 0,
      child: buildCover(context),
    );

    // return Focus(
    //     focusNode: _node,
    //     onKey: _onKey,
    //     child: Builder(
    //       builder: (context) {
    //         return buildCover(context);
    //       }
    //     ),
    // );
  }

  Widget buildCover(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: (focused || widget.active)
                ? primaryColor.resolve({WidgetState.focused})
                : primaryColor.resolve({}),
          ),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 160,
                width: 120,
                child: Container(
                  child: buildPosterImage(context, widget.season.imageUris),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 15,
                        offset: const Offset(5, 5),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Text(
                  widget.season.name,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: (focused || widget.active)
                            ? foregroundColor.resolve({WidgetState.focused})
                            : foregroundColor.resolve({}),
                        fontSize: 20,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPosterImage(BuildContext context, ImageUris? imageUris) {
    return Container(
      child: (imageUris?.primary != null)
          ? CachedNetworkImage(
              key: Key(imageUris!.primary!),
              fadeInDuration: const Duration(milliseconds: 150),
              placeholder: (context, url) => renderPlaceholderBox(),
              errorWidget: (context, url, err) => renderPlaceholderBox(),
              imageUrl: imageUris.primary!,
              fit: BoxFit.cover,
            )
          : renderPlaceholderBox(),
    );
  }

  Widget renderPlaceholderBox() {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.season.index.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge?.apply(
                    color: Colors.grey.shade400,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _node.dispose();
    super.dispose();
  }

  // void _openDetails() {
  //   Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(widget.item)));
  // }

  // bool _onKey(FocusNode node, RawKeyEvent event) {
  //   if(event is RawKeyDownEvent) {
  //     if(event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
  //       _onTap();
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   }
  //   return false;
  // }

  @override
  void initState() {
    _node = FocusNode();
    _node.addListener(_onFocusChange);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.9,
      upperBound: 1,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    super.initState();
  }

  void _onFocusChange() {
    // Scrollable.ensureVisible(
    //   _node.context!,
    //   alignment: 1.0,
    //   alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    // );

    if (_node.hasFocus) {
      _controller.forward();
      setState(() {});
      if (widget.onFocus != null) {
        widget.onFocus!();
      }
    } else {
      _controller.reverse();
      setState(() {});
    }
  }

  void _onTap() {
    _node.requestFocus();
    widget.onTap?.call();
  }
}
