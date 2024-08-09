import 'dart:async';

import 'package:deferred_type_flutter/deferred_type_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_movies/cubits/user_cubit.dart';
import 'package:flutter_movies/models/user.dart';
import 'package:flutter_movies/services/user.dart';
import 'package:flutter_movies/widgets/dialogs/responsive_dialog.dart';
import 'package:flutter_movies/widgets/error.dart';
import 'package:flutter_movies/widgets/scaffold_with_button.dart';
import 'package:flutter_movies/widgets/settings/trakt_selector.dart';
import 'package:flutter_movies/widgets/settings/user_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  bool expanded = false;
  StreamController<String?> serverEndpoint = StreamController();

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithButton(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text("Settings"),
      ),
      child: BlocBuilder<UserCubit, User?>(
        builder: (context, currentUser) {
          return ListView(
            children: ListTile.divideTiles(
              context: context,
              tiles: [
                FutureBuilder2<List<User>>(
                  future:
                      RepositoryProvider.of<UserService>(context).getUsers(),
                  builder: (context, result) => result.maybeWhen(
                    success: (users) {
                      if (expanded) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: UserSelector(
                            users: users,
                            onChange: ([User? user]) async {
                              if (user != null) {
                                setState(() {
                                  expanded = false;
                                });
                                context.read<UserCubit>().setUser(user);
                                // BlocProvider.of<UserCubit>(context, listen: false)
                                //     .setUser(user);
                                // await Provider.of<UserService>(context,
                                //         listen: false)
                                //     .setUser(user);
                              }
                            },
                          ),
                        );
                      }
                      return ListTile(
                        title: currentUser != null
                            ? Text("Current profile: ${currentUser.username}")
                            : const Text("Select a profile"),
                        leading: const Icon(FeatherIcons.user),
                        onTap: () {
                          setState(() {
                            expanded = true;
                          });
                        },
                      );
                    },
                    error: (error, stackTrace) {
                      if (currentUser != null) {
                        context.read<UserCubit>().unsetUser();
                        setState(() {});
                      }
                      return ErrorMessage(error);
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),
                ),
                if (currentUser != null)
                  FutureBuilder2<bool>(
                    future: RepositoryProvider.of<UserService>(context)
                        .isTraktActivated(currentUser.id),
                    builder: (context, state) {
                      return state.maybeWhen(
                        success: (activated) {
                          return TraktSelector(
                            activated: activated,
                            userId: currentUser.id,
                            onChange: () => setState(() {}),
                          );
                        },
                        orElse: () => const SizedBox.shrink(),
                      );
                    },
                  ),
                StreamBuilder<String?>(
                  stream: serverEndpoint.stream,
                  builder: (context, snapshot) {
                    final endpoint = snapshot.data;
                    return ListTile(
                      leading: const Icon(FeatherIcons.server),
                      title: const Text("Server endpoint"),
                      subtitle: Text(endpoint ?? "Loading..."),
                      onTap: () {
                        showAdaptiveInputDialog(
                          context,
                          textField: TextField(
                          decoration: const InputDecoration(hintText: "https://example.com:8080"),
                            controller:
                                TextEditingController(text: endpoint ?? ""),
                          ),
                          title: "Set server endpoint",
                          onConfirm: (text) {
                            if (text != null &&
                                text.contains(RegExp(r"https?"))) {
                              SharedPreferences.getInstance().then((pref) {
                                pref.setString("serverEndpoint", text);
                              });
                              serverEndpoint.add(text);
                              Navigator.of(context).pop();
                            }
                          },
                        );
                      },
                    );
                  },
                )
              ],
            ).toList(),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((pref) {
      final endpoint = pref.getString("serverEndpoint");
      serverEndpoint.add(endpoint);
    });
  }

  @override
  void dispose() {
    serverEndpoint.close();
    super.dispose();
  }
}
