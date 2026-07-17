import 'package:equatable/equatable.dart';

import '../../domain/entities/account_mode.dart';

enum RegisterWizardStep { personalInfo, accountInfo, security, verification, finish }

extension RegisterWizardStepX on RegisterWizardStep {
  String get title => switch (this) {
        RegisterWizardStep.personalInfo => 'Personal Information',
        RegisterWizardStep.accountInfo => 'Account Information',
        RegisterWizardStep.security => 'Security',
        RegisterWizardStep.verification => 'Verification',
        RegisterWizardStep.finish => 'Finish',
      };
}

/// Everything the 5-step Register wizard needs — deliberately *not* the
/// password, which never round-trips through [DraftStorageService]; the
/// draft is "resume filling out the form", not "resume with your password
/// pre-typed".
class RegisterWizardState extends Equatable {
  const RegisterWizardState({
    this.step = RegisterWizardStep.personalInfo,
    this.accountMode = AccountMode.individual,
    this.firstName = '',
    this.lastName = '',
    this.companyName = '',
    this.username = '',
    this.email = '',
    this.phone = '',
    this.country,
    this.companyEmail = '',
    this.organizationId = '',
    this.workspaceUrl = '',
    this.agreeToTerms = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.isDirty = false,
    this.draftRestored = false,
  });

  final RegisterWizardStep step;
  final AccountMode accountMode;
  final String firstName;
  final String lastName;
  final String companyName;
  final String username;
  final String email;
  final String phone;
  final String? country;

  // Business-mode-only fields (Company Email / Org ID / Workspace URL).
  final String companyEmail;
  final String organizationId;
  final String workspaceUrl;

  final bool agreeToTerms;
  final bool isSubmitting;
  final String? errorMessage;

  /// True once any field differs from the initial empty state — drives the
  /// unsaved-changes warning on back navigation.
  final bool isDirty;

  /// True for exactly one frame after a draft was loaded, so the screen can
  /// show a "Draft restored" toast without re-showing it on every rebuild.
  final bool draftRestored;

  Map<String, dynamic> toDraftJson() => {
        'step': step.name,
        'accountMode': accountMode.name,
        'firstName': firstName,
        'lastName': lastName,
        'companyName': companyName,
        'username': username,
        'email': email,
        'phone': phone,
        'country': country,
        'companyEmail': companyEmail,
        'organizationId': organizationId,
        'workspaceUrl': workspaceUrl,
      };

  factory RegisterWizardState.fromDraftJson(Map<String, dynamic> json) {
    return RegisterWizardState(
      step: RegisterWizardStep.values.byName(json['step'] as String? ?? 'personalInfo'),
      accountMode: AccountMode.values.byName(json['accountMode'] as String? ?? 'individual'),
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      country: json['country'] as String?,
      companyEmail: json['companyEmail'] as String? ?? '',
      organizationId: json['organizationId'] as String? ?? '',
      workspaceUrl: json['workspaceUrl'] as String? ?? '',
      isDirty: true,
      draftRestored: true,
    );
  }

  RegisterWizardState copyWith({
    RegisterWizardStep? step,
    AccountMode? accountMode,
    String? firstName,
    String? lastName,
    String? companyName,
    String? username,
    String? email,
    String? phone,
    String? country,
    String? companyEmail,
    String? organizationId,
    String? workspaceUrl,
    bool? agreeToTerms,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    bool? isDirty,
    bool? draftRestored,
  }) {
    return RegisterWizardState(
      step: step ?? this.step,
      accountMode: accountMode ?? this.accountMode,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      companyName: companyName ?? this.companyName,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      companyEmail: companyEmail ?? this.companyEmail,
      organizationId: organizationId ?? this.organizationId,
      workspaceUrl: workspaceUrl ?? this.workspaceUrl,
      agreeToTerms: agreeToTerms ?? this.agreeToTerms,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isDirty: isDirty ?? this.isDirty,
      draftRestored: draftRestored ?? this.draftRestored,
    );
  }

  @override
  List<Object?> get props => [
        step,
        accountMode,
        firstName,
        lastName,
        companyName,
        username,
        email,
        phone,
        country,
        companyEmail,
        organizationId,
        workspaceUrl,
        agreeToTerms,
        isSubmitting,
        errorMessage,
        isDirty,
        draftRestored,
      ];
}
