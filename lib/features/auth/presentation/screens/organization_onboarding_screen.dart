import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/widgets/premium_text_field.dart';
import '../../application/providers/auth_providers.dart';
import '../../application/providers/organization_providers.dart';
import '../widgets/auth_helpers.dart';
import '../widgets/auth_shell.dart';

enum _OrgTab { create, joinDomain, joinCode }

/// Reached after a Business-mode signup with no organization yet. Bundles
/// the three flows the redesign asked for — Create Organization, Join
/// Organization (by matching company domain), and Accept Invitation (by
/// code) — as tabs of one screen rather than three separate routes, since
/// they're mutually exclusive first steps of the same decision.
class OrganizationOnboardingScreen extends ConsumerStatefulWidget {
  const OrganizationOnboardingScreen({super.key});

  @override
  ConsumerState<OrganizationOnboardingScreen> createState() =>
      _OrganizationOnboardingScreenState();
}

class _OrganizationOnboardingScreenState
    extends ConsumerState<OrganizationOnboardingScreen> {
  _OrgTab _tab = _OrgTab.create;
  final _nameController = TextEditingController();
  final _domainController = TextEditingController();
  final _workspaceController = TextEditingController();
  final _joinEmailController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final email = ref.read(authRepositoryProvider).currentUser?.email;
    if (email != null) {
      _joinEmailController.text = email;
      final at = email.indexOf('@');
      if (at != -1) _domainController.text = email.substring(at + 1);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _domainController.dispose();
    _workspaceController.dispose();
    _joinEmailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(organizationControllerProvider);

    ref.listen(organizationControllerProvider, (previous, next) {
      if (next.organization != null && previous?.organization == null) {
        context.go('/home');
      }
    });

    return AuthShell(
      compact: true,
      title: 'Set up your workspace',
      subtitle: 'Create a new organization or join an existing one.',
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TabBar(value: _tab, onChanged: (t) => setState(() => _tab = t)),
            const SizedBox(height: 20),
            AuthErrorBanner(message: formState.errorMessage),
            if (_tab == _OrgTab.create) ...[
              PremiumTextField(
                label: 'Company Name',
                controller: _nameController,
                hint: 'Acme Corp',
                prefixIcon: Icons.apartment_rounded,
              ),
              const SizedBox(height: 16),
              PremiumTextField(
                label: 'Company Domain',
                controller: _domainController,
                hint: 'acme.com',
                prefixIcon: Icons.dns_rounded,
              ),
              const SizedBox(height: 16),
              PremiumTextField(
                label: 'Workspace URL (optional)',
                controller: _workspaceController,
                hint: 'acme',
                prefixIcon: Icons.link_rounded,
              ),
              const SizedBox(height: 22),
              PremiumButton(
                label: 'Create Organization',
                loading: formState.isSubmitting,
                onPressed: () => ref.read(organizationControllerProvider.notifier).createOrganization(
                      name: _nameController.text,
                      domain: _domainController.text,
                      workspaceUrl: _workspaceController.text.isEmpty
                          ? null
                          : _workspaceController.text,
                    ),
              ),
            ] else if (_tab == _OrgTab.joinDomain) ...[
              Text(
                'We match you to your company workspace using your email domain.',
                style: AppTextStyles.body(size: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              PremiumTextField(
                label: 'Company Email',
                controller: _joinEmailController,
                hint: 'you@acme.com',
                prefixIcon: Icons.mail_outline_rounded,
              ),
              const SizedBox(height: 22),
              PremiumButton(
                label: 'Find My Organization',
                loading: formState.isSubmitting,
                onPressed: () => ref
                    .read(organizationControllerProvider.notifier)
                    .joinByDomain(_joinEmailController.text),
              ),
            ] else ...[
              Text(
                'Enter the invitation code your admin sent you.',
                style: AppTextStyles.body(size: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              PremiumTextField(
                label: 'Invitation Code',
                controller: _codeController,
                hint: 'ABCD1234',
                prefixIcon: Icons.confirmation_number_outlined,
              ),
              const SizedBox(height: 22),
              PremiumButton(
                label: 'Join Organization',
                loading: formState.isSubmitting,
                onPressed: () => ref
                    .read(organizationControllerProvider.notifier)
                    .joinWithInvitationCode(_codeController.text),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.value, required this.onChanged});

  final _OrgTab value;
  final ValueChanged<_OrgTab> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = {
      _OrgTab.create: 'Create',
      _OrgTab.joinDomain: 'Join by Domain',
      _OrgTab.joinCode: 'Invite Code',
    };
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: _OrgTab.values.map((tab) {
          final selected = tab == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.cardElevated : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[tab]!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(
                    size: 11.5,
                    weight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.textPrimary : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
