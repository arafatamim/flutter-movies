import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_movies/widgets/buttons/animated_icon_button.dart';
import 'package:flutter_movies/widgets/label.dart';
import 'package:flutter_movies/utils.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ticker_text/ticker_text.dart';

class Spotlight extends StatefulWidget {
  final String? id;
  final String? logo;
  final String? backdrop;
  final String title;
  final int? year;
  final String? synopsis;
  final num? rating;
  final Duration? runtime;
  final String? ageRating;
  final bool? hasEnded;
  final DateTime? endDate;
  final List<String>? genres;
  final VoidCallback? onTapDetails;

  const Spotlight({
    this.backdrop,
    this.genres,
    this.id,
    this.logo,
    this.synopsis,
    required this.title,
    required this.onTapDetails,
    this.year,
    this.rating,
    this.runtime,
    this.ageRating,
    this.hasEnded,
    this.endDate,
  });

  @override
  State<Spotlight> createState() => _SpotlightState();
}

class _SpotlightState extends State<Spotlight> {
  late final FocusNode _node;

  @override
  void initState() {
    _node = FocusNode();
    _node.addListener(_nodeListener);

    super.initState();
  }

  void _nodeListener() {
    if (_node.hasFocus) {
      Scrollable.ensureVisible(
        context,
        alignment: 1,
      );
    }
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final isWide = deviceSize.width > 720;

    return Focus(
      focusNode: _node,
      canRequestFocus: false,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.transparent],
              ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
            },
            blendMode: BlendMode.dstIn,
            child: ClipRRect(
              borderRadius:
                  isWide ? BorderRadius.circular(8) : BorderRadius.circular(0),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withAlpha(70),
                  BlendMode.darken,
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.backdrop!,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0.0, -0.5),
                ),
              ),
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.logo != null
                        ? (isSvg(widget.logo!)
                            ? ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 150,
                                  maxWidth: 500,
                                ),
                                child: SvgPicture.network(
                                  widget.logo!,
                                  colorFilter: ColorFilter.mode(
                                    Colors.grey.shade50,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              )
                            : CachedNetworkImage(
                                imageBuilder: (context, imageProvider) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        maxHeight: 150,
                                      ),
                                      child: Image(
                                        image: imageProvider,
                                      ),
                                    ),
                                  );
                                },
                                imageUrl: widget.logo!,
                                fadeInDuration:
                                    const Duration(milliseconds: 150),
                                errorWidget: (context, url, error) =>
                                    headlineText,
                                fit: BoxFit.scaleDown,
                              ))
                        : Text(
                            widget.title,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                    const SizedBox(height: 20),
                    if (deviceSize.width > 720) ...[
                      Row(
                        children: _buildMeta(
                          ageRating: widget.ageRating,
                          endDate: widget.endDate,
                          hasEnded: widget.hasEnded,
                          rating: widget.rating,
                          year: widget.year,
                          genres: widget.genres,
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                    if (widget.synopsis != null)
                      Flexible(
                        flex: 1,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                              maxHeight: 250, maxWidth: 550),
                          child: TickerText(
                            speed: 12,
                            child: Text(
                              widget.synopsis!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.grey.shade300,
                                    height: 1.1,
                                  ),
                            ),
                            scrollDirection: Axis.vertical,
                          ),
                        ),
                      ),
                    const SizedBox(height: 15),
                    AnimatedIconButton(
                      icon: const Icon(FeatherIcons.play),
                      label: const Text(
                        "Watch",
                        style: TextStyle(fontSize: 24),
                      ),
                      onPressed: widget.onTapDetails,
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Widget get headlineText => Align(
        alignment: Alignment.topLeft,
        child: Text(
          widget.title,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      );

  List<Widget> _buildMeta({
    num? rating,
    Duration? runtime,
    String? ageRating,
    int? year,
    bool? hasEnded,
    DateTime? endDate,
    List<String>? genres,
  }) {
    return <Widget>[
      if (genres != null) MetaLabel(genres.join(", ")),
      if (rating != null)
        MetaLabel(
          rating.toStringAsFixed(2),
          leading: const Icon(FeatherIcons.star),
        ),
      if (runtime != null)
        MetaLabel(
          prettyDuration(
            runtime,
            tersity: DurationTersity.minute,
            abbreviated: true,
            delimiter: " ",
          ),
          leading: const Icon(FeatherIcons.clock),
        ),
      if (ageRating != null) MetaLabel(ageRating, hasBackground: true),
      if (year != null)
        MetaLabel(
          year.toString() +
              (hasEnded != null
                  ? (hasEnded
                      ? (endDate != null
                          ? (endDate.year == year ? "" : " - ${endDate.year}")
                          : " - ENDED")
                      : " - PRESENT")
                  : ""),
        ),
    ];
  }
}
