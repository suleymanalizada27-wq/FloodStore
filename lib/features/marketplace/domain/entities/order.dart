import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

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

  /// Checks if the order is paid
  bool get isPaid =>
      paymentStatus == PaymentStatus.captured ||
      paymentStatus == PaymentStatus.partially_refunded;
}

enum OrderStatus {
  pending, // Order placed but not yet confirmed
  confirmed, // Order confirmed by seller/system
  processing, // Order being prepared
  shipped, // Order shipped to customer
  delivered, // Order received by customer
  cancelled, // Order cancelled by customer or system
  returned, // Order returned by customer
}

enum FulfillmentStatus {
  pending, // Not yet processed
  picked, // Items picked from inventory
  packed, // Items packed for shipment
  shipped, // Shipped to customer
  out_for_delivery, // Out for final delivery
  delivered, // Delivered to customer
}

enum PaymentStatus {
  pending, // Payment pending
  authorized, // Payment authorized but not captured
  captured, // Payment captured (charged)
  failed, // Payment failed
  refunded, // Fully refunded
  partially_refunded, // Partially refunded
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
}

enum DiscountType { percentage, fixed_amount, free_shipping }

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