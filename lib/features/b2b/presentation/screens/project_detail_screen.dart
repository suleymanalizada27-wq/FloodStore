import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:floodstore/features/b2b/application/providers/b2b_providers.dart';
import 'package:floodstore/features/b2b/domain/entities/project.dart';
import 'package:floodstore/core/theme/app_colors.dart';
import 'package:floodstore/core/theme/app_spacing.dart';
import 'package:floodstore/core/theme/app_text_styles.dart';
import 'package:floodstore/core/widgets/glass_card.dart';
import 'package:floodstore/core/widgets/premium_button.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final String projectId;

  const ProjectDetailScreen({required this.projectId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailProvider(projectId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
            'Layihə Detalı',
            style: AppTextStyles.headlineMedium,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: projectAsync.when(
        data: (project) => _buildProjectDetails(context, project),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Yükləmə xanası: $error',
            style: AppTextStyles.textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildProjectDetails(BuildContext context, Project project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: AppTextStyles.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  project.description,
                  style: AppTextStyles.textTheme.bodyLarge
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  label: 'Status',
                  value: _getStatusLabel(project.status),
                ),
                _InfoRow(
                  label: 'Start Date',
                  value: '${project.startDate.day}/${project.startDate.month}/${project.startDate.year}',
                ),
                if (project.endDate != null)
                  _InfoRow(
                    label: 'End Date',
                    value: '${project.endDate!.day}/${project.endDate!.month}/${project.endDate!.year}',
                  ),
                _InfoRow(
                  label: 'Total Budget',
                  value: '\$${project.totalBudget.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildPhasesSection(project.phases),
          const SizedBox(height: AppSpacing.lg),
          _buildActionsSection(context, project),
        ],
      ),
    );
  }

  Widget _buildPhasesSection(List<dynamic> phases) {
    if (phases.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Layihə Fázaları',
          style: AppTextStyles.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: phases.length,
          itemBuilder: (context, index) {
            final phase = phases[index];
            return _PhaseCard(phase: phase);
          },
        ),
      ],
    );
  }

  Widget _buildActionsSection(BuildContext context, Project project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Əməliyyatlar',
          style: AppTextStyles.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            PremiumButton(
              label: 'Yeni Faz Əlavə Et',
              icon: Icons.add,
              expand: true,
              onPressed: () {
                // TODO: Navigate to add phase screen
              },
            ),
            PremiumButton(
              label: 'Yeni Satınalma Tələbi',
              icon: Icons.shopping_cart,
              expand: true,
              onPressed: () {
                // TODO: Navigate to create purchase request screen
              },
            ),
            PremiumButton(
              label: 'Satınalma Tələbləri Gözləyir',
              icon: Icons.pending_actions,
              expand: true,
              onPressed: () {
                // TODO: Navigate to approval inbox for this project
              },
            ),
          ],
        ),
      ],
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'planning':
        return 'Planlaşdırılır';
      case 'active':
        return 'Faaktiv';
      case 'on_hold':
        return 'Gözləyir';
      case 'completed':
        return 'Tamamlandı';
      case 'cancelled':
        return 'Ləğv Edildi';
      default:
        return status;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: AppTextStyles.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PhaseCard extends StatelessWidget {
  final dynamic phase;

  const _PhaseCard({required this.phase});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              phase.name,
              style: AppTextStyles.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _statusBadge(status: phase.status),
            const SizedBox(height: 8),
            Text(
              phase.description,
              style: AppTextStyles.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge({required String status}) {
    Color color;

    switch (status.toLowerCase()) {
      case 'planned':
        color = const Color(0xFF3B82F6); // Blue
        break;
      case 'in_progress':
        color = const Color(0xFF10B981); // Green
        break;
      case 'completed':
        color = const Color(0xFF6B7280); // Gray
        break;
      case 'on_hold':
        color = const Color(0xFFF59E0B); // Yellow
        break;
      default:
        color = AppColors.textTertiary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}