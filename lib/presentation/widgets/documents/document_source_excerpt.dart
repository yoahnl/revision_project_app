import 'package:flutter/material.dart';
import 'package:Neralune/presentation/theme/app_radius.dart';
import 'package:Neralune/presentation/theme/app_spacing.dart';

class DocumentSourceExcerpt extends StatelessWidget {
  const DocumentSourceExcerpt({
    required this.text,
    required this.index,
    this.pageNumber,
    this.label,
    super.key,
  });

  final String text;
  final int index;
  final int? pageNumber;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.46),
        borderRadius: AppRadius.radiusM,
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_sourceLabel(), style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  String _sourceLabel() {
    final pageLabel = pageNumber == null ? null : 'page $pageNumber';
    final chunkLabel = 'extrait ${index + 1}';
    final prefix = label?.trim();
    final baseLabel = prefix == null || prefix.isEmpty
        ? chunkLabel
        : '$prefix · $chunkLabel';

    if (pageLabel == null) {
      return baseLabel;
    }

    return '$baseLabel · $pageLabel';
  }
}
