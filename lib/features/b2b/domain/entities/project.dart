import 'package:floodstore/features/b2b/domain/entities/project_phase.dart';

class Project {
  final String id;
  final String organizationId;
  final String name;
  final String description;
  final String status; // e.g., 'planned', 'active', 'on_hold', 'completed', 'cancelled'
  final List<ProjectPhase> phases;
  final DateTime startDate;
  final DateTime? endDate; // nullable for ongoing projects

  const Project({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.description,
    required this.status,
    required this.phases,
    required this.startDate,
    this.endDate,
  });

  double get totalBudget => phases.fold(0.0, (sum, phase) => sum + phase.budget);
  double get spentBudget => 0.0; // TODO: calculate from actual expenses
  double get remainingBudget => totalBudget - spentBudget;

  Project copyWith({
    String? id,
    String? organizationId,
    String? name,
    String? description,
    String? status,
    List<ProjectPhase>? phases,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Project(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      phases: phases ?? this.phases,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}