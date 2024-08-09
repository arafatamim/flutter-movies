import 'dart:async';

import 'package:deferred_type/deferred_type.dart';
import 'package:deferred_type_flutter/deferred_type_flutter.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_movies/cubits/favorite_cubit.dart';
import 'package:flutter_movies/cubits/user_cubit.dart';
import 'package:flutter_movies/models/models.dart';
import 'package:flutter_movies/models/user.dart';
import 'package:flutter_movies/services/media.dart';
import 'package:flutter_movies/services/favorites.dart';
import 'package:flutter_movies/services/next_up.dart';
import 'package:flutter_movies/widgets/buttons/pill_button.dart';
import 'package:flutter_movies/widgets/detail_shell.dart';
import 'package:flutter_movies/widgets/episodes.dart';
import 'package:flutter_movies/widgets/error.dart';
import 'package:flutter_movies/widgets/label.dart';
import 'package:flutter_movies/widgets/buttons/responsive_button.dart';
import 'package:flutter_movies/widgets/tabs/gn_tab_bar.dart';
import 'package:flutter_movies/widgets/wide_tile.dart';

class SeriesDetails extends StatefulWidget {
  final Series series;

  const SeriesDetails(
    this.series, {
    super.key,
  });

  @override
  State<SeriesDetails> createState() => _SeriesDetailsState();
}

class _SeriesDetailsState extends State<SeriesDetails> {
  late final User? user;

  @override
  void initState() {
    user = context.read<UserCubit>().state;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DetailShell(
      title: widget.series.title ?? "Untitled Series",
      meta: _buildMeta(),
      subtitle: widget.series.genres?.join(", "),
      description: widget.series.synopsis,
      imageUris: widget.series.imageUris,
      actions: [
        if (user != null)
          FavoriteButton(
            seriesId: widget.series.id,
            userId: user!.id,
          ),
      ],
      bottomWidget: _buildContinueWidget(),
      child: _buildSeasons(),
    );
  }

  Widget _buildSeasons() {
    return FutureBuilder2<List<Season>>(
      future: RepositoryProvider.of<MediaService>(context)
          .getSeasons(widget.series.id),
      builder: (context, result) => result.when(
        inProgress: () => const Center(child: CircularProgressIndicator()),
        idle: () => const SizedBox.shrink(),
        error: (error, _) => Center(child: ErrorMessage(error)),
        success: (seasons) => ResponsiveSeasons(seasons),
      ),
    );
  }

  Widget _buildContinueWidget() {
    if (user != null) {
      return FutureBuilder2<NextUpItem?>(
        // Check if there is next up data
        future: RepositoryProvider.of<NextUpService>(context).getNextUp(
          widget.series.id,
          user!.id,
        ),
        builder: (context, result) => result.maybeWhen(
          success: (item) {
            if (item != null) {
              return FutureBuilder2<List<dynamic>>(
                future: Future.wait([
                  RepositoryProvider.of<MediaService>(context).getSeason(
                    item.seriesId,
                    item.seasonIndex,
                  ),
                  RepositoryProvider.of<MediaService>(context).getEpisode(
                    item.seriesId,
                    item.seasonIndex,
                    item.episodeIndex,
                  ),
                ]),
                builder: (context, result) {
                  return result.maybeWhen<Widget>(
                    success: (data) {
                      final Season season = data[0] as Season;
                      final Episode episode = data[1] as Episode;

                      const title = "Continue watching";
                      final subtitle =
                          "S${season.index.toString().padLeft(2, "0")}E${episode.index.toString().padLeft(2, "0")} - ${episode.name}";

                      void onTap() => showModalBottomSheet(
                            useRootNavigator: true,
                            isDismissible: false,
                            routeSettings: const RouteSettings(name: "episode"),
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context) {
                              return EpisodeSheet(
                                season: season,
                                episode: episode,
                              );
                            },
                          );

                      return WideTile(
                        key: ValueKey(episode.id),
                        title: title,
                        subtitle: subtitle,
                        onTap: onTap,
                      );
                    },
                    inProgress: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  );
                },
              );
            } else {
              return const SizedBox.shrink();
            }
          },
          error: (e, stack) {
            print(e);
            return ErrorMessage(e);
          },
          orElse: () => const SizedBox.shrink(),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  List<List<Widget>> _buildMeta() => [
        <Widget>[
          if (widget.series.year != null)
            MetaLabel(
              widget.series.year.toString() +
                  (widget.series.hasEnded != null
                      ? (widget.series.hasEnded!
                          ? (widget.series.lastAired != null
                              ? (widget.series.lastAired!.year ==
                                      widget.series.year
                                  ? ""
                                  : " - ${widget.series.lastAired!.year}")
                              : " - ENDED")
                          : " - PRESENT")
                      : ""),
            ),
          if (widget.series.criticRatings?.community != null)
            MetaLabel(
              widget.series.criticRatings!.community!.toStringAsFixed(2),
              leading: const Icon(FeatherIcons.star),
            ),
          if (widget.series.averageRuntime != null)
            MetaLabel(
              prettyDuration(
                widget.series.averageRuntime!,
                tersity: DurationTersity.minute,
                abbreviated: true,
                delimiter: " ",
              ),
              leading: const Icon(FeatherIcons.clock),
            ),
          if (widget.series.networks != null &&
              widget.series.networks!.isNotEmpty)
            MetaLabel(widget.series.networks![0].name),
          if (widget.series.ageRating != null)
            MetaLabel(widget.series.ageRating!, hasBackground: true),
        ],
        [
          if (widget.series.cast != null && widget.series.cast!.isNotEmpty)
            Expanded(
              child: MetaLabel(
                widget.series.cast!.take(10).map((i) => i.name).join(" • "),
                title: "Cast",
              ),
            ),
        ]
      ];
}

class ResponsiveSeasons extends StatelessWidget {
  final List<Season> seasons;

  const ResponsiveSeasons(
    this.seasons, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return DefaultTabController(
      length: seasons.length,
      child:
          deviceSize.width > 720 ? _buildWideSeasons() : _buildMobileSeasons(),
    );
  }

  Widget _buildWideSeasons() {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              height: 51,
              child: Align(
                alignment: Alignment.topCenter,
                child: GNTabBar(
                  tabs: [
                    for (final season in seasons)
                      ResponsiveButton(label: season.name)
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: _buildEpisodesWidget(seasons),
        ),
      ],
    );
  }

  Widget _buildMobileSeasons() {
    return Builder(builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 50,
            child: TabBar(
              indicatorColor: Theme.of(context).colorScheme.secondary,
              isScrollable: true,
              tabs: [
                for (final season in seasons) ...[
                  Tab(text: "Season ${season.index}"),
                ]
              ],
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: _buildEpisodesWidget(seasons),
          ),
        ],
      );
    });
  }

  Widget _buildEpisodesWidget(
    List<Season> seasons,
  ) {
    return TabBarView(
      children: <Widget>[for (final season in seasons) Episodes(season)],
    );
  }
}

class FavoriteButtonRepository extends FavoriteRepository {
  final BuildContext context;

  const FavoriteButtonRepository(this.context);

  @override
  Future<bool> checkFavorite(String seriesId, int userId) {
    return context.read<FavoritesService>().checkFavorite(seriesId, userId);
  }

  @override
  Future<void> removeFavorite(String seriesId, int userId) {
    return context.read<FavoritesService>().removeFavorite(seriesId, userId);
  }

  @override
  Future<void> setFavorite(String seriesId, int userId) {
    return context.read<FavoritesService>().saveFavorite(seriesId, userId);
  }
}

class FavoriteButton extends StatelessWidget {
  final String seriesId;
  final int userId;

  const FavoriteButton({
    required this.seriesId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = FavoriteCubit(
      userId: userId,
      seriesId: seriesId,
      favoriteRepository: FavoriteButtonRepository(context),
    );
    return BlocBuilder<UserCubit, User?>(
      builder: (context, user) {
        if (user == null) {
          return const SizedBox.shrink();
        }
        return BlocBuilder<FavoriteCubit, Deferred<bool>>(
          bloc: bloc,
          builder: (context, snapshot) {
            return snapshot.maybeWhen(
              success: (isFavorite) {
                return PillButton(
                  icon: Icon(
                    isFavorite ? FeatherIcons.check : FeatherIcons.plus,
                  ),
                  label: "Add to list",
                  onPressed: () async {
                    if (isFavorite) {
                      await bloc.removeFavorite();
                    } else {
                      await bloc.setFavorite();
                    }
                  },
                );
              },
              orElse: () => const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
