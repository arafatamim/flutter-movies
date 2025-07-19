import 'package:dio/dio.dart';
import 'package:flutter_movies/models/user.dart';

class AuthService {
  final Dio dio;

  AuthService({required this.dio});

  Future<User> login(String username, String password) async {
    // TODO: Implement login logic
    throw UnimplementedError();
  }

  Future<User> register(String username, String password) async {
    // TODO: Implement register logic
    throw UnimplementedError();
  }

  Future<void> logout() async {
    // TODO: Implement logout logic
    throw UnimplementedError();
  }
}
