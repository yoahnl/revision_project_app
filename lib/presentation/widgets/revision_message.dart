import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'revision_panel.dart';

class RevisionMessage extends StatelessWidget {
  const RevisionMessage({
    required this.message,
    required this.color,
    this.icon,
    super.key,
  });

  final String message;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 18),
            const SizedBox(width: AppSpacing.s),
          ],
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
