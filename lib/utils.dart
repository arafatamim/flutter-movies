import 'dart:math' as math;
import 'package:dio_cache_interceptor_file_store/dio_cache_interceptor_file_store.dart';
import 'package:flutter_movies/models/models.dart';
import 'package:flutter_movies/services/media.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:path_provider/path_provider.dart';

Stream<T> flattenStreams<T>(Stream<Stream<T>> source) async* {
  await for (var stream in source) {
    yield* stream;
  }
}

String formatBytes(int bytes, {int decimals = 1}) {
  if (bytes == 0) return "0 Bytes";
  const k = 1024;
  final sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

  final i = (math.log(bytes) / math.log(k)).floor();
  final finalSize =
      (bytes / math.pow(k, i)).toStringAsFixed(decimals.abs()); // 830.0
  return "$finalSize ${sizes[i]}";
}

T coalesceException<T>(T Function() func, T defaultValue) {
  try {
    return func();
  } catch (e) {
    print(e);
    return defaultValue;
  }
}

extension Converters on DateTime {
  String get longMonth {
    const Map<int, String> monthsInYear = {
      1: "january",
      2: "february",
      3: "march",
      4: "april",
      5: "may",
      6: "june",
      7: "july",
      8: "august",
      9: "september",
      10: "october",
      11: "november",
      12: "december"
    };
    return monthsInYear[month]!;
  }
}

extension CapExtension on String {
  String get capitalizeFirst => '${this[0].toUpperCase()}${substring(1)}';
  String get capitalizeFirstOfEachWord =>
      split(" ").map((str) => str.capitalizeFirst).join(" ");
}

Future<CacheOptions> cacheOptions() async => CacheOptions(
      store: FileCacheStore((await getTemporaryDirectory()).path),
      policy: CachePolicy.request,
      // Optional. Returns a cached response on error but for statuses 401 & 403.
      hitCacheOnErrorExcept: [401, 403],
      // Optional. Overrides any HTTP directive to delete entry past this duration.
      maxStale: const Duration(days: 7),
      // Default. Allows 3 cache sets and ease cleanup.
      priority: CachePriority.normal,
      // Default. Body and headers encryption with your own algorithm.
      cipher: null,
      // Default. Key builder to retrieve requests.
      keyBuilder: CacheOptions.defaultCacheKeyBuilder,
      // Default. Allows to cache POST requests.
      // Overriding [keyBuilder] is strongly recommended.
      allowPostMethod: false,
    );

Future<SearchResult> mapIdToSearchResult(
  MediaType mediaType,
  String id, {
  required MediaService service,
}) async {
  switch (mediaType) {
    case MediaType.movie:
      final movie = await service.getMovie(id);
      final item = SearchResult(
        id: movie.id,
        name: movie.title ?? "",
        isMovie: true,
        imageUris: movie.imageUris,
      );
      return item;
    case MediaType.series:
      final series = await service.getSeries(id);
      final item = SearchResult(
        id: series.id,
        name: series.title ?? "",
        isMovie: false,
        imageUris: series.imageUris,
      );
      return item;
    case MediaType.episode:
      throw Exception("MediaType cannot be of type `episode`");
  }
}

ServerError mapToServerError(dynamic e) {
  if (e is DioException) {
    if (e.response?.data != null) {
      return ServerError.fromMap(e.response!.data! as Map<String, dynamic>);
    } else {
      return ServerError(message: e.message ?? "Error from server");
    }
  } else if (e is Exception) {
    return ServerError(message: e.toString());
  } else {
    return const ServerError(
      message: "Unknown error. Contact administrator if problem persists.",
    );
  }
}

bool isSvg(String uri) {
  return uri.endsWith(".svg");
}
