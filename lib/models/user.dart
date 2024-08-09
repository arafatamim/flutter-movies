class User {
  final int id;
  final String username;
  final bool admin;

  const User({required this.id, required this.username, required this.admin});

  User.fromJson(dynamic json)
      : id = json["id"] as int,
        username = json["username"] as String,
        admin = json["admin"] as bool;

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "admin": admin,
    };
  }

  @override
  bool operator ==(Object other) => other is User && id == other.id;

  @override
  int get hashCode => Object.hash(id, username, admin);
}
