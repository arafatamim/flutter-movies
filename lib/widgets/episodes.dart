import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:deferred_type_flutter/deferred_type_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_movies/cubits/user_cubit.dart';
import 'package:flutter_movies/models/models.dart';
import 'package:flutter_movies/models/user.dart';
import 'package:flutter_movies/services/media.dart';
import 'package:flutter_movies/services/next_up.dart';
import 'package:flutter_movies/services/user.dart';
import 'package:flutter_movies/widgets/buttons/responsive_button.dart';
import 'package:flutter_movies/widgets/dialogs/responsive_dialog.dart';
import 'package:flutter_movies/widgets/error.dart';
import 'package:flutter_movies/widgets/label.dart';
import 'package:flutter_movies/widgets/wide_tile.dart';
import 'package:flutter_movies/utils.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:ticker_text/ticker_text.dart';

class Episodes extends StatefulWidget {
  final Season season;
  const Episodes(this.season);

  @override
  EpisodesState createState() => EpisodesState();
}

class EpisodesState extends State<Episodes> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder2<List<Episode>>(
      future: RepositoryProvider.of<MediaService>(context)
          .getEpisodes(widget.season.seriesId, widget.season.index),
      builder: (context, result) => result.maybeWhen(
        inProgress: () => const Center(child: CircularProgressIndicator()),
        success: (episodes) {
          final deviceSize = MediaQuery.of(context).size;

          if (deviceSize.width > 720) {
            return _buildWideEpisodesList(episodes);
          } else {
            return _buildMobileEpisodesList(episodes);
          }
        },
        error: (error, stackTrace) => ErrorMessage(error),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildMobileEpisodesList(List<Episode> episodes) {
    return ListView(
      children: [
        for (var index = 0; index < episodes.length; index++)
          ListTile(
            title: Text(episodes[index].name),
            subtitle: Text(episodes[index].synopsis ?? ""),
            leading: Text(episodes[index].index.toString()),
            onTap: () {
              _displaySheet(context, episodes, index);
            },
          )
      ],
    );
  }

  Widget _buildWideEpisodesList(List<Episode> episodes) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: ListView.builder(
        addAutomaticKeepAlives: true,
        itemCount: episodes.length,
        itemBuilder: (context, index) {
          return WideTile(
            leading: Text(
              episodes[index].index.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 25,
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            title: episodes[index].name,
            subtitle: episodes[index].synopsis,
            scrollAxis: Axis.vertical,
            height: 100,
            onTap: () {
              _displaySheet(context, episodes, index);
            },
          );
        },
      ),
    );
  }

  void _displaySheet(BuildContext context, List<Episode> episodes, int index) {
    showModalBottomSheet(
      useRootNavigator: true,
      isDismissible: false,
      routeSettings: const RouteSettings(name: "episode"),
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return EpisodeSheet(
          season: widget.season,
          episode: episodes[index],
        );
      },
    );
  }
}

class EpisodeSheet extends StatelessWidget {
  const EpisodeSheet({
    super.key,
    required this.season,
    required this.episode,
  });

  final Season season;
  final Episode episode;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (episode.imageUris?.backdrop != null)
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: episode.imageUris!.backdrop!,
              fit: BoxFit.cover,
              alignment: const Alignment(0.0, -.5),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            // color: Colors.white,
            gradient: LinearGradient(
              begin: FractionalOffset.centerLeft,
              end: FractionalOffset.centerRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary.withAlpha(200),
              ],
              stops: [0.0, 1.0],
            ),
          ),
        ),
        EpisodeDetails(episode, season),
      ],
    );
  }
}

class EpisodeDetails extends StatelessWidget {
  final Episode episode;
  final Season season;

  const EpisodeDetails(this.episode, this.season);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    if (deviceSize.width > 720) {
      return _buildWideDetails(context);
    } else {
      return _buildMobileDetails(context);
    }
  }

  Padding _buildMobileDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEpisodeTitle(),
            const SizedBox(height: 6),
            _buildEpisodeNumber(),
            const SizedBox(height: 15),
            _buildMeta(),
            const SizedBox(height: 15),
            _buildSynopsis(),
            const SizedBox(height: 20),
            _buildSourcesWidget()
          ],
        ),
      ),
    );
  }

  Widget _buildWideDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 38),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEpisodeTitle(),
              const SizedBox(height: 6),
              _buildEpisodeNumber(),
              const SizedBox(height: 15),
              _buildMeta(),
              const SizedBox(height: 15),
              Expanded(
                child: TickerText(
                  startPauseDuration: const Duration(seconds: 10),
                  endPauseDuration: const Duration(seconds: 10),
                  scrollDirection: Axis.vertical,
                  speed: 12,
                  child: _buildSynopsis(),
                ),
              )
            ],
          ),
        ),
        const Spacer(),
        Expanded(
          child: _buildSourcesWidget(),
        )
      ]),
    );
  }

  Widget _buildEpisodeTitle() {
    return Builder(
      builder: (context) => Text(
        episode.name,
        maxLines: 3,
        softWrap: true,
        style: Theme.of(context).textTheme.displayMedium,
      ),
    );
  }

  Widget _buildEpisodeNumber() {
    return Builder(builder: (context) {
      return Text(
        "S${season.index.toString().padLeft(2, "0")}"
        "E${episode.index.toString().padLeft(2, '0')}",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade300,
              fontSize: 25,
            ),
      );
    });
  }

  Row _buildMeta() {
    return Row(
      children: [
        if (episode.runtime != null)
          MetaLabel(
            prettyDuration(
              episode.runtime!,
              tersity: DurationTersity.minute,
              abbreviated: true,
              delimiter: " ",
            ),
            leading: const Icon(FeatherIcons.clock),
          ),
        if (episode.airDate != null)
          MetaLabel(
            "Aired on ${episode.airDate!.longMonth.capitalizeFirst} ${episode.airDate!.day}, ${episode.airDate!.year}",
          ),
      ],
    );
  }

  Widget _buildSourcesWidget() {
    return BlocBuilder<UserCubit, User?>(
      builder: (context, user) {
        return EpisodeSources(
          episode.seriesId,
          episode.seasonIndex,
          episode.index,
          onPlay: () async {
            if (user != null) {
              final isTraktActivated = await RepositoryProvider.of<UserService>(
                context,
                listen: false,
              ).isTraktActivated(user.id);
              await RepositoryProvider.of<NextUpService>(
                context,
                listen: false,
              ).createNextUp(
                seriesId: episode.seriesId,
                seasonIndex: episode.seasonIndex,
                episodeIndex: episode.index,
                userId: user.id,
              );
              if (isTraktActivated) {
                await Future.delayed(const Duration(seconds: 1));
                await showWatchedDialog(context, user);
              }
            }
          },
        );
      },
    );
  }

  Widget _buildSynopsis() {
    return Builder(builder: (context) {
      return Text(
        episode.synopsis ?? "",
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade300,
              fontSize: 16,
            ),
      );
    });
  }

  Future<dynamic> showWatchedDialog(BuildContext context, User user) {
    Future<void> onPressed() async {
      {
        try {
          RepositoryProvider.of<UserService>(
            context,
            listen: false,
          ).addToTraktHistory(
            MediaType.episode,
            user.id,
            ids: episode.externalIds,
          );
          Navigator.of(context).pop();
        } on ServerError catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
            ),
          );
        }
      }
    }

    return showAdaptiveAlertDialog(
      context,
      title: "Did you watch the full episode?",
      buttons: [
        ResponsiveButton(
          icon: FeatherIcons.x,
          autofocus: true,
          label: "No, I didn't",
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ResponsiveButton(
          icon: FeatherIcons.check,
          label: "Yes, mark watched",
          onPressed: onPressed,
        ),
      ],
    );
  }
}

class EpisodeSources extends StatelessWidget {
  final String seriesId;
  final int seasonIndex;
  final int episodeIndex;
  final VoidCallback? onPlay;

  const EpisodeSources(
    this.seriesId,
    this.seasonIndex,
    this.episodeIndex, {
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder2<List<MediaSource>>(
      future: RepositoryProvider.of<MediaService>(context).getSources(
        id: seriesId,
        seasonIndex: seasonIndex,
        episodeIndex: episodeIndex,
      ),
      builder: (context, result) {
        return result.when(
          inProgress: () => const Center(child: CircularProgressIndicator()),
          success: (mediaSources) {
            final deviceSize = MediaQuery.of(context).size;

            if (deviceSize.width > 720) {
              return _buildWideLayout(mediaSources);
            } else {
              return _buildMobileLayout(mediaSources);
            }
          },
          error: (err, stack) => ErrorMessage(err),
          idle: () => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildSourceCard(MediaSource source) {
    return WideTile(
      title: source.displayName +
          (source.fileSize != null ? ", ${formatBytes(source.fileSize!)}" : ""),
      subtitle: source.fileName,
      height: null,
      scrollAxis: Axis.horizontal,
      onTap: () async {
        try {
          if (Platform.isAndroid) {
            final AndroidIntent intent = AndroidIntent(
              action: 'action_view',
              data: source.streamUri,
              type: source.mimeType ?? "video/*",
              flags: [
                Flag.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
                Flag.FLAG_GRANT_PREFIX_URI_PERMISSION,
                Flag.FLAG_GRANT_WRITE_URI_PERMISSION,
                Flag.FLAG_GRANT_READ_URI_PERMISSION
              ],
            );
            await intent.launch();
            onPlay?.call();
          } else {
            print("DING DING DING");
          }
        } on UnsupportedError {
          print("It's the web!");
        }
      },
    );
  }

  Widget _buildWideLayout(List<MediaSource> mediaSources) {
    return ListView(
      shrinkWrap: true,
      children: [for (final source in mediaSources) _buildSourceCard(source)],
    );
  }

  Widget _buildMobileLayout(List<MediaSource> mediaSources) {
    return Column(
      children: [for (final source in mediaSources) _buildSourceCard(source)],
    );
  }
}
