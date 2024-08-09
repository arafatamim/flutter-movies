import 'package:deferred_type_flutter/deferred_type_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_movies/models/detail_arguments.dart';
import 'package:flutter_movies/models/models.dart';
import 'package:flutter_movies/models/section.dart';
import 'package:flutter_movies/widgets/cover.dart';
import 'package:flutter_movies/widgets/error.dart';
import 'package:flutter_movies/widgets/grid.dart';
import 'package:flutter_movies/widgets/shimmers.dart';

class ItemsTab extends StatefulWidget {
  final List<Section> sections;
  final bool showIcon;

  const ItemsTab({
    required this.sections,
    this.showIcon = false,
  });
  @override
  ItemsTabState createState() => ItemsTabState();
}

class ItemsTabState extends State<ItemsTab> with AutomaticKeepAliveClientMixin {
  int get itemCount {
    final deviceSize = MediaQuery.of(context).size;
    final int itemCount = deviceSize.width ~/ 200;
    return itemCount;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<Widget> buildSections() {
      return <Widget>[
        for (int i = 0; i < widget.sections.length; i++) ...[
          widget.sections[i].when(
            mediaItem: (items) {
              return FutureBuilder2<List<SearchResult>>(
                future: items,
                builder: (context, state) => state.maybeWhen(
                  success: (items) {
                    if (widget.sections[i].title != null && items.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.sections[i].title!.toUpperCase(),
                            style: Theme.of(context).textTheme.headlineMedium?.apply(
                                  fontSizeFactor: 0.6,
                                  color: Colors.grey.shade300,
                                ),
                          ),
                          const SizedBox(height: 8),
                          _buildItemsView(items),
                        ],
                      );
                    } else {
                      return _buildItemsView(items);
                    }
                  },
                  error: (error, _) {
                    print(error);
                    return Center(
                      child: ErrorMessage(error),
                    );
                  },
                  orElse: () => SizedBox(
                    height: 300,
                    child: ShimmerList(itemCount: itemCount),
                  ),
                ),
              );
            },
            nextUp: (arg) => throw Exception("Not implemented"),
          ),
          const SizedBox(height: 26)
        ],
      ];
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: buildSections(),
      ),
    );
  }

  Widget _buildItemsView(List<SearchResult> items) {
    return Grid(
      gap: 8,
      columnCount: itemCount,
      children: [
        for (final item in items)
          AspectRatio(
            aspectRatio: 0.6666,
            child: Cover(
              title: item.name,
              subtitle: (item.year ?? "").toString(),
              image: item.imageUris?.primary,
              color: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.focused)
                    ? Colors.white
                    : Colors.transparent,
              ),
              foregroundColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.focused)
                    ? Colors.white
                    : Colors.grey.shade300,
              ),
              mutedForegroundColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.focused)
                    ? Colors.grey.shade300
                    : Colors.grey.shade400,
              ),
              onTap: () {
                Navigator.pushNamed(context, "/detail",
                    arguments: MediaArgs(item));
              },
            ),
          ),
      ],
    );
  }
}
