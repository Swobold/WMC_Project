class StatsTotal {
  final int userId;
  final String currency;
  final double total;

  StatsTotal({
    required this.userId,
    required this.currency,
    required this.total,
  });

  factory StatsTotal.fromJson(Map<String, dynamic> json) {
    return StatsTotal(
      userId: json['userId'] as int,
      currency: json['currency'] as String,
      total: (json['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'currency': currency,
        'total': total,
      };
}
