import '../entities/organization.dart';

class OrganizationFailure implements Exception {
  const OrganizationFailure(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => 'OrganizationFailure($code): $message';
}

/// Contract for everything the Business Login redesign needs beyond plain
/// [AuthRepository] sign-in: creating a company workspace, joining one by
/// domain match or invite code, and switching between several.
abstract interface class OrganizationRepository {
  /// All organizations the current user belongs to — powers the
  /// Organization Switcher. Empty for Individual/Guest accounts.
  Future<List<OrganizationMembership>> listMyOrganizations();

  /// The organization the app should currently act within. `null` if the
  /// user belongs to none yet (fresh business signup, pre-onboarding).
  Future<Organization?> getActiveOrganization();

  Future<void> setActiveOrganization(String organizationId);

  /// True if [email]'s domain matches [organization.domain] — used to
  /// silently auto-join employees signing up with a company address
  /// instead of making them enter an invite code.
  bool emailMatchesDomain(String email, Organization organization);

  Future<Organization> createOrganization({
    required String name,
    required String domain,
    String? workspaceUrl,
  });

  /// Joins by domain match (no code needed) once [emailMatchesDomain] is
  /// true for some organization owning that domain.
  Future<Organization> joinByDomain(String companyEmail);

  Future<Organization> joinWithInvitationCode(String code);

  /// Owner/admin action — not surfaced in this pass's UI beyond the data
  /// model, since an admin console is out of scope here.
  Future<InvitationCode> generateInvitationCode({
    required String organizationId,
    OrganizationRole role = OrganizationRole.member,
    Duration validFor = const Duration(days: 7),
    int maxUses = 1,
  });
}
