import "package:dio/dio.dart";
import 'package:flutter_movies/models/models.dart';
import 'package:flutter_movies/utils.dart';

class NextUpItem {
  final String seriesId;
  final String seriesName;
  final String episodeName;
  final int seasonIndex;
  final int episodeIndex;
  final ImageUris imageUris;

  NextUpItem({
    required this.seriesId,
    required this.seasonIndex,
    required this.episodeIndex,
    required this.episodeName,
    required this.seriesName,
    required this.imageUris,
  });

  NextUpItem.fromJson(Map<String, dynamic> json)
      : seriesId = json["seriesId"] as String,
        seasonIndex = json["seasonIndex"] as int,
        episodeIndex = json["episodeIndex"] as int,
        episodeName = json["episodeName"] as String,
        seriesName = json["seriesName"] as String,
        imageUris = ImageUris.fromMap(json["imageUris"]);

  Map<String, dynamic> toMap() => {
        "seriesId": seriesId,
        "seasonIndex": seasonIndex,
        "episodeIndex": episodeIndex,
        "episodeName": episodeName,
        "seriesName": seriesName,
        "imageUris": imageUris.toMap(),
      };

  static List<NextUpItem> fromJsonArray(List<Map<String, dynamic>> json) =>
      json.map((e) => NextUpItem.fromJson(e)).toSet().toList();

  static List<Map<String, dynamic>> toJsonArray(List<NextUpItem> items) =>
      items.map((e) => e.toMap()).toSet().toList();

  @override
  String toString() {
    return "StorageFormat { seriesId: $seriesId; seasonIndex: $seasonIndex; episodeIndex: $episodeIndex;"
        "episodeName: $episodeName; seriesName: $seriesName }";
  }
}

class NextUpService {
  final Dio dio;

  NextUpService({required Dio dioClient}) : dio = dioClient;

  Future<List<NextUpItem>> getAll(int userId) async {
    return [];
    // final res = await dio.get('/users/$userId/nextup');
    // final payload = res.data?["payload"] as List<dynamic>;
    // return payload.reversed
    //     .map((element) => NextUpItem.fromJson(element as Map<String, dynamic>))
    //     .toList();
  }

  Future<NextUpItem?> getNextUp(String seriesId, int userId) async {
    return null;
    // try {
    //   final res = await dio
    //       .get<Map<String, dynamic>>('/users/$userId/nextup/$seriesId');
    //   return NextUpItem.fromJson(
    //     res.data?["payload"] as Map<String, dynamic>,
    //   );
    // } on DioException catch (e) {
    //   if (e.response?.statusCode == 404) {
    //     return null;
    //   } else {
    //     throw mapToServerError(e);
    //   }
    // }
  }

  Future<void> createNextUp({
    required final String seriesId,
    required final int seasonIndex,
    required final int episodeIndex,
    required final int userId,
  }) async {
    throw UnimplementedError();
    // await dio.post(
    //   '/users/$userId/nextup/create',
    //   data: {
    //     "seriesId": seriesId,
    //     "seasonIndex": seasonIndex.toString(),
    //     "episodeIndex": episodeIndex.toString(),
    //   },
    // ).catchError((e) => throw mapToServerError(e));
  }

  Future<void> addOrUpdateNextUp({
    required final String seriesId,
    required final int seasonIndex,
    required final int episodeIndex,
    required final int userId,
  }) async {
    throw UnimplementedError();
    // await dio.put(
    //   '/users/$userId/nextup/$seriesId',
    //   data: {
    //     "seasonIndex": seasonIndex.toString(),
    //     "episodeIndex": episodeIndex.toString()
    //   },
    // ).catchError((e) => throw mapToServerError(e));
  }

  Future<void> removeNextUp(String seriesId, int userId) async {
    throw UnimplementedError();
    // final res = await dio.delete("/users/$userId/nextup/$seriesId");
    // if (res.statusCode != 200) {
    //   throw const ServerError(message: "Could not delete nextup entry");
    // }
  }
}
