class PurchaseRequestItem {
  final String id;
  final String description;
  final int quantity;
  final double unitPrice;
  final String unit; // e.g., 'pcs', 'kg', 'm'
  final String vendorSuggestion; // optional

  const PurchaseRequestItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.unit,
    this.vendorSuggestion = '',
  });

  double get totalPrice => quantity * unitPrice;

  PurchaseRequestItem copyWith({
    String? id,
    String? description,
    int? quantity,
    double? unitPrice,
    String? unit,
    String? vendorSuggestion,
  }) {
    return PurchaseRequestItem(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      unit: unit ?? this.unit,
      vendorSuggestion: vendorSuggestion ?? this.vendorSuggestion,
    );
  }
}