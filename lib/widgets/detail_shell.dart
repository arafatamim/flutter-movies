import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_movies/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_movies/utils.dart';
import 'package:flutter_movies/widgets/scaffold_with_button.dart';
import 'package:ticker_text/ticker_text.dart';

class DetailShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? description;
  final List<List<Widget>>? meta;
  final Widget? child;
  final Widget? bottomWidget;
  final List<Widget>? actions;
  final ImageUris? imageUris;

  const DetailShell({
    required this.title,
    this.meta,
    this.child,
    this.imageUris,
    this.subtitle,
    this.description,
    this.bottomWidget,
    this.actions,
  });

  bool isWide(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return deviceSize.width > 720;
  }

  @override
  Widget build(BuildContext context) {
    if (isWide(context)) {
      return _buildWideLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  Widget _buildMobileLayout(BuildContext context) {
    return ScaffoldWithButton(
      child: CustomScrollView(
        shrinkWrap: true,
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 250,
            centerTitle: true,
            actions: actions,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(title),
              background: Stack(
                children: <Widget>[
                  _buildBackdropImage(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(100)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  if (meta != null)
                    for (final row in meta!) ...[
                      Row(children: row),
                      const SizedBox(height: 10)
                    ],
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    _buildGenres(),
                    const SizedBox(height: 10),
                  ],
                  if (bottomWidget != null) ...[
                    bottomWidget!,
                    const SizedBox(height: 10),
                  ],
                  if (description != null) ...[
                    ExpansionTile(
                      title: const Text("Synopsis"),
                      maintainState: true,
                      children: [_buildSynopsisText()],
                    ),
                  ],
                  // Expanded(child: child)
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 350),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSynopsisText() {
    return Builder(
      builder: (context) => Text(description.toString(),
          softWrap: true,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
          textAlign: TextAlign.left),
    );
  }

  Align _buildGenres() {
    return Align(
      alignment: Alignment.topLeft,
      child: Builder(builder: (context) {
        return Text(
          subtitle!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade400,
                fontSize: 20,
              ),
        );
      }),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return ScaffoldWithButton(
      child: Container(
        color: Colors.black,
        child: Stack(
          children: <Widget>[
            Align(
                alignment: Alignment.bottomLeft, child: _buildBackdropImage()),
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: _linearGradient(context),
              ),
              padding: const EdgeInsets.all(50.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    flex: 5,
                    child: Column(
                      children: <Widget>[
                        imageUris?.logo != null
                            ? _buildLogo(imageUris!.logo!)
                            : _buildHeadlineText(),
                        const SizedBox(height: 20),
                        if (actions != null) ...[
                          Row(children: actions!),
                          const SizedBox(height: 10)
                        ],
                        if (meta != null)
                          for (final row in meta!) ...[
                            Row(children: row),
                            const SizedBox(height: 10)
                          ],
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildGenres()
                        ],
                        if (description != null) ...[
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Expanded(
                              child: TickerText(
                                scrollDirection: Axis.vertical,
                                child: _buildSynopsisText(),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        if (bottomWidget != null) bottomWidget!,
                      ],
                    ),
                  ),
                  const SizedBox(width: 50, height: 50),
                  Flexible(
                    flex: 5,
                    child: child ?? const SizedBox.shrink(),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeadlineText() => Builder(
        builder: (context) {
          return Align(
            alignment: Alignment.topLeft,
            child: Text(
              title,
              style: Theme.of(context).textTheme.displayLarge,
            ),
          );
        },
      );

  LinearGradient _linearGradient(BuildContext context) {
    return LinearGradient(
      begin: isWide(context) ? Alignment.centerLeft : Alignment.topCenter,
      end: isWide(context) ? Alignment.centerRight : Alignment.bottomCenter,
      colors: [Colors.black.withAlpha(230), Colors.transparent],
    );
  }

  Widget _buildLogo(String logo) {
    if (isSvg(imageUris!.logo!)) {
      return Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 200,
          ),
          child: SvgPicture.network(
            imageUris!.logo!,
            height: 150,
            colorFilter: ColorFilter.mode(Colors.grey.shade50, BlendMode.srcIn),
            alignment: Alignment.topLeft,
            fit: BoxFit.contain,
          ),
        ),
      );
    } else {
      return CachedNetworkImage(
        imageBuilder: (context, imageProvider) {
          return Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 100),
              child: Image(image: imageProvider),
            ),
          );
        },
        imageUrl: imageUris!.logo!,
        fadeInDuration: const Duration(milliseconds: 150),
        errorWidget: (context, url, error) => _buildHeadlineText(),
        fit: BoxFit.scaleDown,
      );
    }
  }

  Widget _buildBackdropImage() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900, maxHeight: 500),
      child: ClipRRect(
        clipBehavior: Clip.antiAlias,
        borderRadius: const BorderRadius.only(
          topRight: Radius.elliptical(300, 360),
        ),
        child: ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
                    colors: [Colors.black, Colors.white],
                    stops: [0, 0.7],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)
                .createShader(bounds);
          },
          child: ShaderMask(
            shaderCallback: (bounds) {
              return const LinearGradient(
                  colors: [Colors.white, Colors.black],
                  stops: [0.6, 0.9]).createShader(bounds);
            },
            child: CachedNetworkImage(
              fadeInDuration: const Duration(milliseconds: 300),
              imageUrl: imageUris?.backdrop ?? "",
              fit: BoxFit.cover,
              alignment: Alignment.bottomLeft,
              // placeholder: (context, url) => _theatreBackdrop,
              errorWidget: (context, url, error) => const SizedBox.shrink(),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
