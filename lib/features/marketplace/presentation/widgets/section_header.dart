import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A section header with title and optional see-all button
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.showSeeAll = false,
    this.onSeeAllPressed,
  });

  final String title;
  final bool showSeeAll;
  final VoidCallback? onSeeAllPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.titleLarge,
          ),
          if (showSeeAll && onSeeAllPressed != null)
            TextButton(
              onPressed: onSeeAllPressed,
              child: Text(
                'See All',
                style: AppTextStyles.body(
                  size: 14,
                  color: AppColors.secondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}