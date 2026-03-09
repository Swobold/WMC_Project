class Family {
  final int id;
  final String name;
  final String inviteCode;

  Family({
    required this.id,
    required this.name,
    required this.inviteCode,
  });

  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
      id: json['id'] as int,
      name: json['name'] as String,
      inviteCode: json['invite_code'] as String,
    );
  }
}

class FamilyMember {
  final int id;
  final String username;
  final String email;

  FamilyMember({
    required this.id,
    required this.username,
    required this.email,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
    );
  }
}

class FamilyMemberWithStats extends FamilyMember {
  final double sum;
  final String currency;

  FamilyMemberWithStats({
    required super.id,
    required super.username,
    required super.email,
    required this.sum,
    required this.currency,
  });

  factory FamilyMemberWithStats.fromJson(Map<String, dynamic> json) {
    return FamilyMemberWithStats(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      sum: (json['sum'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'EUR',
    );
  }
}
