import 'package:async/async.dart';
import 'package:deferred_type_flutter/deferred_type_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_movies/models/trakt_code.dart';
import 'package:flutter_movies/models/trakt_token.dart';
import 'package:flutter_movies/services/trakt.dart';
import 'package:flutter_movies/services/user.dart';

class TraktSelector extends StatefulWidget {
  final bool activated;
  final int userId;
  final void Function() onChange;

  const TraktSelector({
    super.key,
    required this.activated,
    required this.userId,
    required this.onChange,
  });

  @override
  State<TraktSelector> createState() => _TraktSelectorState();
}

class _TraktSelectorState extends State<TraktSelector> {
  CancelableCompleter<TraktToken>? tokenOperation;

  final traktIcon = "assets/trakt.svg";

  void pollToken(BuildContext context, TraktCode code) {
    tokenOperation = RepositoryProvider.of<TraktService>(context, listen: false)
        .fetchToken(code);
    // Save token on receive
    tokenOperation?.operation.value.then((token) async {
      Navigator.of(context).pop();
      await RepositoryProvider.of<UserService>(context, listen: false)
          .saveTraktToken(
        widget.userId,
        token,
      );
      widget.onChange();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.activated) {
      return ListTile(
        title: const Text("Trakt account is connected"),
        subtitle: const Text("Tap to logout"),
        onTap: () async {
          await RepositoryProvider.of<UserService>(context, listen: false)
              .deleteTraktToken(widget.userId);
          widget.onChange();
        },
        leading: SvgPicture.asset(
          traktIcon,
          colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
        ),
      );
    } else {
      return ListTile(
        title: const Text("Connect your Trakt account"),
        subtitle: const Text(
          "To keep track of watched media, view watchlist, and more",
        ),
        leading: SvgPicture.asset(
          traktIcon,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        onTap: () => _startTraktAuth(context),
      );
    }
  }

  Future<void> _startTraktAuth(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: FutureBuilder2<TraktCode>(
            future: RepositoryProvider.of<TraktService>(context)
                .generateDeviceCodes(),
            builder: (context, state) {
              return state.maybeWhen(
                success: (code) {
                  pollToken(context, code);

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Go to"),
                          Text(
                            code.verificationUrl,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const Text("on your phone and enter the code below:"),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            code.userCode,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: 10),
                          const LinearProgressIndicator()
                        ],
                      ),
                    ),
                  );
                },
                error: (error, stackTrace) {
                  print(error);
                  return const SizedBox.shrink();
                },
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
        );
      },
    ).then((_) => tokenOperation?.operation.cancel());
  }
}
