import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class RevisionProgressBar extends StatelessWidget {
  const RevisionProgressBar({required this.value, super.key});

  final double value;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 1).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.18),
            borderRadius: AppRadius.radiusPill,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              height: 5,
              width: constraints.maxWidth * clamped,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primaryLight],
                ),
                borderRadius: AppRadius.radiusPill,
              ),
            ),
          ),
        );
      },
    );
  }
}
