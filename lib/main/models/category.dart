// Models
class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int questionCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.questionCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      icon: json['icon'] ?? '📚',
      questionCount: json['questionCount'] ?? 0,
    );
  }
}
