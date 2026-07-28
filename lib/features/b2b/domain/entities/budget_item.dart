class BudgetItem {
  final String id;
  final String name;
  final String description;
  final double amount; // in currency units
  final String category; // e.g., 'materials', 'labor', 'equipment'

  const BudgetItem({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.category,
  });

  BudgetItem copyWith({
    String? id,
    String? name,
    String? description,
    double? amount,
    String? category,
  }) {
    return BudgetItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
    );
  }
}