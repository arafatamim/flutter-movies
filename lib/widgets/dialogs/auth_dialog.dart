import 'package:flutter/material.dart';
import 'package:flutter_movies/services/auth_service.dart';
import 'package:flutter_movies/widgets/buttons/pill_button.dart';
import 'package:provider/provider.dart';

class AuthDialog extends StatefulWidget {
  const AuthDialog({super.key});

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PillButton(
                  onPressed: () async {
                    try {
                      final user = await context.read<AuthService>().login(
                            _usernameController.text,
                            _passwordController.text,
                          );
                      Navigator.of(context).pop(user);
                    } catch (e) {
                      // Handle error
                    }
                  },
                  label: 'Login',
                ),
                PillButton(
                  onPressed: () async {
                    try {
                      final user = await context.read<AuthService>().register(
                            _usernameController.text,
                            _passwordController.text,
                          );
                      Navigator.of(context).pop(user);
                    } catch (e) {
                      // Handle error
                    }
                  },
                  label: 'Register',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
