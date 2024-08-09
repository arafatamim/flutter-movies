import 'package:flutter_movies/models/models.dart';
import 'package:flutter_movies/models/person.dart';

sealed class DetailArgs {}

class MediaArgs extends DetailArgs {
  final SearchResult result;

  MediaArgs(this.result);
}

class PersonArgs extends DetailArgs {
  final PersonResult result;

  PersonArgs(this.result);
}

sealed class DetailType {}

class MovieDetail extends DetailType {
  final Movie movie;

  MovieDetail(this.movie);
}

class SeriesDetail extends DetailType {
  final Series series;

  SeriesDetail(this.series);
}

class PersonDetail extends DetailType {
  final Person person;

  PersonDetail(this.person);
}