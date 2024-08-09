import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_movies/cubits/user_cubit.dart';
import 'package:flutter_movies/models/result_endpoint.dart';
import 'package:flutter_movies/models/models.dart';
import 'package:flutter_movies/models/section.dart';
import 'package:flutter_movies/models/user.dart';
import 'package:flutter_movies/services/media.dart';
import 'package:flutter_movies/services/favorites.dart';
import 'package:flutter_movies/services/user.dart';
import 'package:flutter_movies/tabs/home_tab.dart';
import 'package:flutter_movies/tabs/items_tab.dart';
import 'package:flutter_movies/widgets/buttons/animated_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_movies/widgets/error.dart';
import 'package:flutter_movies/widgets/scaffold_with_button.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final TabController _controller;
  bool isWide = true;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 4, vsync: this);
  }

  @override
  void didChangeDependencies() {
    isWide = MediaQuery.of(context).size.width > 720;
    if (isWide) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, User?>(
      builder: (context, user) {
        return ScaffoldWithButton(
          appBar: isWide ? null : _buildAppbar(context),
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.primary,
                  ],
                  stops: [0, 1],
                  center: Alignment.bottomCenter,
                  radius: 1.4,
                  focal: const Alignment(0, 2.5),
                ),
              ),
              child: Column(
                children: [
                  // Nav bar
                  if (isWide) _buildNavBar(context),

                  // Main view
                  Expanded(
                    child: Container(
                      clipBehavior: Clip.none,
                      margin: EdgeInsets.symmetric(
                        horizontal: isWide ? 64 : 0,
                      ),
                      child: TabBarView(
                        controller: _controller,
                        physics: const NeverScrollableScrollPhysics(),
                        children: <Widget>[
                          HomeTab(key: UniqueKey()),
                          user != null
                              ? FutureBuilder<bool>(
                                  future: RepositoryProvider.of<UserService>(
                                    context,
                                  ).isTraktActivated(user.id),
                                  builder: (context, snapshot) {
                                    return ItemsTab(
                                      sections: [
                                        Section.mediaItem(
                                          fetcher: RepositoryProvider.of<
                                                  FavoritesService>(context)
                                              .getFavorites(user.id),
                                        ),
                                        if (snapshot.data == true)
                                          Section.mediaItem(
                                            title: "Movies to watch",
                                            fetcher: RepositoryProvider.of<
                                                    UserService>(context)
                                                .getTraktWatchlist(user.id)
                                                .then(
                                                  (value) =>
                                                      value.take(12).toList(),
                                                ),
                                          ),
                                      ],
                                      showIcon: true,
                                    );
                                  },
                                )
                              : const Center(
                                  child: ErrorMessage(
                                      "Select a profile to view watchlist here"),
                                ),
                          ItemsTab(
                            sections: [
                              Section.mediaItem(
                                fetcher:
                                    RepositoryProvider.of<MediaService>(context)
                                        .search(
                                  DiscoverEndpoint(MediaType.movie),
                                ),
                              ),
                            ],
                          ),
                          ItemsTab(
                            sections: [
                              Section.mediaItem(
                                fetcher:
                                    RepositoryProvider.of<MediaService>(context)
                                        .search(
                                  DiscoverEndpoint(MediaType.series),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppbar(BuildContext context) {
    return AppBar(
      elevation: 7,
      title: Text(
        widget.title,
        style: GoogleFonts.gloriaHallelujah(fontSize: 20.0),
      ),
      automaticallyImplyLeading: false,
      bottom: TabBar(
        indicatorColor: Theme.of(context).colorScheme.secondary,
        controller: _controller,
        tabs: <Widget>[
          const Tab(
            icon: Icon(FeatherIcons.home),
            text: "Home",
          ),
          const Tab(
            icon: Icon(FeatherIcons.heart),
            text: "My list",
          ),
          const Tab(
            icon: Icon(FeatherIcons.film),
            text: "Movies",
          ),
          const Tab(
            icon: Icon(FeatherIcons.tv),
            text: "Shows",
          )
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, "/search");
          },
          icon: const Icon(FeatherIcons.search),
        ),
        PopupMenuButton<String>(
          itemBuilder: (context) {
            return {"Reload", "Settings"}
                .map((e) => PopupMenuItem(value: e, child: Text(e)))
                .toList();
          },
          onSelected: (value) {
            switch (value) {
              case "Reload":
                setState(() {});
                break;
              case "Settings":
                Navigator.pushNamed(context, "/settings");
                break;
            }
          },
        ),
      ],
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 10),
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AnimatedIconButton(
            autofocus: true,
            icon: const Icon(FeatherIcons.search),
            label: const Text(
              "Search",
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              Navigator.pushNamed(context, "/search");
            },
          ),
          const SizedBox(width: 16),
          GNav(
            key: ValueKey(_controller.index),
            selectedIndex: _controller.index,
            onTabChange: (value) {
              _controller.animateTo(value);
            },
            gap: 8,
            color: Colors.white.withAlpha(100),
            activeColor: Colors.grey.shade200,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOutCubic,
            tabs: [
              const GButton(
                textStyle: TextStyle(fontSize: 16),
                icon: FeatherIcons.home,
                text: "Home",
              ),
              const GButton(
                textStyle: TextStyle(fontSize: 16),
                icon: FeatherIcons.heart,
                text: "My list",
              ),
              const GButton(
                textStyle: TextStyle(fontSize: 16),
                icon: FeatherIcons.film,
                text: "Movies",
              ),
              const GButton(
                textStyle: TextStyle(fontSize: 16),
                icon: FeatherIcons.tv,
                text: "Shows",
              ),
            ],
          ),
          const Spacer(),
          AnimatedIconButton(
            icon: const Icon(
              FeatherIcons.refreshCw,
              size: 24,
            ),
            label: const Text(
              "Refresh",
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              setState(() {});
            },
          ),
          const SizedBox(width: 16),
          BlocBuilder<UserCubit, User?>(
            builder: (context, user) {
              if (user == null) {
                return AnimatedIconButton(
                  icon: const Icon(
                    FeatherIcons.settings,
                    size: 24,
                  ),
                  label: const Text(
                    "Settings",
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () => Navigator.of(context).pushNamed("/settings"),
                );
              }
              return AnimatedIconButton(
                icon: const Icon(
                  FeatherIcons.user,
                  size: 24,
                ),
                label: Text(
                  user.username,
                  style: const TextStyle(fontSize: 16),
                ),
                onPressed: () => Navigator.of(context).pushNamed("/settings"),
              );
            },
          ),
          const SizedBox(width: 16),
          Text(
            widget.title,
            style: GoogleFonts.gloriaHallelujah(fontSize: 24.0),
          ),
        ],
      ),
    );
  }
}
