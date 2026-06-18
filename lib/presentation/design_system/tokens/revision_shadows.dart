import 'package:flutter/material.dart';

import 'revision_colors.dart';

class RevisionShadows {
  const RevisionShadows._();

  static List<BoxShadow> soft(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.20),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ];
  }

  static const List<BoxShadow> glass = [
    BoxShadow(color: Color(0x66000000), blurRadius: 22, offset: Offset(0, 14)),
  ];

  static List<BoxShadow> glow(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.38),
        blurRadius: 24,
        spreadRadius: 1,
      ),
    ];
  }

  static const List<BoxShadow> nav = [
    BoxShadow(color: Color(0x7A000000), blurRadius: 26, offset: Offset(0, 14)),
    BoxShadow(color: RevisionColors.glassSoft, blurRadius: 1, spreadRadius: 1),
  ];
}
