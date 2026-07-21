import 'package:equatable/equatable.dart';
import '../../../../core/enums/inventory_status.dart';

/// Represents a specific batch, lot, or serial number of inventory
class InventoryItem extends Equatable {
  final String id;
  final String productId; // Reference to Product
  final String warehouseId; // Reference to Warehouse
  final String? batchNumber; // For materials: lot, heat, pour number
  final String? serialNumber; // For equipment: unique identifier
  final double quantity; // Available quantity
  final double reservedQuantity; // Quantity reserved in carts/orders
  final String unitOfMeasure; // e.g., 'kg', 'ton', 'piece', 'm3', 'ft3'
  final InventoryStatus status; // available, reserved, quarantined, etc.
  final DateTime? receivedDate; // When received into warehouse
  final DateTime? expiryDate; // For perishable materials
  final DateTime? manufacturingDate; // Production date
  final List<String>? certifications; // Batch-specific certifications
  final Map<String, dynamic>? testResults; // e.g., concrete slump, strength
  final String? locationDetails; // Bin, shelf, aisle within warehouse
  final double? unitCost; // Cost per unit in cents
  final String? supplierId; // Reference to supplier/business account
  final DateTime createdAt;
  final DateTime updatedAt;

  const InventoryItem({
    required this.id,
    required this.productId,
    required this.warehouseId,
    this.batchNumber,
    this.serialNumber,
    required this.quantity,
    this.reservedQuantity = 0,
    required this.unitOfMeasure,
    this.status = InventoryStatus.available,
    this.receivedDate,
    this.expiryDate,
    this.manufacturingDate,
    this.certifications,
    this.testResults,
    this.locationDetails,
    this.unitCost,
    this.supplierId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        warehouseId,
        batchNumber,
        serialNumber,
        quantity,
        reservedQuantity,
        unitOfMeasure,
        status,
        receivedDate,
        expiryDate,
        manufacturingDate,
        certifications,
        testResults,
        locationDetails,
        unitCost,
        supplierId,
        createdAt,
        updatedAt,
      ];

  double get availableQuantity => quantity - reservedQuantity;

  bool get isAvailable => status == InventoryStatus.available && availableQuantity > 0;

  bool get isReserved => reservedQuantity > 0;

  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());

  InventoryItem copyWith({
    String? id,
    String? productId,
    String? warehouseId,
    String? batchNumber,
    String? serialNumber,
    double? quantity,
    double? reservedQuantity,
    String? unitOfMeasure,
    InventoryStatus? status,
    DateTime? receivedDate,
    DateTime? expiryDate,
    DateTime? manufacturingDate,
    List<String>? certifications,
    Map<String, dynamic>? testResults,
    String? locationDetails,
    double? unitCost,
    String? supplierId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      warehouseId: warehouseId ?? this.warehouseId,
      batchNumber: batchNumber ?? this.batchNumber,
      serialNumber: serialNumber ?? this.serialNumber,
      quantity: quantity ?? this.quantity,
      reservedQuantity: reservedQuantity ?? this.reservedQuantity,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      status: status ?? this.status,
      receivedDate: receivedDate ?? this.receivedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      manufacturingDate: manufacturingDate ?? this.manufacturingDate,
      certifications: certifications ?? this.certifications,
      testResults: testResults ?? this.testResults,
      locationDetails: locationDetails ?? this.locationDetails,
      unitCost: unitCost ?? this.unitCost,
      supplierId: supplierId ?? this.supplierId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'warehouseId': warehouseId,
      'batchNumber': batchNumber,
      'serialNumber': serialNumber,
      'quantity': quantity,
      'reservedQuantity': reservedQuantity,
      'unitOfMeasure': unitOfMeasure,
      'status': status.name,
      'receivedDate': receivedDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'manufacturingDate': manufacturingDate?.toIso8601String(),
      'certifications': certifications,
      'testResults': testResults,
      'locationDetails': locationDetails,
      'unitCost': unitCost,
      'supplierId': supplierId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static InventoryItem fromFirestore(Map<String, dynamic> data, String documentId) {
    return InventoryItem(
      id: documentId,
      productId: data['productId'] ?? '',
      warehouseId: data['warehouseId'] ?? '',
      batchNumber: data['batchNumber'],
      serialNumber: data['serialNumber'],
      quantity: (data['quantity'] as num?)?.toDouble() ?? 0.0,
      reservedQuantity: (data['reservedQuantity'] as num?)?.toDouble() ?? 0.0,
      unitOfMeasure: data['unitOfMeasure'] ?? '',
      status: InventoryStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => InventoryStatus.available,
      ),
      receivedDate: data['receivedDate'] != null
          ? DateTime.parse(data['receivedDate'])
          : null,
      expiryDate: data['expiryDate'] != null
          ? DateTime.parse(data['expiryDate'])
          : null,
      manufacturingDate: data['manufacturingDate'] != null
          ? DateTime.parse(data['manufacturingDate'])
          : null,
      certifications: data['certifications'] != null
          ? List<String>.from(data['certifications'])
          : null,
      testResults: data['testResults'] as Map<String, dynamic>?,
      locationDetails: data['locationDetails'],
      unitCost: (data['unitCost'] as num?)?.toDouble(),
      supplierId: data['supplierId'],
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}