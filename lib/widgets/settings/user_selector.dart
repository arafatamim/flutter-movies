import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_movies/models/models.dart';
import 'package:flutter_movies/models/user.dart';
import 'package:flutter_movies/services/user.dart';
import 'package:flutter_movies/widgets/buttons/pill_button.dart';
import 'package:flutter_movies/widgets/dialogs/responsive_dialog.dart';

class UserSelector extends StatefulWidget {
  final List<User> users;
  final void Function([User]) onChange;
  final void Function()? onOpen;
  final void Function()? onClose;

  const UserSelector({
    super.key,
    required this.users,
    required this.onChange,
    this.onClose,
    this.onOpen,
  });

  @override
  State<UserSelector> createState() => _UserSelectorState();
}

class _UserSelectorState extends State<UserSelector>
    with TickerProviderStateMixin {
  bool dropped = false;
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final user in widget.users) ...[
          PillButton(
            label: user.username,
            icon: const Icon(FeatherIcons.user),
            fontSize: 20,
            onPressed: () {
              widget.onChange(user);
            },
          ),
          const SizedBox(width: 10)
        ],
        PillButton(
          icon: const Icon(FeatherIcons.plus, size: 30),
          onPressed: () {
            _showCreateUserDialog();
          },
        )
      ],
    );
  }

  Future<void> createUser(String? username) async {
    if (username != null && username.trim() != "") {
      try {
        await RepositoryProvider.of<UserService>(context, listen: false)
            .createUser(username);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User has been created"),
          ),
        );
      } on ServerError {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "There was an error creating user",
            ),
          ),
        );
      }
    }
    Navigator.of(context).pop();
    widget.onChange();
  }

  void _showCreateUserDialog() {
    showAdaptiveInputDialog(
      context,
      onConfirm: (value) async {
        await createUser(value);
      },
      textField: TextField(
        controller: _textEditingController,
        autofocus: true,
        textInputAction: TextInputAction.go,
        onSubmitted: (value) async {
          await createUser(value);
        },
      ),
      title: "Create new profile",
    );
  }
}
