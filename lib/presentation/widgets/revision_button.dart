import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

enum RevisionButtonStyle { primary, ghost }

class RevisionButton extends StatelessWidget {
  const RevisionButton({
    required this.label,
    this.icon,
    this.onPressed,
    this.style = RevisionButtonStyle.primary,
    this.expand = false,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final RevisionButtonStyle style;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final isPrimary = style == RevisionButtonStyle.primary;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final foreground = isPrimary
        ? AppColors.backgroundDark
        : theme.colorScheme.onSurface;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    final child = Opacity(
      opacity: enabled ? 1 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primaryLight],
                )
              : null,
          color: isPrimary ? null : Colors.transparent,
          borderRadius: AppRadius.radiusPill,
          border: Border.all(
            color: isPrimary
                ? Colors.transparent
                : borderColor.withValues(alpha: 0.8),
          ),
          boxShadow: [
            if (enabled && isPrimary && isDark)
              BoxShadow(
                color: AppColors.mintGlow.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingH,
            vertical: AppSpacing.buttonPaddingV,
          ),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: foreground),
                const SizedBox(width: AppSpacing.s),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }
}
