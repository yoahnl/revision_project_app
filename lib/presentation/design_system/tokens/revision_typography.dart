import 'package:flutter/material.dart';

import 'revision_colors.dart';

class RevisionTypography {
  const RevisionTypography._();

  static const hero = TextStyle(
    color: RevisionColors.text,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 1.05,
    letterSpacing: 0,
  );

  static const pageTitle = TextStyle(
    color: RevisionColors.text,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.08,
    letterSpacing: 0,
  );

  static const sectionTitle = TextStyle(
    color: RevisionColors.text,
    fontSize: 17,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: 0,
  );

  static const body = TextStyle(
    color: RevisionColors.textMuted,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: 0,
  );

  static const caption = TextStyle(
    color: RevisionColors.textFaint,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0,
  );
}
