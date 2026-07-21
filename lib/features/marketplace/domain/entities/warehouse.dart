import 'package:equatable/equatable.dart';

/// Represents a warehouse or storage facility
class Warehouse extends Equatable {
  final String id;
  final String name;
  final String code; // Short code like 'WH001', 'NY-WEST'
  final String description;
  final String address; // Full address or reference to BusinessAddress
  final String contactPerson;
  final String contactPhone;
  final String contactEmail;
  final bool isActive; // Whether warehouse is operational
  final bool isDefault; // Default warehouse for new inventory
  final DateTime createdAt;
  final DateTime updatedAt;

  const Warehouse({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.address,
    required this.contactPerson,
    required this.contactPhone,
    required this.contactEmail,
    this.isActive = true,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        description,
        address,
        contactPerson,
        contactPhone,
        contactEmail,
        isActive,
        isDefault,
        createdAt,
        updatedAt,
      ];

  Warehouse copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    String? address,
    String? contactPerson,
    String? contactPhone,
    String? contactEmail,
    bool? isActive,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Warehouse(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      address: address ?? this.address,
      contactPerson: contactPerson ?? this.contactPerson,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'code': code,
      'description': description,
      'address': address,
      'contactPerson': contactPerson,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'isActive': isActive,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static Warehouse fromFirestore(Map<String, dynamic> data, String documentId) {
    return Warehouse(
      id: documentId,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      contactPerson: data['contactPerson'] ?? '',
      contactPhone: data['contactPhone'] ?? '',
      contactEmail: data['contactEmail'] ?? '',
      isActive: data['isActive'] ?? true,
      isDefault: data['isDefault'] ?? false,
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}