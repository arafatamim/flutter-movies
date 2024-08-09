import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:deferred_type_flutter/deferred_type_flutter.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_movies/cubits/user_cubit.dart';
import 'package:flutter_movies/models/models.dart';
import 'package:flutter_movies/models/user.dart';
import 'package:flutter_movies/services/media.dart';
import 'package:flutter_movies/services/user.dart';
import 'package:flutter_movies/widgets/buttons/responsive_button.dart';
import 'package:flutter_movies/widgets/detail_shell.dart';
import 'package:flutter_movies/widgets/dialogs/responsive_dialog.dart';
import 'package:flutter_movies/widgets/error.dart';
import 'package:flutter_movies/widgets/label.dart';
import 'package:flutter_movies/widgets/wide_tile.dart';
import 'package:flutter_movies/utils.dart';

class MovieDetails extends StatefulWidget {
  final Movie movie;

  const MovieDetails(
    this.movie, {
    super.key,
  });

  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  @override
  Widget build(BuildContext context) {
    return DetailShell(
      title: widget.movie.title ?? "Untitled Movie",
      meta: _buildMeta(),
      subtitle: widget.movie.genres?.join(", "),
      description: widget.movie.synopsis,
      imageUris: widget.movie.imageUris,
      child: FutureBuilder2<List<MediaSource>>(
        future: RepositoryProvider.of<MediaService>(context).getSources(
          id: widget.movie.id,
          safeSearch: !widget.movie.adult,
        ),
        builder: (context, result) => result.maybeWhen(
          inProgress: () => const Center(
            child: CircularProgressIndicator(),
          ),
          success: (data) => _buildMovieSources(data),
          error: (error, _) => Center(
            child: ErrorMessage(error),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildMovieSources(List<MediaSource> sources) {
    if (sources.isNotEmpty) {
      return Container(
        child: Column(
          children: [
            Text(
              "Available sources".toUpperCase(),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 20.0,
                  ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView(children: _sourceList(sources)),
            )
          ],
        ),
      );
    } else {
      return const Center(child: ErrorMessage("No sources found"));
    }
  }

  List<Widget> _sourceList(List<MediaSource> sources) {
    const subMimes = [
      "application/x-subrip",
      "text/vtt",
      "text/vnd.dvb.subtitle"
    ];
    final subtitles = sources
        .where(
          (element) =>
              element.mimeType != null && subMimes.contains(element.mimeType),
        )
        .map(
          (e) => SubtitleResult(
              url: e.streamUri, language: e.language ?? Language.english),
        )
        .toList(growable: false);

    final media = sources.where((element) =>
        element.mimeType != null && !subMimes.contains(element.mimeType));
    return <Widget>[
      for (final source in media) _buildSourceTile(source, subtitles)
    ];
  }

  Widget _buildSourceTile(MediaSource source, List<SubtitleResult> subtitles) {
    return BlocBuilder<UserCubit, User?>(
      builder: (context, user) {
        return WideTile(
          title: source.displayName +
              (source.fileSize != null
                  ? ", ${formatBytes(source.fileSize!)}"
                  : ""),
          subtitle: source.fileName,
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
                  arguments: {
                    "title": widget.movie.title,
                  },
                );
                await intent.launch();
              }
              if (user != null) {
                final isTraktActivated =
                    await RepositoryProvider.of<UserService>(
                  context,
                  listen: false,
                ).isTraktActivated(user.id);
                if (isTraktActivated) {
                  await Future.delayed(const Duration(seconds: 2));
                  await showWatchedDialog(user);
                }
              }
            } on UnsupportedError {
              print("It's the web!");
            } catch (e) {
              print(e);
            }
          },
        );
      },
    );
  }

  Future<dynamic> showWatchedDialog(User user) {
    Future<void> onPressed() async {
      {
        try {
          RepositoryProvider.of<UserService>(
            context,
            listen: false,
          ).addToTraktHistory(
            MediaType.movie,
            user.id,
            ids: widget.movie.externalIds,
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
      title: "Did you finish watching the movie?",
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

  List<List<Widget>> _buildMeta() => [
        <Widget>[
          if (widget.movie.year != null)
            MetaLabel(widget.movie.year.toString()),
          if (widget.movie.criticRatings?.tmdb != null)
            MetaLabel(widget.movie.criticRatings!.tmdb!.toString(),
                leading: const Icon(FeatherIcons.star)),
          if (widget.movie.runtime != null)
            MetaLabel(
              prettyDuration(
                widget.movie.runtime!,
                tersity: DurationTersity.minute,
                abbreviated: true,
                delimiter: " ",
              ),
              leading: const Icon(FeatherIcons.clock),
            ),
          if (widget.movie.ageRating != null)
            MetaLabel(widget.movie.ageRating!, hasBackground: true),
        ],
        <Widget>[
          if (widget.movie.directors != null &&
              widget.movie.directors!.isNotEmpty)
            MetaLabel(
              widget.movie.directors![0],
              title: "Director",
            ),
          if (widget.movie.studios != null && widget.movie.studios!.isNotEmpty)
            MetaLabel(
              widget.movie.studios![0],
              title: "Production",
            ),
        ],
        [
          if (widget.movie.cast != null)
            Expanded(
              child: MetaLabel(
                widget.movie.cast!.take(10).map((i) => i.name).join(" • "),
                title: "Cast",
              ),
            ),
        ]
      ];
}
