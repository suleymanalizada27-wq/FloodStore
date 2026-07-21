import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Represents a Request for Quotation (RFQ) in the construction procurement process
class RFQ extends Equatable {
  final String id;
  final String buyerId; // Reference to BusinessAccount (buyer/contractor)
  final String? projectId; // Optional reference to construction project
  final String title; // Brief title/description of the RFQ
  final String description; // Detailed description of requirements
  final DateTime issueDate; // When the RFQ was issued
  final DateTime? responseDeadline; // Deadline for supplier responses
  final String status; // draft, issued, closed, awarded, cancelled
  final String? notes; // Internal notes from buyer
  final List<String>? tags; // Tags for categorization/search
  final Map<String, dynamic>? customFields; // Custom fields for specific industries
  final DateTime createdAt;
  final DateTime updatedAt;

  RFQ({
    String? id,
    required this.buyerId,
    this.projectId,
    required this.title,
    required this.description,
    DateTime? issueDate,
    this.responseDeadline,
    this.status = 'draft',
    this.notes,
    this.tags,
    this.customFields,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        issueDate = issueDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  List<Object?> get props => [
        id,
        buyerId,
        projectId,
        title,
        description,
        issueDate,
        responseDeadline,
        status,
        notes,
        tags,
        customFields,
        createdAt,
        updatedAt,
      ];

  RFQ copyWith({
    String? id,
    String? buyerId,
    String? projectId,
    String? title,
    String? description,
    DateTime? issueDate,
    DateTime? responseDeadline,
    String? status,
    String? notes,
    List<String>? tags,
    Map<String, dynamic>? customFields,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RFQ(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      issueDate: issueDate ?? this.issueDate,
      responseDeadline: responseDeadline ?? this.responseDeadline,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      customFields: customFields ?? this.customFields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'buyerId': buyerId,
      'projectId': projectId,
      'title': title,
      'description': description,
      'issueDate': issueDate.toIso8601String(),
      'responseDeadline': responseDeadline?.toIso8601String(),
      'status': status,
      'notes': notes,
      'tags': tags,
      'customFields': customFields,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static RFQ fromFirestore(Map<String, dynamic> data, String documentId) {
    return RFQ(
      id: documentId,
      buyerId: data['buyerId'] ?? '',
      projectId: data['projectId'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      issueDate: data['issueDate'] != null
          ? DateTime.parse(data['issueDate'])
          : DateTime.now(),
      responseDeadline: data['responseDeadline'] != null
          ? DateTime.parse(data['responseDeadline'])
          : null,
      status: data['status'] ?? 'draft',
      notes: data['notes'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      customFields: data['customFields'],
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'])
          : DateTime.now(),
    );
  }
}

/// Represents a line item within an RFQ
class RFQItem extends Equatable {
  final String id;
  final String rfqId; // Reference to parent RFQ
  final String? productId; // Reference to Product (if known)
  final String? categoryId; // Reference to Category (if product not specified)
  final String description; // Detailed description of item/service needed
  final String? specifications; // Technical specifications, standards, etc.
  final double quantity; // Quantity needed
  final String unitOfMeasure; // e.g., 'kg', 'm3', 'pieces', 'hours'
  final String? deliveryLocation; // Where items should be delivered
  final DateTime? deliveryDate; // When items are needed by
  final String? notes; // Additional notes for this line item
  final Map<String, dynamic>? customFields; // Custom fields for specific industries

  RFQItem({
    String? id,
    required this.rfqId,
    this.productId,
    this.categoryId,
    required this.description,
    this.specifications,
    required this.quantity,
    required this.unitOfMeasure,
    this.deliveryLocation,
    this.deliveryDate,
    this.notes,
    this.customFields,
  }) : id = id ?? const Uuid().v4();

  @override
  List<Object?> get props => [
        id,
        rfqId,
        productId,
        categoryId,
        description,
        specifications,
        quantity,
        unitOfMeasure,
        deliveryLocation,
        deliveryDate,
        notes,
        customFields,
      ];

  RFQItem copyWith({
    String? id,
    String? rfqId,
    String? productId,
    String? categoryId,
    String? description,
    String? specifications,
    double? quantity,
    String? unitOfMeasure,
    String? deliveryLocation,
    DateTime? deliveryDate,
    String? notes,
    Map<String, dynamic>? customFields,
  }) {
    return RFQItem(
      id: id ?? this.id,
      rfqId: rfqId ?? this.rfqId,
      productId: productId ?? this.productId,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      specifications: specifications ?? this.specifications,
      quantity: quantity ?? this.quantity,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      notes: notes ?? this.notes,
      customFields: customFields ?? this.customFields,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'rfqId': rfqId,
      'productId': productId,
      'categoryId': categoryId,
      'description': description,
      'specifications': specifications,
      'quantity': quantity,
      'unitOfMeasure': unitOfMeasure,
      'deliveryLocation': deliveryLocation,
      'deliveryDate': deliveryDate?.toIso8601String(),
      'notes': notes,
      'customFields': customFields,
    };
  }

  static RFQItem fromFirestore(Map<String, dynamic> data, String documentId) {
    return RFQItem(
      id: documentId,
      rfqId: data['rfqId'] ?? '',
      productId: data['productId'],
      categoryId: data['categoryId'],
      description: data['description'] ?? '',
      specifications: data['specifications'],
      quantity: (data['quantity'] as num?)?.toDouble() ?? 0,
      unitOfMeasure: data['unitOfMeasure'] ?? '',
      deliveryLocation: data['deliveryLocation'],
      deliveryDate: data['deliveryDate'] != null
          ? DateTime.parse(data['deliveryDate'])
          : null,
      notes: data['notes'],
      customFields: data['customFields'],
    );
  }
}

/// Represents a supplier's response/quote to an RFQ
class RFQResponse extends Equatable {
  final String id;
  final String rfqId; // Reference to the RFQ being responded to
  final String supplierId; // Reference to BusinessAccount (supplier/vendor)
  final DateTime responseDate; // When the response was submitted
  final String status; // draft, submitted, under_review, accepted, rejected
  final String? notes; // Supplier's notes about their quote
  final double? totalAmount; // Total quoted amount (in cents)
  final String? currency; // Currency code (USD, EUR, etc.)
  final DateTime? validUntil; // How long the quote is valid for
  final List<String>? attachedDocuments; // URLs to supporting documents
  final Map<String, dynamic>? customFields; // Custom fields for specific industries
  final DateTime createdAt;
  final DateTime updatedAt;

  RFQResponse({
    String? id,
    required this.rfqId,
    required this.supplierId,
    DateTime? responseDate,
    this.status = 'draft',
    this.notes,
    this.totalAmount,
    this.currency,
    this.validUntil,
    this.attachedDocuments,
    this.customFields,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        responseDate = responseDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  @override
  List<Object?> get props => [
        id,
        rfqId,
        supplierId,
        responseDate,
        status,
        notes,
        totalAmount,
        currency,
        validUntil,
        attachedDocuments,
        customFields,
        createdAt,
        updatedAt,
      ];

  RFQResponse copyWith({
    String? id,
    String? rfqId,
    String? supplierId,
    DateTime? responseDate,
    String? status,
    String? notes,
    double? totalAmount,
    String? currency,
    DateTime? validUntil,
    List<String>? attachedDocuments,
    Map<String, dynamic>? customFields,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RFQResponse(
      id: id ?? this.id,
      rfqId: rfqId ?? this.rfqId,
      supplierId: supplierId ?? this.supplierId,
      responseDate: responseDate ?? this.responseDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      validUntil: validUntil ?? this.validUntil,
      attachedDocuments: attachedDocuments ?? this.attachedDocuments,
      customFields: customFields ?? this.customFields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'rfqId': rfqId,
      'supplierId': supplierId,
      'responseDate': responseDate.toIso8601String(),
      'status': status,
      'notes': notes,
      'totalAmount': totalAmount,
      'currency': currency,
      'validUntil': validUntil?.toIso8601String(),
      'attachedDocuments': attachedDocuments,
      'customFields': customFields,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static RFQResponse fromFirestore(Map<String, dynamic> data, String documentId) {
    return RFQResponse(
      id: documentId,
      rfqId: data['rfqId'] ?? '',
      supplierId: data['supplierId'] ?? '',
      responseDate: data['responseDate'] != null
          ? DateTime.parse(data['responseDate'])
          : DateTime.now(),
      status: data['status'] ?? 'draft',
      notes: data['notes'],
      totalAmount: (data['totalAmount'] as num?)?.toDouble(),
      currency: data['currency'],
      validUntil: data['validUntil'] != null
          ? DateTime.parse(data['validUntil'])
          : null,
      attachedDocuments: data['attachedDocuments'] != null
          ? List<String>.from(data['attachedDocuments'])
          : null,
      customFields: data['customFields'],
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'])
          : DateTime.now(),
    );
  }
}

/// Represents a line item within an RFQ response (supplier's quote for a specific RFQ item)
class RFQResponseItem extends Equatable {
  final String id;
  final String rfqResponseId; // Reference to parent RFQ response
  final String rfqItemId; // Reference to the RFQ item being quoted
  final String? supplierProductId; // Supplier's internal product ID (if different)
  final String? supplierProductName; // Supplier's product name/description
  final double quantityQuoted; // Quantity supplier is quoting
  final String unitOfMeasure; // Should match RFQ item's unit of measure
  final double unitPrice; // Price per unit (in cents)
  final double totalPrice; // quantityQuoted * unitPrice (in cents)
  final String? notes; // Supplier's notes about this line item
  final int? leadTimeDays; // Delivery lead time in days
  final String? warrantyInfo; // Warranty information
  final Map<String, dynamic>? customFields; // Custom fields for specific industries

  RFQResponseItem({
    String? id,
    required this.rfqResponseId,
    required this.rfqItemId,
    this.supplierProductId,
    this.supplierProductName,
    required this.quantityQuoted,
    required this.unitOfMeasure,
    required this.unitPrice,
    required this.totalPrice,
    this.notes,
    this.leadTimeDays,
    this.warrantyInfo,
    this.customFields,
  }) : id = id ?? const Uuid().v4();

  @override
  List<Object?> get props => [
        id,
        rfqResponseId,
        rfqItemId,
        supplierProductId,
        supplierProductName,
        quantityQuoted,
        unitOfMeasure,
        unitPrice,
        totalPrice,
        notes,
        leadTimeDays,
        warrantyInfo,
        customFields,
      ];

  RFQResponseItem copyWith({
    String? id,
    String? rfqResponseId,
    String? rfqItemId,
    String? supplierProductId,
    String? supplierProductName,
    double? quantityQuoted,
    String? unitOfMeasure,
    double? unitPrice,
    double? totalPrice,
    String? notes,
    int? leadTimeDays,
    String? warrantyInfo,
    Map<String, dynamic>? customFields,
  }) {
    return RFQResponseItem(
      id: id ?? this.id,
      rfqResponseId: rfqResponseId ?? this.rfqResponseId,
      rfqItemId: rfqItemId ?? this.rfqItemId,
      supplierProductId: supplierProductId ?? this.supplierProductId,
      supplierProductName: supplierProductName ?? this.supplierProductName,
      quantityQuoted: quantityQuoted ?? this.quantityQuoted,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      notes: notes ?? this.notes,
      leadTimeDays: leadTimeDays ?? this.leadTimeDays,
      warrantyInfo: warrantyInfo ?? this.warrantyInfo,
      customFields: customFields ?? this.customFields,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'rfqResponseId': rfqResponseId,
      'rfqItemId': rfqItemId,
      'supplierProductId': supplierProductId,
      'supplierProductName': supplierProductName,
      'quantityQuoted': quantityQuoted,
      'unitOfMeasure': unitOfMeasure,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'notes': notes,
      'leadTimeDays': leadTimeDays,
      'warrantyInfo': warrantyInfo,
      'customFields': customFields,
    };
  }

  static RFQResponseItem fromFirestore(Map<String, dynamic> data, String documentId) {
    return RFQResponseItem(
      id: documentId,
      rfqResponseId: data['rfqResponseId'] ?? '',
      rfqItemId: data['rfqItemId'] ?? '',
      supplierProductId: data['supplierProductId'],
      supplierProductName: data['supplierProductName'],
      quantityQuoted: (data['quantityQuoted'] as num?)?.toDouble() ?? 0,
      unitOfMeasure: data['unitOfMeasure'] ?? '',
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0,
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0,
      notes: data['notes'],
      leadTimeDays: (data['leadTimeDays'] as int?)?.toInt(),
      warrantyInfo: data['warrantyInfo'],
      customFields: data['customFields'],
    );
  }
}