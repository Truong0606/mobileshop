import 'package:smart_shopping_chatbot/features/products/domain/entities/category.dart';

/// API response model for category data from `GET /api/v1/categories`.
class CategoryModel extends Category {
  final String? description;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  const CategoryModel({
    required super.id,
    required super.name,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
  }) : super(
          iconName: 'category', // Default fallback
          productCount: 0,
        );

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
