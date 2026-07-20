import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/widgets/premium_text_field.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../application/providers/marketplace_providers.dart';
import '../../domain/entities/business_account.dart';

/// 5-step Business Account registration wizard:
/// 1. Account Type & Basic Info
/// 2. Company Details (tax ID, trade registry, etc.)
/// 3. Authorized Person Info
/// 4. Business Address
/// 5. Documents Upload & Review
class BusinessAccountRegistrationScreen extends ConsumerStatefulWidget {
  const BusinessAccountRegistrationScreen({super.key});

  @override
  ConsumerState<BusinessAccountRegistrationScreen> createState() =>
      _BusinessAccountRegistrationScreenState();
}

class _BusinessAccountRegistrationScreenState
    extends ConsumerState<BusinessAccountRegistrationScreen> {
  int _currentStep = 0;
  static const int _totalSteps = 5;

  // Step 1: Account Type & Basic Info
  BusinessType _selectedBusinessType = BusinessType.individual;
  final _businessNameController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _websiteController = TextEditingController();

  // Step 2: Company Details
  final _taxIdController = TextEditingController();
  final _tradeRegistryController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Step 3: Authorized Person
  final _authorizedPersonNameController = TextEditingController();
  final _authorizedPersonTcController = TextEditingController();
  final _authorizedPersonPhoneController = TextEditingController();
  final _authorizedPersonEmailController = TextEditingController();

  // Step 4: Business Address
  final _countryController = TextEditingController(text: 'Türkiye');
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingNumberController = TextEditingController();
  final _apartmentNumberController = TextEditingController();
  final _postalCodeController = TextEditingController();

  // Step 5: Documents
  String? _logoUrl;
  String? _taxCertificateUrl;
  String? _tradeRegistryUrl;

  final _pageController = PageController();
  final _stepKeys = List.generate(5, (index) => GlobalKey<FormState>());

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessEmailController.dispose();
    _businessPhoneController.dispose();
    _websiteController.dispose();
    _taxIdController.dispose();
    _tradeRegistryController.dispose();
    _descriptionController.dispose();
    _authorizedPersonNameController.dispose();
    _authorizedPersonTcController.dispose();
    _authorizedPersonPhoneController.dispose();
    _authorizedPersonEmailController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _neighborhoodController.dispose();
    _streetController.dispose();
    _buildingNumberController.dispose();
    _apartmentNumberController.dispose();
    _postalCodeController.dispose();
    _pageController.dispose();
    for (final key in _stepKeys) {
      key.currentState?.dispose();
    }
    super.dispose();
  }

  void _nextStep() {
    if (_stepKeys[_currentStep].currentState?.validate() ?? false) {
      if (_currentStep < _totalSteps - 1) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _submitBusinessAccount();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitBusinessAccount() async {
    final authRepository = ref.read(authRepositoryProvider);
    final currentUser = authRepository.currentUser;
    if (currentUser == null) return;

    final address = BusinessAddress(
      country: _countryController.text,
      city: _cityController.text,
      district: _districtController.text,
      neighborhood: _neighborhoodController.text,
      street: _streetController.text,
      buildingNumber: _buildingNumberController.text,
      apartmentNumber: _apartmentNumberController.text.isNotEmpty
          ? _apartmentNumberController.text
          : null,
      postalCode: _postalCodeController.text,
      fullAddress:
          '${_streetController.text} ${_buildingNumberController.text}, ${_neighborhoodController.text}, ${_districtController.text}, ${_cityController.text}, ${_postalCodeController.text}, ${_countryController.text}',
    );

    final businessAccount = BusinessAccount(
      id: '',
      userId: currentUser.id,
      businessName: _businessNameController.text.trim(),
      businessType: _selectedBusinessType.value,
      taxId: _taxIdController.text.trim(),
      businessEmail: _businessEmailController.text.trim(),
      businessPhone: _businessPhoneController.text.trim(),
      address: address,
      website: _websiteController.text.isNotEmpty ? _websiteController.text : null,
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : null,
      taxCertificateUrl: _taxCertificateUrl,
      tradeRegistryUrl: _tradeRegistryUrl,
      logoUrl: _logoUrl,
      authorizedPersonName: _authorizedPersonNameController.text.trim(),
      authorizedPersonTc: _authorizedPersonTcController.text.trim(),
      authorizedPersonPhone: _authorizedPersonPhoneController.text.trim(),
      authorizedPersonEmail: _authorizedPersonEmailController.text.trim(),
      status: BusinessAccountStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final businessAccountRepository =
          ref.read(businessAccountRepositoryProvider);
      await businessAccountRepository.createBusinessAccount(businessAccount);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Business account application submitted successfully! We\'ll review it within 2-3 business days.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit application: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _previousStep,
              )
            : null,
        title: Text(
          'Business Account Registration',
          style: AppTextStyles.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  children: List.generate(_totalSteps, (index) {
                    return Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: index <= _currentStep
                                    ? AppColors.primary
                                    : AppColors.border,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          if (index < _totalSteps - 1)
                            const SizedBox(width: 8),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Step ${_currentStep + 1} of $_totalSteps',
                  style: AppTextStyles.textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          // Form steps
          Expanded(
            child: Form(
              key: _stepKeys[_currentStep],
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                  _buildStep5(),
                ],
              ),
            ),
          ),
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 2,
                  child: PremiumButton(
                    label: _currentStep == 4 ? 'Submit Application' : 'Continue',
                    expand: true,
                    onPressed: _nextStep,
                    icon: _currentStep == 4
                        ? Icons.send_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Type & Basic Info',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tell us about your business',
            style: AppTextStyles.textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Business Type Selector
          Text(
            'Business Type',
            style: AppTextStyles.textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: BusinessType.values.map((type) {
              final isSelected = _selectedBusinessType == type;
              return FilterChip(
                label: Text(type.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedBusinessType = type);
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Business Name
          PremiumTextField(
            controller: _businessNameController,
            label: 'Business Name',
            hint: 'Enter your business name',
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return 'Business name is required';
              if ((v ?? '').trim().length < 2) return 'Name is too short';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Business Email
          PremiumTextField(
            controller: _businessEmailController,
            label: 'Business Email',
            hint: 'business@example.com',
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return 'Email is required';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Business Phone
          PremiumTextField(
            controller: _businessPhoneController,
            label: 'Business Phone',
            hint: '+90 (555) 000-0000',
            keyboardType: TextInputType.phone,
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return 'Phone is required';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Website (optional)
          PremiumTextField(
            controller: _websiteController,
            label: 'Website (Optional)',
            hint: 'https://yourbusiness.com',
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Company Details',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Official company information',
            style: AppTextStyles.textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Tax ID
          PremiumTextField(
            controller: _taxIdController,
            label: 'Tax ID (Vergi Numarası)',
            hint: '1234567890',
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return 'Tax ID is required';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Trade Registry Number
          PremiumTextField(
            controller: _tradeRegistryController,
            label: 'Trade Registry Number (Ticaret Sicil No)',
            hint: '123456-0',
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return 'Trade registry number is required';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Description
          PremiumTextField(
            controller: _descriptionController,
            label: 'Business Description',
            hint: 'Describe your business...',
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return 'Description is required';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Authorized Person Information',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Person authorized to manage this account',
            style: AppTextStyles.textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Full Name
          PremiumTextField(
            controller: _authorizedPersonNameController,
            label: 'Full Name',
            hint: 'John Doe',
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return 'Full name is required';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // TC/Passport
          PremiumTextField(
            controller: _authorizedPersonTcController,
            label: 'TC/Passport Number',
            hint: '12345678901',
            keyboardType: TextInputType.number,
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return 'TC/Passport is required';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Phone
          PremiumTextField(
            controller: _authorizedPersonPhoneController,
            label: 'Phone Number',
            hint: '+90 (555) 000-0000',
            keyboardType: TextInputType.phone,
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return 'Phone is required';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Email
          PremiumTextField(
            controller: _authorizedPersonEmailController,
            label: 'Email',
            hint: 'authorized@business.com',
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return 'Email is required';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Address',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Where is your business located?',
            style: AppTextStyles.textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),

// Country
          PremiumTextField(
            controller: _countryController,
            label: 'Country',
            hint: 'Türkiye',
          ),
          const SizedBox(height: AppSpacing.md),

          // City
          PremiumTextField(
            controller: _cityController,
            label: 'City (İl)',
            hint: 'İstanbul',
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return 'City is required';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // District
          PremiumTextField(
            controller: _districtController,
            label: 'District (İlçe)',
            hint: 'Kadıköy',
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return 'District is required';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Neighborhood
          PremiumTextField(
            controller: _neighborhoodController,
            label: 'Neighborhood (Mahalle)',
            hint: 'Caferağa',
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return 'Neighborhood is required';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Street
          PremiumTextField(
            controller: _streetController,
            label: 'Street (Cadde/Sokak)',
            hint: 'Caferaga Mah. Moda Cd.',
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return 'Street is required';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Building Number
          PremiumTextField(
            controller: _buildingNumberController,
            label: 'Building Number',
            hint: '12',
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return 'Building number is required';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Apartment Number (optional)
          PremiumTextField(
            controller: _apartmentNumberController,
            label: 'Apartment/Suite (Optional)',
            hint: 'Daire 3',
          ),
          const SizedBox(height: AppSpacing.md),

          // Postal Code
          PremiumTextField(
            controller: _postalCodeController,
            label: 'Postal Code',
            hint: '34710',
            keyboardType: TextInputType.number,
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return 'Postal code is required';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Documents & Review',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Upload required documents and review your application',
            style: AppTextStyles.textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Logo Upload
          _buildDocumentUpload(
            label: 'Business Logo',
            subtitle: 'Recommended: 500x500px, PNG/JPG',
            currentUrl: _logoUrl,
            onUpload: () => _pickImage('logo'),
          ),
          const SizedBox(height: AppSpacing.md),

          // Tax Certificate
          _buildDocumentUpload(
            label: 'Tax Certificate (Vergi Levazı)',
            subtitle: 'Required - PDF or Image',
            currentUrl: _taxCertificateUrl,
            onUpload: () => _pickImage('tax_certificate'),
            isRequired: true,
          ),
          const SizedBox(height: AppSpacing.md),

          // Trade Registry Gazette
          _buildDocumentUpload(
            label: 'Trade Registry Gazette (Ticaret Sicil Gazetesi)',
            subtitle: 'Required - PDF or Image',
            currentUrl: _tradeRegistryUrl,
            onUpload: () => _pickImage('trade_registry'),
            isRequired: true,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Review Section
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Application Summary',
                  style: AppTextStyles.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildSummaryRow('Business Name', _businessNameController.text),
                _buildSummaryRow('Business Type', _selectedBusinessType.displayName),
                _buildSummaryRow('Tax ID', _taxIdController.text),
                _buildSummaryRow('Business Email', _businessEmailController.text),
                _buildSummaryRow('Business Phone', _businessPhoneController.text),
                _buildSummaryRow('Authorized Person', _authorizedPersonNameController.text),
                _buildSummaryRow('Address',
                    '${_streetController.text} ${_buildingNumberController.text}, ${_neighborhoodController.text}, ${_districtController.text}, ${_cityController.text}'),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'By submitting this application, you confirm that all information provided is accurate and complete. False information may result in rejection of your application.',
                  style: AppTextStyles.textTheme.bodySmall
                      ?.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUpload({
    required String label,
    required String subtitle,
    required String? currentUrl,
    required VoidCallback onUpload,
    bool isRequired = false,
  }) {
    return GlassCard(
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
                      label,
                      style: AppTextStyles.textTheme.labelLarge,
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.textTheme.bodySmall
                          ?.copyWith(color: AppColors.textTertiary),
                    ),
                    if (isRequired)
                      Text(
                        'Required',
                        style: AppTextStyles.textTheme.bodySmall
                            ?.copyWith(color: AppColors.error),
                      ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: onUpload,
                icon: Icon(currentUrl != null ? Icons.edit_rounded : Icons.add_rounded),
                label: Text(currentUrl != null ? 'Change' : 'Upload'),
              ),
            ],
          ),
          if (currentUrl != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Uploaded',
                  style: AppTextStyles.textTheme.bodySmall
                      ?.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickImage(String documentType) async {
    // In a real app, this would use image_picker to select from gallery/camera
    // For now, show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$documentType upload would open image picker')),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: AppTextStyles.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onDeleted});

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: AppTextStyles.textTheme.bodySmall),
      deleteIcon: const Icon(Icons.close, size: 14),
      onDeleted: onDeleted,
      deleteIconColor: AppColors.primary,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      labelStyle: const TextStyle(color: AppColors.primary),
      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}