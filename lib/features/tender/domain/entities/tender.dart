import 'package:flutter/foundation.dart';

enum TenderMode { open, sealed, reverseAuction, multiRound }
enum TenderStatus { open, evaluating, awarded, cancelled }

@immutable
class Tender {
  final String id;
  final String? rfqId;
  final TenderMode mode;
  final int currentRound;
  final TenderStatus status;
  final DateTime createdAt;

  const Tender({
    required this.id,
    this.rfqId,
    required this.mode,
    required this.currentRound,
    required this.status,
    required this.createdAt,
  });

  Tender copyWith({
    String? id,
    String? rfqId,
    TenderMode? mode,
    int? currentRound,
    TenderStatus? status,
    DateTime? createdAt,
  }) {
    return Tender(
      id: id ?? this.id,
      rfqId: rfqId ?? this.rfqId,
      mode: mode ?? this.mode,
      currentRound: currentRound ?? this.currentRound,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
