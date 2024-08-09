import 'package:flutter_movies/models/models.dart';

sealed class ResultEndpoint {}

class SearchEndpoint extends ResultEndpoint {
  final String query;
  final MediaType mediaType;
  final int? limit;

  SearchEndpoint(this.query, this.mediaType, this.limit);
}

class SimilarEndpoint extends ResultEndpoint {
  final String id;
  final MediaType mediaType;

  SimilarEndpoint(this.id, this.mediaType);
}

class MultiSearchEndpoint extends ResultEndpoint {
  final String query;

  MultiSearchEndpoint(this.query);
}

class DiscoverEndpoint extends ResultEndpoint {
  final MediaType mediaType;
  final List<String>? networks;
  final List<String>? genres;
  final List<String>? people;

  DiscoverEndpoint(
    this.mediaType, {
    this.networks,
    this.genres,
    this.people,
  });
}

class PersonCreditsEndpoint extends ResultEndpoint {
  final String personId;

  PersonCreditsEndpoint(this.personId);
}
