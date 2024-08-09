import 'dart:async';

import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:flutter_movies/models/trakt_code.dart';
import 'package:flutter_movies/models/trakt_token.dart';

class TraktService {
  final Dio dio;
  final clientId = const String.fromEnvironment('TRAKT_CLIENT_ID');
  final clientSecret = const String.fromEnvironment('TRAKT_CLIENT_SECRET');

  const TraktService({required Dio dioClient}) : dio = dioClient;

  Future<TraktCode> generateDeviceCodes() async {
    throw UnimplementedError();
    // fetch device code here
    // final res = await dio.post<Map<String, dynamic>>(
    //   "/oauth/device/code",
    //   data: {"client_id": clientId},
    // ).catchError((Object e) {
    //   print(e);
    //   throw e;
    // });
    //
    // if (res.data != null) {
    //   final codes = TraktCode.fromJson(res.data!);
    //   return codes;
    // } else {
    //   throw const ServerError(message: "Codes not found");
    // }
  }

  CancelableCompleter<TraktToken> fetchToken(
    TraktCode code,
  ) {
    throw UnimplementedError();

    /*
    print("Fetching token...");
    final CancelableCompleter<TraktToken> completer = CancelableCompleter(
      onCancel: () => print("Token operation canceled!"),
    );

    if (completer.isCompleted) {
      throw const ServerError(message: "Operation is already completed!");
    }

    Future<Response<dynamic>?> request() async {
      try {
        return await dio.post<Map<String, dynamic>>(
          "/oauth/device/token",
          data: {
            "code": code.deviceCode,
            "client_id": clientId,
            "client_secret": clientSecret
          },
        );
      } on DioException catch (e) {
        return e.response;
      }
    }

    void doRequest() async {
      while (true) {
        final res = await request();
        switch (res?.statusCode) {
          case 400:
            {
              if (completer.isCanceled) {
                return completer.completeError(
                    const ServerError(message: "Token canceled!"));
              } else {
                // pending
                print("Token still pending...");
                await Future.delayed(Duration(seconds: code.interval));
                continue;
              }
            }
          case 404:
            {
              return completer.completeError(
                  const ServerError(message: "Invalid device code passed!"));
            }
          case 409:
            {
              return completer.completeError(
                  const ServerError(message: "Code already used up!"));
            }
          case 410:
            {
              return completer.completeError(
                  const ServerError(message: "Code has expired"));
            }
          case 418:
            {
              return completer.completeError(
                  const ServerError(message: "User cancelled login process"));
            }
          case 429:
            {
              return completer.completeError(
                  const ServerError(message: "Polling too quickly!"));
            }
          case 200:
            {
              print("Got token!");
              return completer.complete(TraktToken.fromJson(res!.data!));
            }
          default:
            {
              return completer.completeError(
                const ServerError(
                  message: "Unexpected status code while polling for token!",
                ),
              );
            }
        }
      }
    }

    doRequest();
    return completer;
  */
  }
}
