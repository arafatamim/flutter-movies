import 'package:flutter_movies/models/result_endpoint.dart';
import 'package:flutter_movies/models/models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_movies/models/person.dart';
import 'package:flutter_movies/sample_data.dart';

class MediaService {
  final Dio dio;

  MediaService({required Dio dioClient}) : dio = dioClient;

  Future<List<SearchResult>> search(ResultEndpoint endpoint) async {
    /*
    final client = switch (endpoint) {
      SearchEndpoint(
        query: final query,
        mediaType: final mediaType,
        limit: final limit
      ) =>
        dio.get<Map<String, dynamic>>(
          "/${mediaType.value}/search",
          queryParameters: {
            'limit': limit.toString(),
            'query': query,
          },
        ),
      DiscoverEndpoint(
        mediaType: final mediaType,
        networks: final networks,
        genres: final genres,
        people: final people
      ) =>
        dio.get<Map<String, dynamic>>(
          "/discover/${mediaType.value}",
          queryParameters: {
            'networks': networks?.join(","),
            'genres': genres?.join(","),
            'people': people?.join(",")
          }..removeWhere((_, value) => value == null),
        ),
      MultiSearchEndpoint(query: final query) => dio.get<Map<String, dynamic>>(
          "/search/multi",
          queryParameters: {'query': query},
        ),
      SimilarEndpoint(id: final id, mediaType: final mediaType) =>
        dio.get<Map<String, dynamic>>(
          "/${mediaType.value}/$id/similar",
        ),
      PersonCreditsEndpoint(personId: final personId) =>
        dio.get<Map<String, dynamic>>("/person/$personId/credits"),
    }
        .catchError((e) => throw mapToServerError(e));

    final res = await client;
    final payload = res.data?['payload'] as List<dynamic>;
    final results = payload.map((e) => SearchResult.fromMap(e)).toList();
    */
    final Iterable<Media> results = switch (endpoint) {
      SearchEndpoint(
        query: final query,
        mediaType: final mediaType,
      ) =>
        switch (mediaType) {
          MediaType.movie =>
            movies.where((element) => element.title!.contains(query)),
          MediaType.series =>
            series.where((element) => element.title!.contains(query)),
          _ => []
        },
      DiscoverEndpoint(
        mediaType: final mediaType,
      ) =>
        switch (mediaType) {
          MediaType.movie => movies,
          MediaType.series => series,
          _ => []
        },
      MultiSearchEndpoint(query: final query) => [...movies, ...series]
          .where((element) => element.title!.contains(query)),
      SimilarEndpoint _ => [],
      PersonCreditsEndpoint _ => [],
    };

    return results
        .map(
          (item) => SearchResult(
            id: item.id,
            name: item.title!,
            isMovie: item is Movie,
            year: item.year,
            adult: item.adult,
            imageUris: item.imageUris,
          ),
        )
        .toList();
  }

  Future<List<PersonResult>> searchPerson(String query) async {
    return [];
    // final res = await dio.get<Map<String, dynamic>>(
    //   "/person/search",
    //   queryParameters: {
    //     'query': query,
    //   },
    // ).catchError((e) => throw mapToServerError(e));
    //
    // final payload = res.data?["payload"] as List<dynamic>;
    // final results = payload.map((e) => PersonResult.fromMap(e)).toList();
    // return results;
  }

  Future<Person> getPerson(String personId) async {
    throw UnimplementedError();
    // final res = await dio.get<Map<String, dynamic>>("/person/$personId");
    // final payload = res.data?["payload"] as dynamic;
    // return Person.fromMap(payload);
  }

  Future<Movie> getMovie(String id, {bool safeSearch = true}) async {
    return movies.firstWhere((element) => element.id == id);
    // final res = await dio.get<Map<String, dynamic>>(
    //   "/movie/$id",
    //   queryParameters: {"include_adult": !safeSearch},
    // ).catchError((e) => throw mapToServerError(e));
    //
    // Map<String, dynamic> payload = res.data?['payload'] as Map<String, dynamic>;
    // return Movie.fromMap(payload);
  }

  Future<Series> getSeries(String id) async {
    return series.firstWhere((element) => element.id == id);
    // final res = await dio
    //     .get<Map<String, dynamic>>("/series/$id")
    //     .catchError((e) => throw mapToServerError(e));
    //
    // Map<String, dynamic> payload = res.data?['payload'] as Map<String, dynamic>;
    // return Series.fromMap(payload);
  }

  Future<List<Season>> getSeasons(String id) async {
    return seasons.firstWhere((element) => element["seriesId"] == id)["seasons"]
        as List<Season>;
    // final res = await dio
    //     .get<Map<String, dynamic>>("/series/$id/seasons")
    //     .catchError((e) => throw mapToServerError(e));
    //
    // final payload = res.data?['payload'] as List<dynamic>;
    // return payload.map((e) => Season.fromMap(e)).toList();
  }

  Future<Season> getSeason(String seriesId, int seasonIndex) async {
    return (seasons.firstWhere(
                (element) => element["seriesId"] == seriesId)["seasons"]
            as List<Season>)
        .firstWhere((element) => element.index == seasonIndex);
    // final res = await dio
    //     .get<Map<String, dynamic>>("/series/$seriesId/seasons/$seasonIndex")
    //     .catchError((e) => throw mapToServerError(e));
    //
    // return Season.fromMap(res.data?["payload"] as Map<String, dynamic>);
  }

  Future<Episode> getEpisode(
    String seriesId,
    int seasonIndex,
    int episodeIndex,
  ) async {
    return (episodes.firstWhere((element) =>
            element["seriesId"] == seriesId &&
            element["seasonIndex"] == seasonIndex)["episodes"] as List<Episode>)
        .firstWhere((element) => element.index == episodeIndex);
    // final res = await dio
    //     .get<Map<String, dynamic>>(
    //         "/series/$seriesId/seasons/$seasonIndex/episodes/$episodeIndex")
    //     .catchError((e) => throw mapToServerError(e));
    //
    // return Episode.fromMap(res.data?["payload"] as Map<String, dynamic>);
  }

  Future<List<Episode>> getEpisodes(String seriesId, int seasonIndex) async {
    return (episodes.firstWhere((element) =>
        element["seriesId"] == seriesId &&
        element["seasonIndex"] == seasonIndex)["episodes"] as List<Episode>);
    // final res = await dio
    //     .get<Map<String, dynamic>>(
    //         "/series/$seriesId/seasons/$seasonIndex/episodes")
    //     .catchError((e) => throw mapToServerError(e));
    //
    // final payload = res.data?['payload'] as List<dynamic>;
    // return payload.map((e) => Episode.fromMap(e)).toList();
  }

  Future<List<MediaSource>> getSources({
    required String id,
    int? seasonIndex,
    int? episodeIndex,
    bool safeSearch = true,
  }) async {
    return [];
    // final pathname = (seasonIndex != null && episodeIndex != null)
    //     ? "/series/$id/seasons/$seasonIndex/episodes/$episodeIndex/sources"
    //     : "/movie/$id/sources";
    // final res = await dio.get<Map<String, dynamic>>(
    //   pathname,
    //   queryParameters: {"include_adult": !safeSearch},
    // ).catchError((e) => throw mapToServerError(e));
    //
    // final payload = res.data?['payload'] as List<dynamic>;
    // return MediaSource.fromMapList(payload);
  }
}

class SearchModel {
  final String type;
  final String payload;
  SearchModel.fromMap(Map<String, dynamic> json)
      : type = json["type"] as String,
        payload = json["payload"] as String;
}
