import 'package:floodstore/features/b2b/domain/entities/budget_item.dart';

class Budget {
  final String id;
  final String name;
  final String description;
  final List<BudgetItem> items;

  const Budget({
    required this.id,
    required this.name,
    required this.description,
    required this.items,
  });

  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.amount);

  Budget copyWith({
    String? id,
    String? name,
    String? description,
    List<BudgetItem>? items,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      items: items ?? this.items,
    );
  }
}