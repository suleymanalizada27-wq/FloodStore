import 'package:flutter/foundation.dart';

@immutable
class TenderParticipant {
  final String id;
  final String tenderId;
  final String sellerId; // mocked as string for now

  const TenderParticipant({
    required this.id,
    required this.tenderId,
    required this.sellerId,
  });

  TenderParticipant copyWith({
    String? id,
    String? tenderId,
    String? sellerId,
  }) {
    return TenderParticipant(
      id: id ?? this.id,
      tenderId: tenderId ?? this.tenderId,
      sellerId: sellerId ?? this.sellerId,
    );
  }
}
