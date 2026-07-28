class ProjectPhase {
  final String id;
  final String projectId;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final double budget;
  final String status; // e.g., 'planned', 'in_progress', 'completed', 'on_hold'

  const ProjectPhase({
    required this.id,
    required this.projectId,
    required this.name,
    required this.description,
    required this.startDate,
    this.endDate,
    required this.budget,
    required this.status,
  });

  ProjectPhase copyWith({
    String? id,
    String? projectId,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    String? status,
  }) {
    return ProjectPhase(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      status: status ?? this.status,
    );
  }
}