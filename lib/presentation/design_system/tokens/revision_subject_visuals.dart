import 'package:flutter/material.dart';

import 'revision_colors.dart';

class RevisionSubjectVisualTheme {
  const RevisionSubjectVisualTheme({
    required this.accent,
    required this.secondary,
    required this.icon,
  });

  final Color accent;
  final Color secondary;
  final IconData icon;

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, secondary],
  );
}

RevisionSubjectVisualTheme revisionSubjectVisualThemeFor(String label) {
  final normalized = label.toLowerCase();

  // The label is used only as a real-data visual hint. It must never create a
  // fake subject, course, score, streak, or any other production content.
  if (normalized.contains('philo')) {
    return const RevisionSubjectVisualTheme(
      accent: RevisionColors.pink,
      secondary: RevisionColors.pinkDeep,
      icon: Icons.psychology_alt_rounded,
    );
  }

  if (normalized.contains('droit') || normalized.contains('jurid')) {
    return const RevisionSubjectVisualTheme(
      accent: RevisionColors.violet,
      secondary: RevisionColors.blueDeep,
      icon: Icons.account_balance_rounded,
    );
  }

  if (normalized.contains('stat') ||
      normalized.contains('math') ||
      normalized.contains('prob')) {
    return const RevisionSubjectVisualTheme(
      accent: RevisionColors.blue,
      secondary: RevisionColors.cyan,
      icon: Icons.functions_rounded,
    );
  }

  if (normalized.contains('eco') || normalized.contains('finance')) {
    return const RevisionSubjectVisualTheme(
      accent: RevisionColors.mint,
      secondary: RevisionColors.green,
      icon: Icons.trending_up_rounded,
    );
  }

  return const RevisionSubjectVisualTheme(
    accent: RevisionColors.blue,
    secondary: RevisionColors.violet,
    icon: Icons.auto_stories_outlined,
  );
}
