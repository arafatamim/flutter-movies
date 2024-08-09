import 'dart:async';

import 'package:couchkeys/couchkeys.dart';
import 'package:deferred_type/deferred_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_movies/cubits/search_cubit.dart';
import 'package:flutter_movies/models/detail_arguments.dart';
import 'package:flutter_movies/models/models.dart';
import 'package:flutter_movies/models/person.dart';
import 'package:flutter_movies/services/media.dart';
import 'package:flutter_movies/widgets/buttons/pill_button.dart';
import 'package:flutter_movies/widgets/buttons/responsive_button.dart';
import 'package:flutter_movies/widgets/cover.dart';
import 'package:flutter_movies/widgets/error.dart';
import 'package:flutter_movies/widgets/scaffold_with_button.dart';
import 'package:flutter_movies/widgets/tabs/gn_tab_bar.dart';

// bool _isUtf16Surrogate(int value) {
//   return value & 0xF800 == 0xD800;
// }

class SearchPage extends StatefulWidget {
  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  late final TextEditingController _textController;
  late final TabController _tabController;
  Timer? _debounce;
  Timer? _addHistoryDebounce;
  List<String> _recentQueries = [];
  final _searchKey = const PageStorageKey("recentQueries");

  late final SearchMediaCubit _searchMediaCubit;
  late final SearchPersonCubit _searchPersonCubit;

  String get query => _textController.text;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithButton(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 720) {
              return _buildWideLayout();
            } else {
              return _buildMobileLayout();
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _tabController.dispose();
    _searchPersonCubit.close();
    _searchMediaCubit.close();
    _debounce?.cancel();
    _addHistoryDebounce?.cancel();
    super.dispose();
  }

  void executeSearch() {
    switch (_tabController.index) {
      case 0:
        _searchMediaCubit.search(query);
        break;
      case 1:
        _searchPersonCubit.search(query);
        break;
    }
  }

  @override
  void initState() {
    _textController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);

    final mediaService =
        RepositoryProvider.of<MediaService>(context, listen: false);

    _searchMediaCubit = SearchMediaCubit(mediaService: mediaService);
    _searchPersonCubit = SearchPersonCubit(mediaService: mediaService);

    final savedQueries = PageStorage.of(context).readState(
      context,
      identifier: _searchKey,
    );

    if (savedQueries != null) {
      _recentQueries = savedQueries as List<String>;
    }

    super.initState();
  }

  Container _buildMobileLayout() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          SearchWidget(
            controller: _textController,
            onSubmitted: (value) {
              if (_textController.text.trim() != "") {
                _searchMediaCubit.search(_textController.text);
              }
            },
          ),
          const SizedBox(height: 25),
          Expanded(
            flex: 2,
            child: BlocBuilder<SearchMediaCubit, SearchMediaState>(
              bloc: _searchMediaCubit,
              builder: (context, state) => _buildSearchResults(state),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPersonResults(Deferred<List<PersonResult>> people) {
    return people.when<Widget>(
      success: (results) {
        if (results.isEmpty) {
          return const Center(child: ErrorMessage("No results found"));
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: CoverListView(
            [
              for (final item in results)
                Cover(
                  title: item.name,
                  subtitle: item.department,
                  icon: FeatherIcons.user,
                  key: ValueKey(item.id),
                  image: item.imageUris.primary,
                  onTap: () {
                    Navigator.pushNamed(context, "/detail",
                        arguments: PersonArgs(item));
                  },
                )
            ],
            showIcon: true,
          ),
        );
      },
      error: (error, _) => Center(child: ErrorMessage(error)),
      inProgress: () => const Center(child: CircularProgressIndicator()),
      idle: () => const SizedBox.shrink(),
    );
  }

  Widget _buildSearchResults(Deferred<List<SearchResult>> media) {
    return media.when<Widget>(
      success: (results) {
        if (results.isEmpty) {
          return const Center(child: ErrorMessage("No results found"));
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: CoverListView(
            [
              for (final item in results)
                Cover(
                  title: item.name,
                  subtitle: item.year?.toString(),
                  icon: item.isMovie ? FeatherIcons.film : FeatherIcons.tv,
                  image: item.imageUris?.primary,
                  key: ValueKey(item.id),
                  onTap: () {
                    Navigator.pushNamed(context, "/detail",
                        arguments: MediaArgs(item));
                  },
                )
            ],
            showIcon: true,
          ),
        );
      },
      error: (error, _) => Center(child: ErrorMessage(error)),
      inProgress: () => const Center(child: CircularProgressIndicator()),
      idle: () => const SizedBox.shrink(),
    );
  }

  Widget _buildWideLayout() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  // left side
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // search box
                        Expanded(
                          child: Center(
                            child: FocusScope(
                              canRequestFocus: false,
                              child: SearchWidget(
                                controller: _textController,
                                readOnly: true,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (final query in _recentQueries) ...[
                              PillButton(
                                icon: const Icon(
                                  FeatherIcons.clock,
                                  size: 20,
                                ),
                                label: query,
                                fontSize: 14,
                                onPressed: () {
                                  _textController.text = query;
                                  executeSearch();
                                },
                              ),
                              const SizedBox(
                                width: 8,
                              )
                            ]
                          ],
                        ),
                        const SizedBox(height: 8),
                        GNTabBar(
                          onTabChange: (index) {
                            if (query.trim() != "") {
                              if (index == 0) {
                                _searchMediaCubit.search(query);
                              } else if (index == 1) {
                                _searchPersonCubit.search(query);
                              }
                            }
                          },
                          controller: _tabController,
                          color: WidgetStateColor.resolveWith(
                            (states) => states.contains(WidgetState.focused)
                                ? Colors.white
                                : Colors.black.withAlpha(60),
                          ),
                          mainAxisAlignment: MainAxisAlignment.center,
                          tabs: [
                            const ResponsiveButton(label: "Movies & Series"),
                            const ResponsiveButton(label: "Cast & Crew"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Keyboard
                  Expanded(
                    child: Couchkeys(
                      controller: _textController,
                      keyboardHeight: double.infinity,
                      textTransformer: (incomingValue) =>
                          incomingValue?.toLowerCase(),
                      onChanged: (value) {
                        if ((_debounce?.isActive ?? false) ||
                            (_addHistoryDebounce?.isActive ?? false)) {
                          _debounce?.cancel();
                          _addHistoryDebounce?.cancel();
                        }
                        _debounce = Timer(
                          const Duration(milliseconds: 2000),
                          () {
                            if (query.trim() != "") {
                              executeSearch();
                            }
                          },
                        );
                        _addHistoryDebounce = Timer(
                          const Duration(seconds: 10),
                          () {
                            if (query.trim() != "") {
                              setState(() {
                                _recentQueries = _recentQueries.reversed
                                    .take(4)
                                    .toList()
                                    .reversed
                                    .toList();
                                if (!_recentQueries.contains(query)) {
                                  _recentQueries.add(query);
                                }
                                PageStorage.of(context).writeState(
                                  context,
                                  _recentQueries,
                                  identifier: _searchKey,
                                );
                              });
                            }
                          },
                        );
                      },
                      buttonStyle: ButtonStyle(
                        backgroundColor: WidgetStateColor.resolveWith(
                          (states) => states.contains(WidgetState.focused)
                              ? Colors.white
                              : Colors.black.withAlpha(60),
                        ),
                        foregroundColor: WidgetStateColor.resolveWith(
                          (states) => states.contains(WidgetState.focused)
                              ? Colors.black
                              : Colors.white,
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: TabBarView(
                controller: _tabController,
                children: [
                  BlocBuilder<SearchMediaCubit, SearchMediaState>(
                    bloc: _searchMediaCubit,
                    builder: (context, state) => _buildSearchResults(state),
                  ),
                  BlocBuilder<SearchPersonCubit, SearchPersonState>(
                    bloc: _searchPersonCubit,
                    builder: (context, state) => _buildPersonResults(state),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchWidget extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(String)? onSubmitted;
  final bool readOnly;
  final bool autofocus;

  const SearchWidget({
    super.key,
    this.onSubmitted,
    this.controller,
    this.readOnly = false,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: autofocus,
      readOnly: readOnly,
      controller: controller,
      textInputAction: TextInputAction.go,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontSize: 32.0,
          ),
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 2,
        ),
        border: InputBorder.none,
        hintText: "Search...",
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 32,
              color: Colors.grey,
            ),
      ),
    );
  }
}
