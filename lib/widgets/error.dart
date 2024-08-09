import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_movies/models/models.dart';

class ErrorMessage extends StatelessWidget {
  final Object? error;

  const ErrorMessage(this.error, {super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(height: 110),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                FeatherIcons.frown,
                size: 28,
              ),
              const SizedBox(height: 10),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(height: 1.1),
              )
            ],
          ),
        ),
      ),
    );
  }

  String get errorMessage => error is DioException
      ? (error as DioException).message ?? "Unknown HTTP client exception"
      : error is ServerError
          ? (error as ServerError).message
          : error is String
              ? (error as String)
              : "Unhandled error. Contact system administrator.";
}
