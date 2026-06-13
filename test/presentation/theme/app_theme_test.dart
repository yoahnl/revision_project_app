import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/presentation/theme/app_colors.dart';
import 'package:revision_app/presentation/theme/app_radius.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/theme/app_theme.dart';

void main() {
  test('light and dark themes expose Revision design tokens', () {
    final lightTheme = AppTheme.lightTheme;
    final darkTheme = AppTheme.darkTheme;

    expect(lightTheme.useMaterial3, isTrue);
    expect(lightTheme.colorScheme.primary, AppColors.primary);
    expect(lightTheme.scaffoldBackgroundColor, AppColors.background);
    expect(darkTheme.useMaterial3, isTrue);
    expect(darkTheme.colorScheme.primary, AppColors.primaryDark);
    expect(darkTheme.scaffoldBackgroundColor, AppColors.backgroundDark);
    expect(AppSpacing.pageHorizontal, 16);
    expect(AppRadius.radiusL, BorderRadius.circular(12));
  });
}
