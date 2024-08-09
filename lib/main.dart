import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_movies/cubits/user_cubit.dart';
import 'package:flutter_movies/models/detail_arguments.dart';
import 'package:flutter_movies/pages/profile_page.dart';
import 'package:flutter_movies/scale_page_transition.dart';
import 'package:flutter_movies/pages/detail_page.dart';
import 'package:flutter_movies/pages/home_page.dart';
import 'package:flutter_movies/pages/search_page.dart';
import 'package:flutter_movies/pages/settings_page.dart';
import 'package:flutter_movies/services/media.dart';
import 'package:flutter_movies/services/favorites.dart';
import 'package:flutter_movies/services/next_up.dart';
import 'package:flutter_movies/services/trakt.dart';
import 'package:flutter_movies/services/user.dart';
import 'package:flutter_movies/theme/modern.dart';
import 'package:flutter_movies/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final endpoint = prefs.getString("serverEndpoint");
  final baseUrl = Uri.parse("${endpoint ?? "http://192.168.0.100:6767"}/api");

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl.toString(),
      responseType: ResponseType.json,
      receiveDataWhenStatusError: true,
    ),
  )..interceptors.addAll([
      DioCacheInterceptor(
        options: await cacheOptions(),
      ),
    ]);

  runApp(MyApp(dio: dio));
}

const searchKey = PageStorageKey("recentQueries");

class MyApp extends StatelessWidget {
  final Dio dio;
  final _searchPageBucket = PageStorageBucket();

  MyApp({
    super.key,
    required this.dio,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<MediaService>(
          create: (_) => MediaService(dioClient: dio),
        ),
        RepositoryProvider<FavoritesService>(
          create: (_) => FavoritesService(dioClient: dio),
        ),
        RepositoryProvider<NextUpService>(
          create: (_) => NextUpService(dioClient: dio),
        ),
        RepositoryProvider<UserService>(
          create: (_) => UserService(dioClient: dio),
        ),
        RepositoryProvider<TraktService>(
          create: (_) => TraktService(
            dioClient: Dio(
              BaseOptions(
                baseUrl: "https://api.trakt.tv",
                responseType: ResponseType.json,
                receiveDataWhenStatusError: true,
              ),
            ),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<UserCubit>(
            create: (context) => UserCubit(),
          ),
        ],
        child: Shortcuts(
          // needed for AndroidTV to be able to select
          shortcuts: {
            LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent()
          },
          child: MaterialApp(
            title: 'Flutter Movies',
            theme: ModernTheme.darkTheme,
            home: const ProfilePage(),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case "/detail":
                  return ScaleRoute(
                    settings: const RouteSettings(name: "detail"),
                    page: DetailPage(settings.arguments as DetailArgs),
                  );
                case "/search":
                  return ScaleRoute(
                    settings: const RouteSettings(name: "search"),
                    page: PageStorage(
                      bucket: _searchPageBucket,
                      child: SearchPage(),
                    ),
                  );
                case "/settings":
                  return ScaleRoute(
                    settings: const RouteSettings(name: "settings"),
                    page: SettingsPage(),
                  );
                case "/home":
                  return ScaleRoute(
                    page: const HomePage(title: "Flutter Movies"),
                  );
                default:
                  return null;
              }
            },
          ),
        ),
      ),
    );
  }
}
