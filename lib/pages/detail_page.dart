import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_movies/models/detail_arguments.dart';
import 'package:flutter_movies/services/media.dart';
import 'package:flutter_movies/widgets/detail_shell.dart';
import 'package:flutter_movies/widgets/details/movie_details.dart';
import 'package:flutter_movies/widgets/details/person_details.dart';
import 'package:flutter_movies/widgets/details/series_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_movies/widgets/error.dart';
import 'package:deferred_type_flutter/deferred_type_flutter.dart';

class DetailPage extends StatelessWidget {
  final DetailArgs args;

  const DetailPage(this.args);

  Future<DetailType> _getData(BuildContext context) {
    switch (args) {
      case MediaArgs media:
        if (media.result.isMovie) {
          return RepositoryProvider.of<MediaService>(context, listen: false)
              .getMovie(media.result.id, safeSearch: !media.result.adult)
              .then((movie) => MovieDetail(movie));
        } else {
          return RepositoryProvider.of<MediaService>(context, listen: false)
              .getSeries(media.result.id)
              .then((series) => SeriesDetail(series));
        }
      case PersonArgs person:
        return RepositoryProvider.of<MediaService>(context, listen: false)
            .getPerson(person.result.id)
            .then((person) => PersonDetail(person));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder2<DetailType>(
      future: _getData(context),
      builder: (context, result) {
        return result.maybeWhen(
          success: (media) => switch (media) {
            MovieDetail(movie: final movie) => MovieDetails(movie),
            SeriesDetail(series: final series) => SeriesDetails(series),
            PersonDetail(person: final person) => PersonDetails(person),
          },
          error: (error, stackTrace) {
            print(error);
            return Center(
              child: ErrorMessage(error),
            );
          },
          orElse: () => switch (args) {
            MediaArgs(result: final media) => DetailShell(
                title: media.name,
                imageUris: media.imageUris,
              ),
            PersonArgs(result: final person) => DetailShell(
                title: person.name,
                imageUris: person.imageUris,
              ),
          },
        );
      },
    );
  }
}
