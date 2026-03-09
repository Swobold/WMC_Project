class User {
  final int id;
  final String username;
  final String email;
  final int? familyId;
  final bool isEur;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.familyId,
    required this.isEur,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      familyId: json['family_id'] as int?,
      isEur: (json['isEur'] ?? json['is_eur'] ?? 1) == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'family_id': familyId,
        'isEur': isEur,
      };
}
