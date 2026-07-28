import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:floodstore/features/b2b/application/providers/b2b_providers.dart';
import 'package:floodstore/features/b2b/domain/entities/purchase_request.dart';
import 'package:floodstore/core/theme/app_colors.dart';
import 'package:floodstore/core/theme/app_spacing.dart';
import 'package:floodstore/core/theme/app_text_styles.dart';
import 'package:floodstore/core/widgets/glass_card.dart';

// Provider to track the loading state for each request
final _isProcessingProvider =
    StateProvider.family<bool, String>((ref, requestId) => false);

class ApprovalInboxScreen extends ConsumerWidget {
  const ApprovalInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For now, we'll fetch all pending requests
    // In a real implementation, we'd filter by user's approval permissions
    // Using empty string as placeholder organizationId since we don't have auth context here
    final requestsAsync = ref.watch(pendingApprovalRequestsProvider(''));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Təsdiq Qobei',
          style: AppTextStyles.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _RequestCard(request: request);
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
            Icons.inbox,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Təsdiq üçün gözləyən heç bir talib yoxdur',
            style: AppTextStyles.textTheme.titleMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Təbbiotsatçı talepleri buradadir',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends ConsumerWidget {
  final PurchaseRequest request;

  const _RequestCard({required this.request});

  Future<void> _approveRequest(
      BuildContext context, WidgetRef ref, String requestId) async {
    // Set loading state
    ref.read(_isProcessingProvider(requestId).notifier).update((state) => true);
    try {
      final approvePurchaseRequest = ref.read(approvePurchaseRequestProvider);
      await approvePurchaseRequest(requestId);
      if (context.mounted) {
        // Refresh the list by notifying the provider
        ref.refresh(pendingApprovalRequestsProvider(request.projectId));
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Talibi qəbul edildi')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Qəbul edilə bilmədi: $e')),
        );
      }
    } finally {
      if (context.mounted) {
        // Reset loading state
        ref.read(_isProcessingProvider(requestId).notifier).update((state) => false);
      }
    }
  }

  Future<void> _rejectRequest(
      BuildContext context, WidgetRef ref, String requestId) async {
    // Show a dialog to get rejection reason
    String reason = '';
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Rədd Etmə Sebebi'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Rədd等原因',
          ),
          maxLines: 3,
          onChanged: (value) => reason = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İmtina Et'),
          ),
          TextButton(
            onPressed: reason.isNotEmpty
                ? () => Navigator.of(context).pop(reason)
                : null,
            child: const Text('Təsdiq Et'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    // Actually update the provider
    ref.read(_isProcessingProvider(requestId).notifier).update((state) => true);
    try {
      final rejectPurchaseRequest = ref.read(rejectPurchaseRequestProvider);
      await rejectPurchaseRequest(requestId, result);
      if (context.mounted) {
        // Refresh the list by notifying the provider
        ref.refresh(pendingApprovalRequestsProvider(request.projectId));
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Talibi rədd')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rədd edilə bilmədi: $e')),
        );
      }
    } finally {
      if (context.mounted) {
        // Reset loading state
        ref.read(_isProcessingProvider(requestId).notifier).update((state) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isProcessing = ref.watch(_isProcessingProvider(request.id));

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to request detail screen
      },
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Talibi #${request.id.substring(0, 8)}',
                        style: AppTextStyles.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Layihə: ${request.projectId}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (request.phaseId.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Faza: ${request.phaseId}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: _getStatusColor(request.status)
                            .withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    _getStatusLabel(request.status),
                    style: TextStyle(
                      color: _getStatusColor(request.status),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              request.items.isEmpty
                  ? 'Heç məhsul seçilməyib'
                  : '${request.items.length} ${request.items.length == 1 ? 'məhsul' : 'məhsullar'}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(color: AppColors.border),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isProcessing) ...[
                  TextButton(
                    onPressed: () =>
                        _rejectRequest(context, ref, request.id),
                    child: const Text(
                      'Rədd Et',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () =>
                        _approveRequest(context, ref, request.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    child: const Text('Qəbul Et'),
                  ),
                ] else ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return AppColors.textTertiary;
      case 'pending':
        return Colors.orange;
      case 'pending_approval':
        return Colors.orange;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'ordered':
        return AppColors.primary;
      default:
        return AppColors.textTertiary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'Tasnif';
      case 'pending':
        return 'Gözləyir';
      case 'pending_approval':
        return 'Təsdiq İcra Edilir';
      case 'approved':
        return 'Qəbul Edilib';
      case 'rejected':
        return 'Rədd Edilib';
      case 'ordered':
        return 'Sifariş Verilib';
      default:
        return status;
    }
  }
}