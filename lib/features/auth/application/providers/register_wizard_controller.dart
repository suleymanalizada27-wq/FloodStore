import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/draft_storage_service.dart';
import '../../domain/entities/account_mode.dart';
import '../../domain/repositories/auth_repository.dart';
import '../state/register_wizard_state.dart';
import 'auth_providers.dart';

final draftStorageServiceProvider = Provider<DraftStorageService>((ref) {
  return DraftStorageService();
});

const _registerDraftId = 'register_wizard';

/// Orchestrates the 5-step Register wizard: field state, step navigation
/// with per-step validation gates, draft autosave, and the final
/// `registerWithEmail` call. Password itself is only ever held by the
/// screen's own `TextEditingController` — see [RegisterWizardState] for why
/// it never enters this state object.
class RegisterWizardController extends StateNotifier<RegisterWizardState> {
  RegisterWizardController(this.ref) : super(const RegisterWizardState()) {
    _restoreDraftIfAny();
  }

  final Ref ref;

  AuthRepository get _repository => ref.read(authRepositoryProvider);
  DraftStorageService get _drafts => ref.read(draftStorageServiceProvider);

  Future<void> _restoreDraftIfAny() async {
    final json = await _drafts.load(_registerDraftId);
    if (json != null && mounted) {
      state = RegisterWizardState.fromDraftJson(json);
    }
  }

  void update(RegisterWizardState Function(RegisterWizardState) updater) {
    state = updater(state).copyWith(isDirty: true, draftRestored: false);
  }

  void setAccountMode(AccountMode mode) => update((s) => s.copyWith(accountMode: mode));

  void goBack() {
    if (state.step.index == 0) return;
    state = state.copyWith(
      step: RegisterWizardStep.values[state.step.index - 1],
      clearError: true,
    );
  }

  void goNext() {
    if (state.step.index >= RegisterWizardStep.values.length - 1) return;
    state = state.copyWith(
      step: RegisterWizardStep.values[state.step.index + 1],
      clearError: true,
    );
  }

  Future<void> saveDraftAndExit() async {
    await _drafts.save(_registerDraftId, state.toDraftJson());
  }

  Future<void> discardDraft() async {
    await _drafts.clear(_registerDraftId);
  }

  Future<void> submit(String password) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repository.registerWithEmail(RegisterPayload(
        firstName: state.firstName.trim(),
        lastName: state.lastName.trim(),
        username: state.username.trim(),
        email: state.email.trim(),
        phone: state.phone.trim(),
        password: password,
        country: state.country ?? '',
        accountMode: state.accountMode,
        companyName: state.accountMode.requiresCompanyName ? state.companyName.trim() : null,
      ));
      await discardDraft();
      state = state.copyWith(isSubmitting: false, step: RegisterWizardStep.finish);
    } on AuthFailure catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }
}

final registerWizardControllerProvider =
    StateNotifierProvider.autoDispose<RegisterWizardController, RegisterWizardState>(
  RegisterWizardController.new,
);
