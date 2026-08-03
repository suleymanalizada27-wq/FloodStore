import 'package:flutter/foundation.dart';

@immutable
class TenderBid {
  final String id;
  final String tenderId;
  final String sellerId; // mocked as string for now
  final int round;
  final double price;
  final int? deliveryDays; // nullable
  final DateTime submittedAt;

  const TenderBid({
    required this.id,
    required this.tenderId,
    required this.sellerId,
    required this.round,
    required this.price,
    this.deliveryDays,
    required this.submittedAt,
  });

  TenderBid copyWith({
    String? id,
    String? tenderId,
    String? sellerId,
    int? round,
    double? price,
    int? deliveryDays,
    DateTime? submittedAt,
  }) {
    return TenderBid(
      id: id ?? this.id,
      tenderId: tenderId ?? this.tenderId,
      sellerId: sellerId ?? this.sellerId,
      round: round ?? this.round,
      price: price ?? this.price,
      deliveryDays: deliveryDays ?? this.deliveryDays,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}
