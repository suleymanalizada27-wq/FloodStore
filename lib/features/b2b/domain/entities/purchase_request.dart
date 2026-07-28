import 'package:floodstore/features/b2b/domain/entities/purchase_request_item.dart';

class PurchaseRequest {
  final String id;
  final String projectId;
  final String phaseId;
  final String requesterId;
  final DateTime requestDate;
  final String status; // e.g., 'pending', 'approved', 'rejected', 'ordered'
  final List<PurchaseRequestItem> items;

  const PurchaseRequest({
    required this.id,
    required this.projectId,
    required this.phaseId,
    required this.requesterId,
    required this.requestDate,
    required this.status,
    required this.items,
  });

  PurchaseRequest copyWith({
    String? id,
    String? projectId,
    String? phaseId,
    String? requesterId,
    DateTime? requestDate,
    String? status,
    List<PurchaseRequestItem>? items,
  }) {
    return PurchaseRequest(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      phaseId: phaseId ?? this.phaseId,
      requesterId: requesterId ?? this.requesterId,
      requestDate: requestDate ?? this.requestDate,
      status: status ?? this.status,
      items: items ?? this.items,
    );
  }
}