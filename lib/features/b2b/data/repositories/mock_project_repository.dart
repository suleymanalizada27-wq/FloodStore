import 'package:flutter/foundation.dart';
import 'package:floodstore/features/b2b/domain/entities/budget.dart';
import 'package:floodstore/features/b2b/domain/entities/budget_item.dart';
import 'package:floodstore/features/b2b/domain/entities/project.dart';
import 'package:floodstore/features/b2b/domain/entities/project_phase.dart';
import 'package:floodstore/features/b2b/domain/entities/purchase_request.dart';
import 'package:floodstore/features/b2b/domain/entities/purchase_request_item.dart';
import 'package:floodstore/features/b2b/domain/repositories/project_repository.dart';

/// Mock implementation of ProjectRepository using in-memory lists
/// TODO: replace with SupabaseProjectRepository once Supabase project is provisioned
/// (see docs/decisions/ADR-004-PAYMENTS.md, docs/database/12_MIGRATIONS.md)
class MockProjectRepository implements ProjectRepository {
  // In-memory storage
  final Map<String, Project> _projects = {};
  final Map<String, List<ProjectPhase>> _projectPhases = {};
  final Map<String, Budget> _projectBudgets = {};
  final Map<String, List<BudgetItem>> _budgetItems = {};
  final Map<String, PurchaseRequest> _purchaseRequests = {};
  final Map<String, List<PurchaseRequestItem>> _purchaseRequestItems = {};

  // ID generators
  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  @override
  Future<List<Project>> getProjects(String organizationId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _projects.values
        .where((project) => project.organizationId == organizationId)
        .toList();
  }

  @override
  Future<Project> createProject(Project project) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final id = _generateId();
    final newProject = project.copyWith(id: id);
    _projects[id] = newProject;
    _projectPhases[id] = [];

    return newProject;
  }

  @override
  Future<Project> getProjectDetail(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final project = _projects[projectId];
    if (project == null) {
      throw Exception('Project not found');
    }
    return project;
  }

  @override
  Future<PurchaseRequest> createPurchaseRequest(PurchaseRequest purchaseRequest) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final id = _generateId();
    final newRequest = purchaseRequest.copyWith(id: id);
    _purchaseRequests[id] = newRequest;
    _purchaseRequestItems[id] = newRequest.items;

    return newRequest;
  }

  @override
  Future<PurchaseRequest> approvePurchaseRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final request = _purchaseRequests[requestId];
    if (request == null) {
      throw Exception('Purchase request not found');
    }

    final updatedRequest = request.copyWith(status: 'approved');
    _purchaseRequests[requestId] = updatedRequest;

    return updatedRequest;
  }

  @override
  Future<PurchaseRequest> rejectPurchaseRequest(String requestId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final request = _purchaseRequests[requestId];
    if (request == null) {
      throw Exception('Purchase request not found');
    }

    final updatedRequest = request.copyWith(
      status: 'rejected',
      // Note: We'd need to add a rejectionReason field to PurchaseRequest entity
      // For now, we'll just update the status
    );
    _purchaseRequests[requestId] = updatedRequest;

    return updatedRequest;
  }
}