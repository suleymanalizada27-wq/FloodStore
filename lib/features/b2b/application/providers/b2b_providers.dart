import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:floodstore/features/b2b/domain/entities/project.dart';
import 'package:floodstore/features/b2b/domain/entities/purchase_request.dart';
import 'package:floodstore/features/b2b/domain/repositories/project_repository.dart';
import 'package:floodstore/features/b2b/data/repositories/mock_project_repository.dart';
import 'package:floodstore/features/auth/application/providers/auth_providers.dart';

// Provider for the project repository
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  // TODO: replace with SupabaseProjectRepository once Supabase project is provisioned
  // (see docs/decisions/ADR-004-PAYMENTS.md, docs/database/12_MIGRATIONS.md)
  return MockProjectRepository();
});

// Provider for getting projects for an organization
final projectsProvider = FutureProvider.family<List<Project>, String>((ref, organizationId) {
  final repository = ref.read(projectRepositoryProvider);
  return repository.getProjects(organizationId);
});

// Provider for getting a single project detail
final projectDetailProvider = FutureProvider.family<Project, String>((ref, projectId) {
  final repository = ref.read(projectRepositoryProvider);
  return repository.getProjectDetail(projectId);
});

// Provider for creating a purchase request
final createPurchaseRequestProvider = Provider<Future<PurchaseRequest> Function(PurchaseRequest)>((ref) {
  final repository = ref.read(projectRepositoryProvider);
  return (purchaseRequest) => repository.createPurchaseRequest(purchaseRequest);
});

// Provider for approving a purchase request
final approvePurchaseRequestProvider = Provider<Future<PurchaseRequest> Function(String)>((ref) {
  final repository = ref.read(projectRepositoryProvider);
  return (requestId) => repository.approvePurchaseRequest(requestId);
});

// Provider for rejecting a purchase request
final rejectPurchaseRequestProvider = Provider<Future<PurchaseRequest> Function(String, String)>((ref) {
  final repository = ref.read(projectRepositoryProvider);
  return (requestId, reason) => repository.rejectPurchaseRequest(requestId, reason);
});

// Provider for getting pending approval requests
final pendingApprovalRequestsProvider =
    FutureProvider.family<List<PurchaseRequest>, String>((ref, organizationId) {
  final repository = ref.read(projectRepositoryProvider);
  // For now, we'll get all projects and filter for pending requests
  // In a real implementation, we'd have a dedicated method for this
  return repository.getProjects(organizationId).then((projects) {
    // This is a simplified implementation - in reality, we'd query purchase requests directly
    // For now, returning empty list as we don't have a direct method to get pending requests
    return [];
  });
});

// Provider for current user ID (shared from auth)
final currentUserIdProvider = Provider<String?>((ref) {
  final asyncUser = ref.watch(authStateChangesProvider);
  return asyncUser.value?.id;
});