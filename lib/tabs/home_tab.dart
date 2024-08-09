import 'dart:math';

import 'package:deferred_type_flutter/deferred_type_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_movies/cubits/user_cubit.dart';
import 'package:flutter_movies/models/detail_arguments.dart';
import 'package:flutter_movies/models/result_endpoint.dart';
import 'package:flutter_movies/models/section.dart';
import 'package:flutter_movies/models/user.dart';
import 'package:flutter_movies/services/next_up.dart';
import 'package:flutter_movies/widgets/episodes.dart';
import 'package:flutter_movies/widgets/slim_cover.dart';
import 'package:flutter_movies/models/models.dart';
import 'package:flutter_movies/services/media.dart';
import 'package:flutter_movies/widgets/cover.dart';
import 'package:flutter_movies/widgets/error.dart';
import 'package:flutter_movies/widgets/shimmers.dart';
import 'package:flutter_movies/widgets/spotlight.dart';

const seriesList = [
  "1972"
];

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  HomeTabState createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<UserCubit, User?>(
      builder: (context, user) {
        return SingleChildScrollView(
          clipBehavior: Clip.none,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: _buildSpotlight(context),
              ),
              if (user != null) ...[
                const SizedBox(height: 40),
                SectionBuilder(
                  onChange: () => setState(() {}),
                  section: Section.nextUp(
                    fetcher: RepositoryProvider.of<NextUpService>(context)
                        .getAll(user.id)
                        .then((l) => l.take(3).toList()),
                    title: "Continue watching for ${user.username}",
                  ),
                ),
              ],
              const SizedBox(height: 40),
              SectionBuilder(
                section: Section.mediaItem(
                  title: "Trending this week",
                  fetcher: RepositoryProvider.of<MediaService>(context).search(
                    DiscoverEndpoint(MediaType.movie),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SectionBuilder(
                section: Section.mediaItem(
                  title: "Airing on Disney+",
                  fetcher: RepositoryProvider.of<MediaService>(context).search(
                    DiscoverEndpoint(MediaType.series, networks: ["2739"]),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SectionBuilder(
                section: Section.mediaItem(
                  title: "Apple TV+ Originals",
                  fetcher: RepositoryProvider.of<MediaService>(context).search(
                    DiscoverEndpoint(MediaType.series, networks: ["2552"]),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  FutureBuilder2<Series> _buildSpotlight(BuildContext context) {
    final random = Random();
    return FutureBuilder2<Series>(
      future: RepositoryProvider.of<MediaService>(context).getSeries(
        seriesList[random.nextInt(seriesList.length)],
      ),
      builder: (context, result) => result.maybeWhen(
        inProgress: () => const ShimmerItem(
          child: SpotlightShimmer(),
        ),
        success: (item) {
          return Spotlight(
            title: item.title ?? "Unknown Title",
            backdrop: item.imageUris?.thumb ?? item.imageUris?.backdrop,
            logo: item.imageUris?.logo,
            genres: item.genres,
            synopsis: item.synopsis,
            id: item.id,
            year: item.year,
            ageRating: item.ageRating,
            endDate: item.lastAired,
            hasEnded: item.hasEnded,
            rating: item.criticRatings?.community,
            runtime: item.averageRuntime,
            onTapDetails: () {
              Navigator.pushNamed(
                context,
                "/detail",
                arguments: MediaArgs(
                  SearchResult(
                    id: item.id,
                    name: item.title ?? "",
                    isMovie: false,
                    imageUris: item.imageUris,
                  ),
                ),
              );
            },
          );
        },
        error: (error, stackTrace) => ErrorMessage(error),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}

class SectionBuilder extends StatefulWidget {
  final Section section;
  final void Function()? onChange;

  const SectionBuilder({
    super.key,
    required this.section,
    this.onChange,
  });

  @override
  State<SectionBuilder> createState() => _SectionBuilderState();
}

class _SectionBuilderState extends State<SectionBuilder> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.section.when(
      mediaItem: _buildMediaItemSection,
      nextUp: _buildNextUpSection,
    );
  }

  Future<void> _removeNextUp(NextUpItem item, User? user) async {
    final scaffold = ScaffoldMessenger.of(context);
    if (user != null) {
      try {
        await RepositoryProvider.of<NextUpService>(
          context,
          listen: false,
        ).removeNextUp(item.seriesId, user.id);
        scaffold.showSnackBar(
          const SnackBar(
            content: Text('Deleted entry!'),
          ),
        );
        widget.onChange?.call();
      } catch (e) {
        scaffold.showSnackBar(
          const SnackBar(
            content: Text("Could not delete entry!"),
          ),
        );
      }
    }
  }

  Widget _buildNextUpSection(
    Future<List<NextUpItem>> arg,
  ) {
    return FutureBuilder2<List<NextUpItem>>(
      future: arg,
      builder: (context, state) {
        final user = context.read<UserCubit>().state;
        return state.maybeWhen(
          success: (items) {
            if (items.isNotEmpty) {
              return Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.section.title != null)
                      _buildSectionTitle(widget.section.title!),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        for (final item in items) ...[
                          SlimCover(
                            focusNode: FocusNode(
                              onKeyEvent: (node, event) {
                                if (event is KeyUpEvent &&
                                    event.logicalKey ==
                                        LogicalKeyboardKey.contextMenu) {
                                  _removeNextUp(item, user);
                                }
                                return KeyEventResult.ignored;
                              },
                            ),
                            title: item.seriesName,
                            subtitle1:
                                "Season ${item.seasonIndex}, Episode ${item.episodeIndex}",
                            subtitle2: item.episodeName,
                            imageUris: item.imageUris,
                            onLongPress: () async {
                              await _removeNextUp(item, user);
                            },
                            onPressed: () async {
                              final season = await context
                                  .read<MediaService>()
                                  .getSeason(item.seriesId, item.seasonIndex);
                              final episode =
                                  await context.read<MediaService>().getEpisode(
                                        item.seriesId,
                                        item.seasonIndex,
                                        item.episodeIndex,
                                      );
                              showModalBottomSheet(
                                useRootNavigator: true,
                                isDismissible: false,
                                routeSettings:
                                    const RouteSettings(name: "episode"),
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (context) {
                                  return EpisodeSheet(
                                    season: season,
                                    episode: episode,
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
          inProgress: () => const SlimCoverShimmer(),
          error: (e, s) => const SizedBox.shrink(),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildMediaItemSection(Future<List<SearchResult>> arg) {
    return Container(
      child: Column(
        children: <Widget>[
          if (widget.section.title != null)
            _buildSectionTitle(widget.section.title!),
          const SizedBox(height: 16),
          LimitedBox(
            maxHeight: 450,
            child: FutureBuilder2<List<SearchResult>>(
              future: arg,
              builder: (context, result) => result.maybeWhen(
                inProgress: () => const ShimmerList(
                  itemCount: 6,
                ),
                success: (items) {
                  return CoverListView(
                    [
                      for (final item in items)
                        Cover(
                          title: item.name,
                          subtitle: item.year?.toString(),
                          image: item.imageUris?.primary,
                          key: ValueKey(item.id),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              "/detail",
                              arguments: MediaArgs(item),
                            );
                          },
                        )
                    ],
                  );
                },
                error: (error, stackTrace) => Center(
                  child: ErrorMessage(error),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Builder(builder: (context) {
      return Container(
        child: Text(
          title.toUpperCase(),
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.apply(fontSizeFactor: 0.6, color: Colors.grey.shade300),
        ),
      );
    });
  }
}
