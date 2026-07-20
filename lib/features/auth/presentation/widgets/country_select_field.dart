import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A short, curated list. Swap for a full ISO-3166 dataset package
/// (e.g. `country_picker`) if FloodStore needs exhaustive coverage —
/// kept minimal here to honor the "no unnecessary packages" directive.
const List<({String flag, String name})> kCountries = [
  (flag: '🇺🇸', name: 'United States'),
  (flag: '🇬🇧', name: 'United Kingdom'),
  (flag: '🇨🇦', name: 'Canada'),
  (flag: '🇦🇺', name: 'Australia'),
  (flag: '🇩🇪', name: 'Germany'),
  (flag: '🇫🇷', name: 'France'),
  (flag: '🇦🇿', name: 'Azerbaijan'),
  (flag: '🇹🇷', name: 'Turkey'),
  (flag: '🇦🇪', name: 'United Arab Emirates'),
  (flag: '🇸🇬', name: 'Singapore'),
  (flag: '🇯🇵', name: 'Japan'),
  (flag: '🇮🇳', name: 'India'),
  (flag: '🇧🇷', name: 'Brazil'),
];

class CountrySelectField extends StatelessWidget {
  const CountrySelectField({
    super.key,
    required this.value,
    required this.onChanged,
    this.validator,
  });

  final String? value;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shrinkWrap: true,
            itemCount: kCountries.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.divider),
            itemBuilder: (context, index) {
              final country = kCountries[index];
              return ListTile(
                leading: Text(
                  country.flag,
                  style: const TextStyle(fontSize: 22),
                ),
                title: Text(country.name, style: AppTextStyles.body(size: 14)),
                onTap: () => Navigator.of(context).pop(country.name),
              );
            },
          ),
        );
      },
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: value,
      validator: validator,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Country',
              style: AppTextStyles.body(
                size: 13,
                weight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _openPicker(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: field.hasError
                        ? AppColors.error
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.public_rounded,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        value ?? 'Select your country',
                        style: AppTextStyles.body(
                          size: 15,
                          color: value == null
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
            if (field.hasError) ...[
              const SizedBox(height: 6),
              Text(
                field.errorText!,
                style: AppTextStyles.body(size: 12, color: AppColors.error),
              ),
            ],
          ],
        );
      },
    );
  }
}
