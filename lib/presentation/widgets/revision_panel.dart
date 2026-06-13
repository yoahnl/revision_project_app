import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class RevisionPanel extends StatelessWidget {
  const RevisionPanel({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.margin,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final surfaceColor = isDark
        ? AppColors.surfaceGlassDark
        : AppColors.surface;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: borderColor.withValues(alpha: 0.72)),
        boxShadow: [
          if (isDark)
            BoxShadow(
              color: AppColors.mintGlow.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            )
          else
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: child,
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.radiusXl,
        onTap: onTap,
        child: content,
      ),
    );
  }
}
