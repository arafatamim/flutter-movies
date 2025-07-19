import 'package:dio/dio.dart';
import 'package:flutter_movies/models/models.dart';
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


}
