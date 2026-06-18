import 'package:flutter/material.dart';

import '../tokens/revision_colors.dart';
import '../tokens/revision_radius.dart';
import '../tokens/revision_spacing.dart';
import '../tokens/revision_typography.dart';

class RevisionLoadingState extends StatelessWidget {
  const RevisionLoadingState({this.label = 'Chargement...', super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return _RevisionStateCard(
      icon: Icons.hourglass_top_rounded,
      iconColor: RevisionColors.blue,
      title: label,
      message: 'Les données réelles sont en cours de chargement.',
      child: const Padding(
        padding: EdgeInsets.only(top: RevisionSpacing.m),
        child: LinearProgressIndicator(),
      ),
    );
  }
}

class RevisionEmptyState extends StatelessWidget {
  const RevisionEmptyState({
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _RevisionStateCard(
      icon: icon,
      iconColor: RevisionColors.cyan,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

class RevisionErrorState extends StatelessWidget {
  const RevisionErrorState({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _RevisionStateCard(
      icon: Icons.error_outline_rounded,
      iconColor: RevisionColors.red,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

class RevisionNotFoundState extends StatelessWidget {
  const RevisionNotFoundState({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _RevisionStateCard(
      icon: Icons.search_off_rounded,
      iconColor: RevisionColors.amber,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

class RevisionProcessingState extends StatelessWidget {
  const RevisionProcessingState({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _RevisionStateCard(
      icon: Icons.auto_awesome_rounded,
      iconColor: RevisionColors.violet,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      child: const Padding(
        padding: EdgeInsets.only(top: RevisionSpacing.m),
        child: LinearProgressIndicator(),
      ),
    );
  }
}

class _RevisionStateCard extends StatelessWidget {
  const _RevisionStateCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.child,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(RevisionSpacing.l),
      decoration: BoxDecoration(
        color: RevisionColors.glassSoft,
        borderRadius: RevisionRadius.radiusL,
        border: Border.all(color: RevisionColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 30),
          const SizedBox(height: RevisionSpacing.m),
          Text(title, style: RevisionTypography.sectionTitle),
          const SizedBox(height: RevisionSpacing.s),
          Text(message, style: RevisionTypography.body),
          ?child,
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: RevisionSpacing.l),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
