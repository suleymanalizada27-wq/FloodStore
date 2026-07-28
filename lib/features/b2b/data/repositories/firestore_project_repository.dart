import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floodstore/features/b2b/domain/entities/project.dart';
import 'package:floodstore/features/b2b/domain/entities/project_phase.dart';
import 'package:floodstore/features/b2b/domain/entities/purchase_request.dart';
import 'package:floodstore/features/b2b/domain/entities/purchase_request_item.dart';
import 'package:floodstore/features/b2b/domain/repositories/project_repository.dart';

class FirestoreProjectRepository implements ProjectRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Project>> getProjects(String organizationId) async {
    final snapshot = await _firestore
        .collection('organizations')
        .doc(organizationId)
        .collection('projects')
        .get();

    return snapshot.docs.map((doc) => _projectFromSnapshot(doc)).toList();
  }

  @override
  Future<Project> createProject(Project project) async {
    final docRef = await _firestore
        .collection('organizations')
        .doc(project.organizationId)
        .collection('projects')
        .add(_projectToMap(project));

    final doc = await docRef.get();
    return _projectFromSnapshot(doc);
  }

  @override
  Future<Project> getProjectDetail(String projectId) async {
    // In a real implementation, we would need to know the organizationId too
    // For now, we'll search across all organizations (not ideal but works for demo)
    final querySnapshot = await _firestore
        .collectionGroup('projects')
        .where(FieldPath.documentId, isEqualTo: projectId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Project not found');
    }

    return _projectFromSnapshot(querySnapshot.docs.first);
  }

  @override
  Future<PurchaseRequest> createPurchaseRequest(PurchaseRequest purchaseRequest) async {
    final docRef = await _firestore
        .collection('purchase_requests')
        .add(_purchaseRequestToMap(purchaseRequest));

    final doc = await docRef.get();
    return _purchaseRequestFromSnapshot(doc);
  }

  @override
  Future<PurchaseRequest> approvePurchaseRequest(String requestId) async {
    final docRef = _firestore.collection('purchase_requests').doc(requestId);
    await docRef.update({'status': 'approved'});
    final doc = await docRef.get();
    return _purchaseRequestFromSnapshot(doc);
  }

  @override
  Future<PurchaseRequest> rejectPurchaseRequest(String requestId, String reason) async {
    final docRef = _firestore.collection('purchase_requests').doc(requestId);
    await docRef.update({
      'status': 'rejected',
      'rejection_reason': reason,
    });
    final doc = await docRef.get();
    return _purchaseRequestFromSnapshot(doc);
  }

  Project _projectFromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Project(
      id: doc.id,
      organizationId: data['organizationId'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      status: data['status'] as String,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : null,
      phases: (data['phases'] as List<dynamic>?)
          ?.map((phase) => _projectPhaseFromMap(phase as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> _projectToMap(Project project) {
    return {
      'organizationId': project.organizationId,
      'name': project.name,
      'description': project.description,
      'status': project.status,
      'startDate': Timestamp.fromDate(project.startDate),
      'endDate': project.endDate != null ? Timestamp.fromDate(project.endDate!) : null,
      'phases': project.phases.map((phase) => _projectPhaseToMap(phase)).toList(),
    };
  }

  ProjectPhase _projectPhaseFromMap(Map<String, dynamic> data) {
    return ProjectPhase(
      id: data['id'] as String,
      projectId: data['projectId'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : null,
      budget: (data['budget'] as num).toDouble(),
      status: data['status'] as String,
    );
  }

  Map<String, dynamic> _projectPhaseToMap(ProjectPhase phase) {
    return {
      'id': phase.id,
      'projectId': phase.projectId,
      'name': phase.name,
      'description': phase.description,
      'startDate': Timestamp.fromDate(phase.startDate),
      'endDate': phase.endDate != null ? Timestamp.fromDate(phase.endDate!) : null,
      'budget': phase.budget,
      'status': phase.status,
    };
  }

  PurchaseRequest _purchaseRequestFromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PurchaseRequest(
      id: doc.id,
      projectId: data['projectId'] as String,
      phaseId: data['phaseId'] as String,
      requesterId: data['requesterId'] as String,
      requestDate: (data['requestDate'] as Timestamp).toDate(),
      status: data['status'] as String,
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => _purchaseRequestItemFromMap(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> _purchaseRequestToMap(PurchaseRequest request) {
    return {
      'projectId': request.projectId,
      'phaseId': request.phaseId,
      'requesterId': request.requesterId,
      'requestDate': Timestamp.fromDate(request.requestDate),
      'status': request.status,
      'items': request.items.map((item) => _purchaseRequestItemToMap(item)).toList(),
    };
  }

  PurchaseRequestItem _purchaseRequestItemFromMap(Map<String, dynamic> data) {
    return PurchaseRequestItem(
      id: data['id'] as String,
      description: data['description'] as String,
      quantity: data['quantity'] as int,
      unitPrice: (data['unitPrice'] as num).toDouble(),
      unit: data['unit'] as String,
      vendorSuggestion: data['vendorSuggestion'] as String? ?? '',
    );
  }

  Map<String, dynamic> _purchaseRequestItemToMap(PurchaseRequestItem item) {
    return {
      'id': item.id,
      'description': item.description,
      'quantity': item.quantity,
      'unitPrice': item.unitPrice,
      'unit': item.unit,
      'vendorSuggestion': item.vendorSuggestion,
    };
  }
}

// Budget and BudgetItem repository methods would go here in a complete implementation
// For now, we'll focus on the core project functionality