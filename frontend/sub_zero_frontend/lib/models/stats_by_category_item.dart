class StatsByCategoryItem {
  final int categoryId;
  final String categoryName;
  final String colorHex;
  final String currency;
  final double sum;
  final double percent;

  StatsByCategoryItem({
    required this.categoryId,
    required this.categoryName,
    required this.colorHex,
    required this.currency,
    required this.sum,
    required this.percent,
  });

  factory StatsByCategoryItem.fromJson(Map<String, dynamic> json) {
    return StatsByCategoryItem(
      categoryId: json['category_id'] as int,
      categoryName: json['category_name'] as String,
      colorHex: json['color_hex'] as String,
      currency: json['currency'] as String,
      sum: (json['sum'] as num).toDouble(),
      percent: (json['percent'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'category_name': categoryName,
        'color_hex': colorHex,
        'currency': currency,
        'sum': sum,
        'percent': percent,
      };
}
