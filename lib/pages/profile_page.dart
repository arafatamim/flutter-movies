import 'package:deferred_type_flutter/deferred_type_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_movies/cubits/user_cubit.dart';
import 'package:flutter_movies/models/user.dart';
import 'package:flutter_movies/services/user.dart';
import 'package:flutter_movies/widgets/dialogs/responsive_dialog.dart';
import 'package:flutter_movies/widgets/scaffold_with_button.dart';
import 'package:flutter_movies/widgets/settings/user_selector.dart';
import 'package:flutter_movies/widgets/wave_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithButton(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.primary,
            ],
            radius: 2,
            center: const Alignment(0, 1),
          ),
        ),
        child: Stack(
          children: [
            WaveWidget(
              size: MediaQuery.of(context).size,
              yOffset: 300,
              color: Colors.grey.shade900,
            ),
            FutureBuilder2<List<User>>(
              future: RepositoryProvider.of<UserService>(context).getUsers(),
              builder: (context, state) => state.maybeWhen(
                success: (users) => Column(
                  children: [
                    const SizedBox(height: 64),
                    Text(
                      "Who's watching?",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.grey.shade300),
                    ),
                    const SizedBox(height: 28),
                    UserSelector(
                      users: users,
                      onChange: ([User? user]) async {
                        if (user != null) {
                          BlocProvider.of<UserCubit>(context, listen: false)
                              .setUser(user);
                          Navigator.of(context).pushReplacementNamed("/home");
                        } else {
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
                error: (error, stackTrace) {
                  return DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(FeatherIcons.power),
                        const Text(
                          "Could not reach server",
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                        RawMaterialButton(
                          onPressed: () {
                            showAdaptiveInputDialog(
                              context,
                              textField: TextField(
                                controller: TextEditingController(),
                              ),
                              title: "Set server endpoint",
                              onConfirm: (text) {
                                if (text != null &&
                                    text.contains(RegExp(r"https?"))) {
                                  SharedPreferences.getInstance().then((pref) {
                                    pref.setString("serverEndpoint", text);
                                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                                  });
                                  Navigator.of(context).pop();
                                }
                              },
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(FeatherIcons.server),
                              const SizedBox(width: 8),
                              Text(
                                "Change server endpoint".toUpperCase(),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        RawMaterialButton(
                          onPressed: () {
                            setState(() {});
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(FeatherIcons.refreshCw),
                              const SizedBox(width: 8),
                              Text(
                                "Try again".toUpperCase(),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                orElse: () => const DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
