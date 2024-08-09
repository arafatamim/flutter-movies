import 'dart:async';

import 'package:deferred_type/deferred_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FavoriteRepository {
  const FavoriteRepository();
  Future<void> removeFavorite(String seriesId, int userId);
  Future<void> setFavorite(String seriesId, int userId);
  Future<bool> checkFavorite(String seriesId, int userId);
}

class FavoriteCubit extends Cubit<Deferred<bool>> {
  final String _seriesId;
  final int _userId;
  final FavoriteRepository _favoriteRepository;

  FavoriteCubit({
    required String seriesId,
    required int userId,
    required FavoriteRepository favoriteRepository,
  })  : _seriesId = seriesId,
        _userId = userId,
        _favoriteRepository = favoriteRepository,
        super(const Deferred.idle()) {
    favoriteRepository
        .checkFavorite(seriesId, userId)
        .then((isFavorite) => emit(Deferred.success(isFavorite)))
        .catchError(
      (Object e) {
        addError(e);
      },
    );
  }

  Future<void> _fetchFavoriteToStream() async {
    try {
      final isFavorite = await _favoriteRepository.checkFavorite(
        _seriesId,
        _userId,
      );
      emit(Deferred.success(isFavorite));
    } catch (error, stackTrace) {
      emit(Deferred.error(error, stackTrace));
    }
  }

  Future<void> removeFavorite() async {
    emit(const Deferred.success(false));
    await _favoriteRepository.removeFavorite(_seriesId, _userId);
    await _fetchFavoriteToStream();
  }

  Future<void> setFavorite() async {
    emit(const Deferred.success(true));
    await _favoriteRepository.setFavorite(_seriesId, _userId);
    await _fetchFavoriteToStream();
  }
}
