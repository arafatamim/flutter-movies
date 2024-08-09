import 'package:dio/dio.dart';
import 'package:flutter_movies/models/models.dart';
import 'package:flutter_movies/models/trakt_token.dart';
import 'package:flutter_movies/models/user.dart';

/// sample data
var users = [
  const User(id: 1, username: "Homer", admin: true),
  const User(id: 2, username: "Lisa", admin: false)
];

/// replace with your own implementation
class UserService {
  final Dio dio;

  UserService({required Dio dioClient}) : dio = dioClient;

  Future<List<User>> getUsers() async {
    return users;
  }

  Future<User> getUserDetails(int id) async {
    return users.firstWhere((el) => el.id == id);
  }

  Future<void> createUser(String username) async {
    // add to users var with id being epoch millisecons
    users.add(
      User(
        id: DateTime.now().millisecondsSinceEpoch,
        username: username,
        admin: false,
      ),
    );
  }

  Future<void> saveTraktToken(int userId, TraktToken token) async {
    throw UnimplementedError();
    // await dio
    //     .post("/users/$userId/trakt/activate", data: token.toJson())
    //     .catchError((e) => throw mapToServerError(e));
  }

  Future<void> deleteTraktToken(int userId) async {
    throw UnimplementedError();
    // await dio
    //     .get("/users/$userId/trakt/deactivate")
    //     .catchError((e) => throw mapToServerError(e));
  }

  Future<bool> isTraktActivated(int userId) async {
    return false;
    // final res = await dio
    //     .get<Map<String, dynamic>>("/users/$userId/trakt/details")
    //     .catchError((e) => throw mapToServerError(e));
    //
    // return res.data!["payload"]["activated"] as bool;
  }

  Future<List<SearchResult>> getTraktWatchlist(int userId) async {
    throw UnimplementedError();
    // final res = await dio
    //     .get<Map<String, dynamic>>("/users/$userId/trakt/watchlist")
    //     .catchError((e) => throw mapToServerError(e));
    //
    // final payload = res.data!["payload"] as List<dynamic>;
    //
    // return SearchResult.fromList(payload);
  }

  Future<void> addToTraktHistory(
    MediaType mediaType,
    int userId, {
    required ExternalIds ids,
  }) async {
    throw UnimplementedError();
    // await dio
    //     .post(
    //       "/users/$userId/trakt/history/${mediaType.value}",
    //       data: ids.toMap(),
    //     )
    //     .catchError((e) => throw mapToServerError(e));
  }
}
