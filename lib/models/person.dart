import 'package:flutter/material.dart';

import 'package:flutter_movies/models/models.dart';

@immutable
class PersonResult {
  final String id;
  final String name;
  final String gender;
  final String department;
  final ImageUris imageUris;
  const PersonResult({
    required this.id,
    required this.name,
    required this.gender,
    required this.department,
    required this.imageUris,
  });

  PersonResult copyWith({
    String? id,
    String? name,
    String? gender,
    String? department,
    ImageUris? imageUris,
  }) {
    return PersonResult(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      department: department ?? this.department,
      imageUris: imageUris ?? this.imageUris,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'department': department,
      'imageUris': imageUris.toMap(),
    };
  }

  factory PersonResult.fromMap(dynamic map) {
    return PersonResult(
      id: map['id'] as String,
      name: map['name'] as String,
      gender: map['gender'] as String,
      department: map['department'] as String,
      imageUris: ImageUris.fromMap(map['imageUris']),
    );
  }

  @override
  String toString() {
    return 'PersonResult(id: $id, name: $name, gender: $gender, department: $department, imageUris: $imageUris)';
  }
}

@immutable
class Person {
  final String id;
  final String name;
  final String biography;
  final String gender;
  final String? birthplace;
  final ImageUris imageUris;
  final String department;

  const Person({
    required this.id,
    required this.name,
    required this.biography,
    required this.gender,
    this.birthplace,
    required this.imageUris,
    required this.department,
  });

  Person copyWith({
    String? id,
    String? name,
    String? biography,
    String? gender,
    String? birthplace,
    ImageUris? imageUris,
    String? department,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      biography: biography ?? this.biography,
      gender: gender ?? this.gender,
      birthplace: birthplace ?? this.birthplace,
      imageUris: imageUris ?? this.imageUris,
      department: department ?? this.department,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'biography': biography,
      'gender': gender,
      'birthplace': birthplace,
      'imageUris': imageUris.toMap(),
      'department': department,
    };
  }

  factory Person.fromMap(dynamic map) {
    return Person(
      id: map['id'] as String,
      name: map['name'] as String,
      biography: map['biography'] as String,
      gender: map['gender'] as String,
      birthplace: map['birthplace'] as String?,
      imageUris: ImageUris.fromMap(map['imageUris']),
      department: map['department'] as String,
    );
  }

  @override
  String toString() {
    return 'Person(id: $id, name: $name, biography: $biography, gender: $gender, birthplace: $birthplace, imageUris: $imageUris, department: $department)';
  }
}
