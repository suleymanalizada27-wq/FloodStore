import 'package:floodstore/features/b2b/domain/entities/project.dart';
import 'package:floodstore/features/b2b/domain/entities/purchase_request.dart';

abstract class ProjectRepository {
  Future<List<Project>> getProjects(String organizationId);
  Future<Project> createProject(Project project);
  Future<Project> getProjectDetail(String projectId);
  Future<PurchaseRequest> createPurchaseRequest(PurchaseRequest purchaseRequest);
  Future<PurchaseRequest> approvePurchaseRequest(String requestId);
  Future<PurchaseRequest> rejectPurchaseRequest(String requestId, String reason);
}