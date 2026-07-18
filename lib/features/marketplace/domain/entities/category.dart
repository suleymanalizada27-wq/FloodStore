import 'package:equatable/equatable.dart';

/// Represents a product category in the marketplace
class Category extends Equatable {
  final String id;
  final String name;
  final String? parentId; // null for root categories
  final int level; // 0 for root, 1 for subcategory, etc.
  final int sortOrder;
  final bool isActive;

  const Category({
    required this.id,
    required this.name,
    this.parentId,
    required this.level,
    required this.sortOrder,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        parentId,
        level,
        sortOrder,
        isActive,
      ];

  Category copyWith({
    String? id,
    String? name,
    String? parentId,
    int? level,
    int? sortOrder,
    bool? isActive,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      level: level ?? this.level,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Returns true if this is a root category (no parent)
  bool get isRoot => parentId == null;

  /// Returns true if this is a leaf category (no children)
  // Note: This would typically be determined by checking if any categories have this as parent
  // For now, we'll leave it as a property that can be set externally
}