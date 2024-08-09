import 'package:flutter/material.dart';
import 'package:flutter_movies/models/person.dart';
import 'package:flutter_movies/widgets/detail_shell.dart';

class PersonDetails extends StatelessWidget {
  final Person person;

  const PersonDetails(
    this.person, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DetailShell(
      title: person.name,
      description: person.biography,
      imageUris: person.imageUris,
    );
  }
}
