import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/firestore_organization_repository.dart';
import '../../domain/entities/organization.dart';
import '../../domain/repositories/organization_repository.dart';

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return FirestoreOrganizationRepository();
});

/// The organizations the signed-in user belongs to. Empty for Individual /
/// Guest accounts. [OrganizationSwitcher] watches this to decide whether it
/// has anything to show.
final myOrganizationsProvider = FutureProvider<List<OrganizationMembership>>((ref) {
  return ref.watch(organizationRepositoryProvider).listMyOrganizations();
});

final activeOrganizationProvider = FutureProvider<Organization?>((ref) {
  return ref.watch(organizationRepositoryProvider).getActiveOrganization();
});

class OrganizationFormState extends Equatable {
  const OrganizationFormState({
    this.isSubmitting = false,
    this.errorMessage,
    this.organization,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final Organization? organization;

  OrganizationFormState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    Organization? organization,
  }) {
    return OrganizationFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      organization: organization ?? this.organization,
    );
  }

  @override
  List<Object?> get props => [isSubmitting, errorMessage, organization];
}

/// Drives Create Organization, Join Organization (invite code), and
/// join-by-domain — the three flows the Business Login redesign asked for,
/// unified into one controller since they share the exact same
/// submit/loading/error shape.
class OrganizationController extends StateNotifier<OrganizationFormState> {
  OrganizationController(this.ref) : super(const OrganizationFormState());

  final Ref ref;

  OrganizationRepository get _repository => ref.read(organizationRepositoryProvider);

  Future<void> _run(Future<Organization> Function() action) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final org = await action();
      state = state.copyWith(isSubmitting: false, organization: org);
      ref.invalidate(myOrganizationsProvider);
      ref.invalidate(activeOrganizationProvider);
    } on OrganizationFailure catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<void> createOrganization({
    required String name,
    required String domain,
    String? workspaceUrl,
  }) {
    return _run(() => _repository.createOrganization(
          name: name,
          domain: domain,
          workspaceUrl: workspaceUrl,
        ));
  }

  Future<void> joinByDomain(String companyEmail) {
    return _run(() => _repository.joinByDomain(companyEmail));
  }

  Future<void> joinWithInvitationCode(String code) {
    return _run(() => _repository.joinWithInvitationCode(code));
  }

  Future<void> switchOrganization(String organizationId) async {
    await _repository.setActiveOrganization(organizationId);
    ref.invalidate(activeOrganizationProvider);
  }
}

final organizationControllerProvider =
    StateNotifierProvider.autoDispose<OrganizationController, OrganizationFormState>(
  OrganizationController.new,
);
