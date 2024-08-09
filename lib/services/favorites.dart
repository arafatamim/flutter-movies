import 'package:flutter_movies/models/models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_movies/utils.dart';

class FavoritesService {
  final Dio dio;

  FavoritesService({required Dio dioClient}) : dio = dioClient;

  Future<List<SearchResult>> getFavorites(int userId) async {
    return [];
    // final res = await dio
    //     .get<Map<String, dynamic>>("/users/$userId/favorites")
    //     .catchError((e) => throw mapToServerError(e));
    // return (res.data?["payload"] as List<dynamic>)
    //     .map((e) => SearchResult.fromMap(e))
    //     .toList();
  }

  Future<bool> checkFavorite(String id, int userId) async {
    return false;
    // try {
    //   await dio.get<Map<String, dynamic>>("/users/$userId/favorites/$id");
    //   return true;
    // } catch (e) {
    //   return false;
    // }
  }

  Future<void> saveFavorite(String id, int userId) async {
    throw UnimplementedError();
    // await dio
    //     .put("/users/$userId/favorites/$id")
    //     .catchError((e) => throw mapToServerError(e));
  }

  Future<void> removeFavorite(String id, int userId) async {
    throw UnimplementedError();
    // await dio
    //     .delete("/users/$userId/favorites/$id")
    //     .catchError((e) => throw mapToServerError(e));
  }
}
