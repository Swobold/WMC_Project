class Category {
  final int id;
  final String name;
  final String colorHex;

  Category({
    required this.id,
    required this.name,
    required this.colorHex,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      colorHex: json['color_hex'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color_hex': colorHex,
      };
}
