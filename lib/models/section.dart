import 'package:flutter_movies/models/models.dart';
import 'package:flutter_movies/services/next_up.dart';

abstract class Section {
  final String? title;
  const Section({this.title});

  factory Section.mediaItem({
    String? title,
    required Future<List<SearchResult>> fetcher,
  }) = _MediaItem;

  factory Section.nextUp({
    String? title,
    required Future<List<NextUpItem>> fetcher,
  }) = _NextUp;

  R when<R>({
    required R Function(Future<List<SearchResult>> arg) mediaItem,
    required R Function(Future<List<NextUpItem>> arg) nextUp,
  }) {
    if (this is _MediaItem) {
      return mediaItem((this as _MediaItem).fetcher);
    } else {
      return nextUp((this as _NextUp).fetcher);
    }
  }
}

class _MediaItem extends Section {
  final Future<List<SearchResult>> fetcher;
  const _MediaItem({required this.fetcher, super.title});
}

class _NextUp extends Section {
  final Future<List<NextUpItem>> fetcher;
  const _NextUp({required this.fetcher, super.title});
}
