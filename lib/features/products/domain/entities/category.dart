import 'package:equatable/equatable.dart';

/// Represents a product category in the shopping catalog.
class Category extends Equatable {
  final String id;
  final String name;
  final String iconName;
  final int productCount;

  const Category({
    required this.id,
    required this.name,
    required this.iconName,
    this.productCount = 0,
  });

  @override
  List<Object?> get props => [id, name, iconName, productCount];
}
