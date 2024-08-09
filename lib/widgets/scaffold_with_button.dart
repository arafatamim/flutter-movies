import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_movies/utils.dart';

class ScaffoldWithButton extends StatelessWidget {
  final Widget child;
  final AppBar? appBar;

  const ScaffoldWithButton({
    required this.child,
    this.appBar,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: coalesceException(
        () => Platform.isLinux
            ? FloatingActionButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Icon(Icons.arrow_back),
              )
            : null,
        null,
      ),
      key: key,
      appBar: appBar,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniStartFloat,
      body: ProgressIndicatorTheme(
        data: ProgressIndicatorThemeData(
          color: Theme.of(context).colorScheme.secondary,
        ),
        child: child,
      ),
    );
  }
}
