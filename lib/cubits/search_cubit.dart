import 'package:deferred_type/deferred_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_movies/models/result_endpoint.dart';
import 'package:flutter_movies/models/models.dart';
import 'package:flutter_movies/models/person.dart';
import 'package:flutter_movies/services/media.dart';

typedef SearchPersonState = Deferred<List<PersonResult>>;

class SearchPersonCubit extends Cubit<SearchPersonState> {
  final MediaService mediaService;

  SearchPersonCubit({
    required this.mediaService,
  }) : super(const Deferred.idle());

  void search(String query) async {
    try {
      emit(const Deferred.inProgress());
      final results = await mediaService.searchPerson(query);
      emit(Deferred.success(results));
    } catch (e, s) {
      emit(Deferred.error(e, s));
    }
  }
}

typedef SearchMediaState = Deferred<List<SearchResult>>;

class SearchMediaCubit extends Cubit<SearchMediaState> {
  final MediaService mediaService;

  SearchMediaCubit({
    required this.mediaService,
  }) : super(const Deferred.idle());

  void search(String query) async {
    try {
      emit(const Deferred.inProgress());
      final results = await mediaService.search(
        MultiSearchEndpoint(query)
      );
      emit(Deferred.success(results));
    } catch (e, s) {
      emit(Deferred.error(e, s));
    }
  }
}
