import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class RevisionPage extends StatelessWidget {
  const RevisionPage({
    required this.title,
    required this.children,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = padding.resolve(Directionality.of(context));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            resolvedPadding.left,
            resolvedPadding.top,
            resolvedPadding.right,
            0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              resolvedPadding.left,
              AppSpacing.xl,
              resolvedPadding.right,
              resolvedPadding.bottom,
            ),
            children: children,
          ),
        ),
      ],
    );
  }
}
