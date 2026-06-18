import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class RevisionBackground extends StatelessWidget {
  const RevisionBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF020A12),
                  Color(0xFF06182A),
                  Color(0xFF0B1028),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.background, AppColors.surfaceSubtle],
              ),
      ),
      child: child,
    );
  }
}
