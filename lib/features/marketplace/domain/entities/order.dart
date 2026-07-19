import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a customer order
class Order extends Equatable {
  final String id;
  final String userId;
  final String? sellerId; // null for single-vendor orders, set for marketplace
  final OrderStatus status;
  final FulfillmentStatus fulfillmentStatus;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? placedAt;
  final DateTime? completedAt;
  final double subtotalAmount; // in cents
  final double taxAmount; // in cents
  final double shippingAmount; // in cents
  final double discountAmount; // in cents
  final double totalAmount; // in cents
  final String currency;
  final String? customerNotes;
  final String? internalNotes;
  final Address shippingAddress;
  final Address billingAddress;
  final List<OrderItem> items;
  final List<Discount> discounts;
  final PaymentInfo? payment;
  final ShippingInfo? tracking;
  final List<OrderHistoryEntry> history;

  const Order({
    required this.id,
    required this.userId,
    this.sellerId,
    required this.status,
    required this.fulfillmentStatus,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    this.placedAt,
    this.completedAt,
    required this.subtotalAmount,
    required this.taxAmount,
    required this.shippingAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.currency,
    this.customerNotes,
    this.internalNotes,
    required this.shippingAddress,
    required this.billingAddress,
    required this.items,
    required this.discounts,
    this.payment,
    this.tracking,
    required this.history,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        sellerId,
        status,
        fulfillmentStatus,
        paymentStatus,
        createdAt,
        updatedAt,
        placedAt,
        completedAt,
        subtotalAmount,
        taxAmount,
        shippingAmount,
        discountAmount,
        totalAmount,
        currency,
        customerNotes,
        internalNotes,
        shippingAddress,
        billingAddress,
        items,
        discounts,
        payment,
        tracking,
        history,
      ];

  Order copyWith({
    String? id,
    String? userId,
    String? sellerId,
    OrderStatus? status,
    FulfillmentStatus? fulfillmentStatus,
    PaymentStatus? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? placedAt,
    DateTime? completedAt,
    double? subtotalAmount,
    double? taxAmount,
    double? shippingAmount,
    double? discountAmount,
    double? totalAmount,
    String? currency,
    String? customerNotes,
    String? internalNotes,
    Address? shippingAddress,
    Address? billingAddress,
    List<OrderItem>? items,
    List<Discount>? discounts,
    PaymentInfo? payment,
    ShippingInfo? tracking,
    List<OrderHistoryEntry>? history,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sellerId: sellerId ?? this.sellerId,
      status: status ?? this.status,
      fulfillmentStatus: fulfillmentStatus ?? this.fulfillmentStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      placedAt: placedAt ?? this.placedAt,
      completedAt: completedAt ?? this.completedAt,
      subtotalAmount: subtotalAmount ?? this.subtotalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      shippingAmount: shippingAmount ?? this.shippingAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      customerNotes: customerNotes ?? this.customerNotes,
      internalNotes: internalNotes ?? this.internalNotes,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      items: items ?? this.items,
      discounts: discounts ?? this.discounts,
      payment: payment ?? this.payment,
      tracking: tracking ?? this.tracking,
      history: history ?? this.history,
    );
  }

  /// Calculates the total number of items in the order
  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Checks if the order can be cancelled based on current status
  bool get canCancel =>
      status == OrderStatus.pending ||
      status == OrderStatus.confirmed ||
      status == OrderStatus.processing;

  /// Checks if the order is delivered
  bool get isDelivered => status == OrderStatus.delivered;

  /// Converts to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'sellerId': sellerId,
      'status': status.name,
      'fulfillmentStatus': fulfillmentStatus.name,
      'paymentStatus': paymentStatus.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'placedAt': placedAt,
      'completedAt': completedAt,
      'subtotalAmount': subtotalAmount,
      'taxAmount': taxAmount,
      'shippingAmount': shippingAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'currency': currency,
      'customerNotes': customerNotes,
      'internalNotes': internalNotes,
      'shippingAddress': shippingAddress.toFirestore(),
      'billingAddress': billingAddress.toFirestore(),
      'items': items.map((item) => item.toFirestore()).toList(),
      'discounts': discounts.map((d) => d.toFirestore()).toList(),
      'payment': payment?.toFirestore(),
      'tracking': tracking?.toFirestore(),
      'history': history.map((h) => h.toFirestore()).toList(),
    };
  }

  /// Creates an Order from Firestore document data
  static Order fromFirestore(Map<String, dynamic> data, String documentId) {
    return Order(
      id: documentId,
      userId: data['userId'] ?? '',
      sellerId: data['sellerId'],
      status: OrderStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      fulfillmentStatus: FulfillmentStatus.values.firstWhere(
        (e) => e.name == data['fulfillmentStatus'],
        orElse: () => FulfillmentStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == data['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      placedAt: (data['placedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      subtotalAmount: (data['subtotalAmount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (data['taxAmount'] as num?)?.toDouble() ?? 0.0,
      shippingAmount: (data['shippingAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (data['discountAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] ?? 'USD',
      customerNotes: data['customerNotes'],
      internalNotes: data['internalNotes'],
      shippingAddress: Address.fromFirestore(data['shippingAddress'] as Map<String, dynamic>),
      billingAddress: Address.fromFirestore(data['billingAddress'] as Map<String, dynamic>),
      items: (data['items'] as List?)?.map((item) => OrderItem.fromFirestore(item as Map<String, dynamic>)).toList() ?? [],
      discounts: (data['discounts'] as List?)?.map((d) => Discount.fromFirestore(d as Map<String, dynamic>)).toList() ?? [],
      payment: data['payment'] != null ? PaymentInfo.fromFirestore(data['payment'] as Map<String, dynamic>) : null,
      tracking: data['tracking'] != null ? ShippingInfo.fromFirestore(data['tracking'] as Map<String, dynamic>) : null,
      history: (data['history'] as List?)?.map((h) => OrderHistoryEntry.fromFirestore(h as Map<String, dynamic>)).toList() ?? [],
    );
  }
}

enum OrderStatus {
  pending, // Order placed but not yet confirmed
  confirmed, // Order confirmed by seller/system
  processing, // Order being prepared
  shipped, // Order shipped to customer
  delivered, // Order received by customer
  cancelled, // Order cancelled by customer or system
  returned, // Order returned by customer
  failed, // Order failed
  refunded, // Order refunded
}

enum FulfillmentStatus {
  pending, // Not yet processed
  picked, // Items picked from inventory
  packed, // Items packed for shipment
  shipped, // Shipped to customer
  outForDelivery, // Out for final delivery
  delivered, // Delivered to customer
  returned, // Returned by customer
  cancelled, // Cancelled
}

enum PaymentStatus {
  pending, // Payment pending
  authorized, // Payment authorized but not captured
  captured, // Payment captured (charged)
  paid, // Alias for captured
  failed, // Payment failed
  refunded, // Fully refunded
  partiallyRefunded, // Partially refunded
}

class OrderItem extends Equatable {
  final String id;
  final String productId;
  final String? variantId; // null if product has no variants
  final int quantity;
  final double unitPrice; // price per unit in cents
  final double totalPrice; // quantity * unitPrice in cents
  final String productTitle;
  final Map<String, String> variantAttributes; // snapshot of variant attributes at time of purchase

  const OrderItem({
    required this.id,
    required this.productId,
    this.variantId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.productTitle,
    required this.variantAttributes,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        variantId,
        quantity,
        unitPrice,
        totalPrice,
        productTitle,
        variantAttributes,
      ];

  OrderItem copyWith({
    String? id,
    String? productId,
    String? variantId,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? productTitle,
    Map<String, String>? variantAttributes,
  }) {
    return OrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      productTitle: productTitle ?? this.productTitle,
      variantAttributes:
          variantAttributes ?? this.variantAttributes,
    );
  }

  /// Firestore conversion methods for [OrderItem]
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'productId': productId,
      'variantId': variantId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'productTitle': productTitle,
      'variantAttributes': variantAttributes,
    };
  }

  static OrderItem fromFirestore(Map<String, dynamic> data) {
    return OrderItem(
      id: data['id'] ?? '',
      productId: data['productId'] ?? '',
      variantId: data['variantId'],
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      productTitle: data['productTitle'] ?? '',
      variantAttributes: Map<String, String>.from(data['variantAttributes'] ?? {}),
    );
  }
}

class Discount extends Equatable {
  final String promoId;
  final String code;
  final DiscountType type;
  final double value; // percentage or fixed amount in cents
  final String? description;

  const Discount({
    required this.promoId,
    required this.code,
    required this.type,
    required this.value,
    this.description,
  });

  @override
  List<Object?> get props => [
        promoId,
        code,
        type,
        value,
        description,
      ];

  Discount copyWith({
    String? promoId,
    String? code,
    DiscountType? type,
    double? value,
    String? description,
  }) {
    return Discount(
      promoId: promoId ?? this.promoId,
      code: code ?? this.code,
      type: type ?? this.type,
      value: value ?? this.value,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'promoId': promoId,
      'code': code,
      'type': type.name,
      'value': value,
      'description': description,
    };
  }

  static Discount fromFirestore(Map<String, dynamic> data) {
    return Discount(
      promoId: data['promoId'] ?? '',
      code: data['code'] ?? '',
      type: DiscountType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => DiscountType.fixedAmount,
      ),
      value: (data['value'] as num?)?.toDouble() ?? 0.0,
      description: data['description'],
    );
  }
}

enum DiscountType { percentage, fixedAmount, freeShipping }

class PaymentInfo extends Equatable {
  final PaymentProvider provider;
  final String providerPaymentId;
  final String status; // provider-specific status
  final double amount; // in cents
  final String currency;
  final Map<String, dynamic>? details; // additional provider-specific data

  const PaymentInfo({
    required this.provider,
    required this.providerPaymentId,
    required this.status,
    required this.amount,
    required this.currency,
    this.details,
  });

  @override
  List<Object?> get props => [
        provider,
        providerPaymentId,
        status,
        amount,
        currency,
        details,
      ];

  PaymentInfo copyWith({
    PaymentProvider? provider,
    String? providerPaymentId,
    String? status,
    double? amount,
    String? currency,
    Map<String, dynamic>? details,
  }) {
    return PaymentInfo(
      provider: provider ?? this.provider,
      providerPaymentId: providerPaymentId ?? this.providerPaymentId,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      details: details ?? this.details,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'provider': provider.name,
      'providerPaymentId': providerPaymentId,
      'status': status,
      'amount': amount,
      'currency': currency,
      'details': details,
    };
  }

  static PaymentInfo fromFirestore(Map<String, dynamic> data) {
    return PaymentInfo(
      provider: PaymentProvider.values.firstWhere(
        (e) => e.name == data['provider'],
        orElse: () => PaymentProvider.stripe,
      ),
      providerPaymentId: data['providerPaymentId'] ?? '',
      status: data['status'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] ?? 'USD',
      details: data['details'] as Map<String, dynamic>?,
    );
  }
}

enum PaymentProvider { stripe, paypal, apple_pay, google_pay }

class ShippingInfo extends Equatable {
  final String carrier;
  final String trackingNumber;
  final DateTime? estimatedDelivery;
  final DateTime? actualDelivery;
  final List<TrackingEvent> events;

  const ShippingInfo({
    required this.carrier,
    required this.trackingNumber,
    this.estimatedDelivery,
    this.actualDelivery,
    required this.events,
  });

  @override
  List<Object?> get props => [
        carrier,
        trackingNumber,
        estimatedDelivery,
        actualDelivery,
        events,
      ];

  ShippingInfo copyWith({
    String? carrier,
    String? trackingNumber,
    DateTime? estimatedDelivery,
    DateTime? actualDelivery,
    List<TrackingEvent>? events,
  }) {
    return ShippingInfo(
      carrier: carrier ?? this.carrier,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      actualDelivery: actualDelivery ?? this.actualDelivery,
      events: events ?? this.events,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'carrier': carrier,
      'trackingNumber': trackingNumber,
      'estimatedDelivery': estimatedDelivery,
      'actualDelivery': actualDelivery,
      'events': events.map((e) => e.toFirestore()).toList(),
    };
  }

  static ShippingInfo fromFirestore(Map<String, dynamic> data) {
    return ShippingInfo(
      carrier: data['carrier'] ?? '',
      trackingNumber: data['trackingNumber'] ?? '',
      estimatedDelivery: (data['estimatedDelivery'] as Timestamp?)?.toDate(),
      actualDelivery: (data['actualDelivery'] as Timestamp?)?.toDate(),
      events: (data['events'] as List?)?.map((e) => TrackingEvent.fromFirestore(e as Map<String, dynamic>)).toList() ?? [],
    );
  }
}

class TrackingEvent extends Equatable {
  final DateTime timestamp;
  final String status;
  final String? location;
  final String description;

  const TrackingEvent({
    required this.timestamp,
    required this.status,
    this.location,
    required this.description,
  });

  @override
  List<Object?> get props => [
        timestamp,
        status,
        location,
        description,
      ];

  TrackingEvent copyWith({
    DateTime? timestamp,
    String? status,
    String? location,
    String? description,
  }) {
    return TrackingEvent(
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      location: location ?? this.location,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'timestamp': timestamp,
      'status': status,
      'location': location,
      'description': description,
    };
  }

  static TrackingEvent fromFirestore(Map<String, dynamic> data) {
    return TrackingEvent(
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? '',
      location: data['location'],
      description: data['description'] ?? '',
    );
  }
}

class OrderHistoryEntry extends Equatable {
  final DateTime timestamp;
  final String fromStatus;
  final String toStatus;
  final String changedBy; // userId or system
  final String? reason;
  final String? notes;

  const OrderHistoryEntry({
    required this.timestamp,
    required this.fromStatus,
    required this.toStatus,
    required this.changedBy,
    this.reason,
    this.notes,
  });

  @override
  List<Object?> get props => [
        timestamp,
        fromStatus,
        toStatus,
        changedBy,
        reason,
        notes,
      ];

  OrderHistoryEntry copyWith({
    DateTime? timestamp,
    String? fromStatus,
    String? toStatus,
    String? changedBy,
    String? reason,
    String? notes,
  }) {
    return OrderHistoryEntry(
      timestamp: timestamp ?? this.timestamp,
      fromStatus: fromStatus ?? this.fromStatus,
      toStatus: toStatus ?? this.toStatus,
      changedBy: changedBy ?? this.changedBy,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'timestamp': timestamp,
      'fromStatus': fromStatus,
      'toStatus': toStatus,
      'changedBy': changedBy,
      'reason': reason,
      'notes': notes,
    };
  }

  static OrderHistoryEntry fromFirestore(Map<String, dynamic> data) {
    return OrderHistoryEntry(
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fromStatus: data['fromStatus'] ?? '',
      toStatus: data['toStatus'] ?? '',
      changedBy: data['changedBy'] ?? '',
      reason: data['reason'],
      notes: data['notes'],
    );
  }
}

class Address extends Equatable {
  final String name;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String phone;

  const Address({
    required this.name,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.phone,
  });

  @override
  List<Object?> get props => [
        name,
        line1,
        line2,
        city,
        state,
        postalCode,
        country,
        phone,
      ];

  Address copyWith({
    String? name,
    String? line1,
    String? line2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? phone,
  }) {
    return Address(
      name: name ?? this.name,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'line1': line1,
      'line2': line2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'phone': phone,
    };
  }

  static Address fromFirestore(Map<String, dynamic> data) {
    return Address(
      name: data['name'] ?? '',
      line1: data['line1'] ?? '',
      line2: data['line2'],
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      postalCode: data['postalCode'] ?? '',
      country: data['country'] ?? '',
      phone: data['phone'] ?? '',
    );
  }

  /// Returns a formatted address string
  String get formattedAddress {
    final lines = [
      name,
      line1,
      if (line2 != null && line2!.isNotEmpty) line2,
      '$city, $state $postalCode',
      country,
    ];
    return lines.where((e) => e != null && (e is! String || e.isNotEmpty)).join('\n');
  }
}