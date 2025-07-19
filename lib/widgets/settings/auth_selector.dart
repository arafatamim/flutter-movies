import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_movies/cubits/user_cubit.dart';
import 'package:flutter_movies/services/auth_service.dart';
import 'package:flutter_movies/models/user.dart';
import 'package:flutter_movies/widgets/dialogs/auth_dialog.dart';

class AuthSelector extends StatelessWidget {
  const AuthSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, User?>(
      builder: (context, currentUser) {
        if (currentUser == null) {
          return ListTile(
            title: const Text("Login or Register"),
            onTap: () => _showAuthDialog(context),
          );
        } else {
          return ListTile(
            title: Text("Logged in as ${currentUser.username}"),
            subtitle: const Text("Tap to logout"),
            onTap: () async {
              await RepositoryProvider.of<AuthService>(context).logout();
              context.read<UserCubit>().unsetUser();
            },
          );
        }
      },
    );
  }

  Future<void> _showAuthDialog(BuildContext context) async {
    final user = await showDialog<User>(
      context: context,
      builder: (context) => const AuthDialog(),
    );

    if (user != null) {
      context.read<UserCubit>().setUser(user);
    }
  }
}
