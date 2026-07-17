import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../application/providers/organization_providers.dart';
import '../../domain/entities/organization.dart';

/// A compact "Acme Corp ▾" control that opens a sheet listing every
/// organization the signed-in user belongs to. Intended for a future
/// authenticated shell's app bar — dropped in here as the deliverable for
/// "Organization selector when user belongs to multiple companies", since
/// no authenticated shell exists yet to host it permanently.
class OrganizationSwitcher extends ConsumerWidget {
  const OrganizationSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(activeOrganizationProvider);
    final membershipsAsync = ref.watch(myOrganizationsProvider);

    return activeAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (active) {
        if (active == null) return const SizedBox.shrink();
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openSwitcher(context, ref, membershipsAsync.valueOrNull ?? []),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 22,
                  width: 22,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.cardElevated,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    active.name.isEmpty ? '?' : active.name[0].toUpperCase(),
                    style: AppTextStyles.body(size: 11, weight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Text(active.name, style: AppTextStyles.body(size: 13, weight: FontWeight.w600)),
                const SizedBox(width: 4),
                const Icon(Icons.unfold_more_rounded, size: 16, color: AppColors.textTertiary),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openSwitcher(
    BuildContext context,
    WidgetRef ref,
    List<OrganizationMembership> memberships,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: memberships.map((m) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.cardElevated,
                child: Text(m.organization.name[0].toUpperCase()),
              ),
              title: Text(m.organization.name, style: AppTextStyles.body(size: 14)),
              subtitle: Text(m.role.name, style: AppTextStyles.body(size: 12, color: AppColors.textTertiary)),
              onTap: () {
                ref
                    .read(organizationControllerProvider.notifier)
                    .switchOrganization(m.organization.id);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
