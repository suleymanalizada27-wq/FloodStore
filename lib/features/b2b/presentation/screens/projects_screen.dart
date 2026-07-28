import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:floodstore/features/b2b/application/providers/b2b_providers.dart';
import 'package:floodstore/features/b2b/domain/entities/project.dart';
import 'package:floodstore/features/b2b/presentation/screens/project_detail_screen.dart';
import 'package:floodstore/core/theme/app_colors.dart';
import 'package:floodstore/core/theme/app_spacing.dart';
import 'package:floodstore/core/theme/app_text_styles.dart';
import 'package:floodstore/core/widgets/glass_card.dart';
import 'package:floodstore/core/widgets/premium_button.dart';

class ProjectsScreen extends ConsumerWidget {
  final String organizationId;

  const ProjectsScreen({required this.organizationId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider(organizationId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Projects',
          style: AppTextStyles.headlineMedium,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to create project screen
            },
            tooltip: 'Yeni Layihə',
          ),
        ],
      ),
      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return _ProjectCard(project: project);
            },
          );
        },
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.work_outline,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Heç bir layihə yoxdur',
            style: AppTextStyles.textTheme.headlineSmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk layihənizi yaradın',
            style: AppTextStyles.textTheme.bodyMedium
                ?.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 24),
          PremiumButton(
            label: 'Yeni Layihə Yaradın',
            icon: Icons.add,
            onPressed: () {
              // TODO: Navigate to create project screen
            },
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends ConsumerWidget {
  final Project project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.name,
            style: AppTextStyles.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            project.description,
            style: AppTextStyles.textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatusBadge(status: project.status),
              const SizedBox(width: 8),
              Text(
                'Created: ${_formatDate(project.startDate)}',
                style: AppTextStyles.textTheme.bodySmall
                    ?.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: PremiumButton(
              label: 'Detaylar',
              icon: Icons.arrow_forward_ios,
              expand: false,
              onPressed: () {
                // TODO: Navigate to project detail screen
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (_) => ProjectDetailScreen(projectId: project.id),
                //   ),
                // );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _StatusBadge({required String status}) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'planning':
        color = AppColors.info;
        label = 'Planlaşdırılır';
        break;
      case 'active':
        color = AppColors.success;
        label = 'Faaktiv';
        break;
      case 'on_hold':
        color = AppColors.warning;
        label = 'Gözləyir';
        break;
      case 'completed':
        color = AppColors.secondary;
        label = 'Tamamlandı';
        break;
      case 'cancelled':
        color = AppColors.error;
        label = 'Ləğv Edildi';
        break;
      default:
        color = AppColors.textTertiary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}