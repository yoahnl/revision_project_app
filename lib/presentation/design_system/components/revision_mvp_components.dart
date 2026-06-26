import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/revision_colors.dart';
import '../tokens/revision_radius.dart';
import '../tokens/revision_shadows.dart';
import '../tokens/revision_spacing.dart';
import '../tokens/revision_typography.dart';

class RevisionPageScaffold extends StatelessWidget {
  const RevisionPageScaffold({
    required this.children,
    this.headerChildren = const [],
    this.padding = const EdgeInsets.fromLTRB(
      RevisionSpacing.pageX,
      RevisionSpacing.pageTop,
      RevisionSpacing.pageX,
      110,
    ),
    this.maxWidth = 620,
    super.key,
  });

  static const double compactMaxWidth = 620;
  static const double wideMaxWidth = 1560;
  static const double wideBreakpoint = 1180;

  final List<Widget> children;
  final List<Widget> headerChildren;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveMaxWidth =
            maxWidth == compactMaxWidth &&
                constraints.maxWidth >= wideBreakpoint
            ? wideMaxWidth
            : maxWidth;
        final resolvedPadding = padding.resolve(Directionality.of(context));
        final hasFixedHeader = headerChildren.isNotEmpty;
        final supportsFixedHeader =
            hasFixedHeader && constraints.hasBoundedHeight;

        final scrollableContent = _SpacedColumn(children: children);

        if (!supportsFixedHeader) {
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
              // Keep the premium screens visually fixed when their content
              // fits, but still allow overflow content to move on shorter
              // panes. This avoids the "web page" feeling on normal screens
              // without risking clipped cards when a course has more state.
              child: SingleChildScrollView(
                child: Padding(padding: padding, child: scrollableContent),
              ),
            ),
          );
        }

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    resolvedPadding.left,
                    resolvedPadding.top,
                    resolvedPadding.right,
                    0,
                  ),
                  child: _SpacedColumn(children: headerChildren),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        resolvedPadding.left,
                        RevisionSpacing.l,
                        resolvedPadding.right,
                        resolvedPadding.bottom,
                      ),
                      child: scrollableContent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SpacedColumn extends StatelessWidget {
  const _SpacedColumn({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final child in children) ...[
          child,
          if (child != children.last) const SizedBox(height: RevisionSpacing.l),
        ],
      ],
    );
  }
}

class RevisionPageHeader extends StatelessWidget {
  const RevisionPageHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: RevisionTypography.pageTitle),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: RevisionSpacing.xs),
                Text(
                  subtitle,
                  style: RevisionTypography.body.copyWith(
                    color: RevisionColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: RevisionSpacing.m),
          trailing!,
        ],
      ],
    );
  }
}

class RevisionGlassCard extends StatelessWidget {
  const RevisionGlassCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(RevisionSpacing.l),
    this.radius = RevisionRadius.radiusXl,
    this.borderColor,
    this.backgroundColor,
    this.gradient,
    this.selected = false,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final BorderRadius radius;
  final Color? borderColor;
  final Color? backgroundColor;
  final Gradient? gradient;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null
            ? backgroundColor ?? RevisionColors.glassSoft
            : null,
        gradient: gradient,
        borderRadius: radius,
        border: Border.all(
          color:
              borderColor ??
              (selected ? RevisionColors.blue : RevisionColors.border),
          width: selected ? 1.4 : 1,
        ),
        boxShadow: selected
            ? RevisionShadows.soft(RevisionColors.blue)
            : RevisionShadows.glass,
      ),
      child: child,
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: radius, onTap: onTap, child: content),
    );
  }
}

class RevisionLightButton extends StatelessWidget {
  const RevisionLightButton({
    required this.label,
    this.icon,
    this.onPressed,
    this.expanded = false,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final content = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: RevisionColors.blueDeep),
          const SizedBox(width: RevisionSpacing.s),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: RevisionColors.blueDeep,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.56,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: RevisionRadius.pill,
            onTap: onPressed,
            child: Ink(
              decoration: BoxDecoration(
                color: RevisionColors.text,
                borderRadius: RevisionRadius.pill,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66FFFFFF),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: RevisionSpacing.xl,
                  vertical: RevisionSpacing.s,
                ),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RevisionHeaderIconButton extends StatelessWidget {
  const RevisionHeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 52,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RevisionColors.glassStrong,
        borderRadius: RevisionRadius.pill,
        border: Border.all(color: RevisionColors.borderBright),
        boxShadow: RevisionShadows.nav,
      ),
      child: IconButton(
        tooltip: tooltip,
        constraints: BoxConstraints.tightFor(width: size, height: size),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(icon, color: RevisionColors.text, size: size * 0.62),
      ),
    );
  }
}

class RevisionGradientButton extends StatelessWidget {
  const RevisionGradientButton({
    required this.label,
    this.icon,
    this.onPressed,
    this.expanded = false,
    this.gradient,
    this.foreground = RevisionColors.text,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expanded;
  final Gradient? gradient;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final button = Opacity(
      opacity: enabled ? 1 : 0.55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient:
              gradient ??
              const LinearGradient(
                colors: [RevisionColors.blue, RevisionColors.blueDeep],
              ),
          borderRadius: RevisionRadius.pill,
          boxShadow: RevisionShadows.soft(RevisionColors.blue),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RevisionSpacing.xl,
            vertical: RevisionSpacing.m,
          ),
          child: Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: foreground, size: 19),
                const SizedBox(width: RevisionSpacing.s),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RevisionColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: expanded
            ? SizedBox(width: double.infinity, child: button)
            : button,
      ),
    );
  }
}

class RevisionIconTile extends StatelessWidget {
  const RevisionIconTile({
    required this.icon,
    required this.accent,
    this.size = 52,
    this.iconSize = 28,
    super.key,
  });

  final IconData icon;
  final Color accent;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.95),
            accent.withValues(alpha: 0.35),
          ],
        ),
        borderRadius: RevisionRadius.radiusM,
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: RevisionShadows.soft(accent),
      ),
      child: Icon(icon, color: RevisionColors.text, size: iconSize),
    );
  }
}

class RevisionHeaderActionPill extends StatelessWidget {
  const RevisionHeaderActionPill({
    required this.label,
    required this.icon,
    this.onTap,
    this.accent = RevisionColors.blue,
    this.selected = false,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color accent;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: enabled ? 1 : 0.58,
          child: Container(
            constraints: const BoxConstraints(minHeight: 38),
            padding: const EdgeInsets.symmetric(
              horizontal: RevisionSpacing.m,
              vertical: RevisionSpacing.s,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? accent.withValues(alpha: 0.18)
                  : RevisionColors.glassSoft,
              borderRadius: RevisionRadius.pill,
              border: Border.all(
                color: selected
                    ? accent.withValues(alpha: 0.68)
                    : RevisionColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: selected ? accent : RevisionColors.textMuted,
                  size: 17,
                ),
                const SizedBox(width: RevisionSpacing.xs),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? RevisionColors.text
                        : RevisionColors.textMuted,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RevisionActionListTile extends StatelessWidget {
  const RevisionActionListTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.onTap,
    this.trailing,
    this.enabled = true,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      onTap: enabled ? onTap : null,
      padding: const EdgeInsets.all(RevisionSpacing.m),
      borderColor: accent.withValues(alpha: enabled ? 0.36 : 0.18),
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.58,
        duration: const Duration(milliseconds: 160),
        child: Row(
          children: [
            RevisionIconTile(
              icon: icon,
              accent: accent,
              size: 46,
              iconSize: 24,
            ),
            const SizedBox(width: RevisionSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: RevisionTypography.sectionTitle),
                  const SizedBox(height: RevisionSpacing.xs),
                  Text(subtitle, style: RevisionTypography.body),
                ],
              ),
            ),
            const SizedBox(width: RevisionSpacing.s),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: enabled
                      ? RevisionColors.textMuted
                      : RevisionColors.textFaint,
                ),
          ],
        ),
      ),
    );
  }
}

class RevisionMetricPill extends StatelessWidget {
  const RevisionMetricPill({
    required this.label,
    required this.icon,
    this.accent = RevisionColors.blue,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RevisionSpacing.m,
        vertical: RevisionSpacing.s,
      ),
      decoration: BoxDecoration(
        color: RevisionColors.glassSoft,
        borderRadius: RevisionRadius.pill,
        border: Border.all(color: accent.withValues(alpha: 0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 16),
          const SizedBox(width: RevisionSpacing.xs),
          Text(
            label,
            style: RevisionTypography.caption.copyWith(
              color: RevisionColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class RevisionSubjectSwitcher extends StatelessWidget {
  const RevisionSubjectSwitcher({
    required this.label,
    required this.accent,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String label;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Changer de matiere',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 220,
            maxWidth: 320,
            minHeight: 52,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: RevisionSpacing.m,
            vertical: RevisionSpacing.s,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                accent.withValues(alpha: 0.42),
                RevisionColors.glassStrong,
              ],
            ),
            borderRadius: RevisionRadius.pill,
            border: Border.all(
              color: accent.withValues(alpha: 0.76),
              width: 1.4,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RevisionIconTile(
                icon: icon,
                accent: accent,
                size: 34,
                iconSize: 20,
              ),
              const SizedBox(width: RevisionSpacing.m),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RevisionColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: RevisionColors.text,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RevisionTopCounters extends StatelessWidget {
  const RevisionTopCounters({this.streakLabel, this.gemsLabel, super.key});

  final String? streakLabel;
  final String? gemsLabel;

  @override
  Widget build(BuildContext context) {
    final counters = <Widget>[
      if (streakLabel != null)
        _CounterPill(
          icon: Icons.local_fire_department_rounded,
          label: streakLabel!,
        ),
      if (gemsLabel != null)
        _CounterPill(
          icon: Icons.diamond_rounded,
          label: gemsLabel!,
          accent: RevisionColors.cyan,
        ),
    ];

    if (counters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, counter) in counters.indexed) ...[
          if (index > 0) const SizedBox(width: RevisionSpacing.s),
          counter,
        ],
      ],
    );
  }
}

class _CounterPill extends StatelessWidget {
  const _CounterPill({
    required this.icon,
    required this.label,
    this.accent = RevisionColors.amber,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RevisionSpacing.s,
        vertical: RevisionSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: RevisionColors.glassSoft,
        borderRadius: RevisionRadius.pill,
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(width: RevisionSpacing.xs),
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class RevisionProgressLine extends StatelessWidget {
  const RevisionProgressLine({
    required this.value,
    this.color = RevisionColors.blue,
    this.height = 5,
    super.key,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 1).toDouble();

    return ClipRRect(
      borderRadius: RevisionRadius.pill,
      child: LinearProgressIndicator(
        value: clamped,
        minHeight: height,
        color: color,
        backgroundColor: RevisionColors.border.withValues(alpha: 0.72),
      ),
    );
  }
}

class RevisionMasteryRing extends StatelessWidget {
  const RevisionMasteryRing({
    required this.value,
    required this.label,
    this.size = 82,
    this.color = RevisionColors.green,
    this.caption,
    super.key,
  });

  final double value;
  final String label;
  final String? caption;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: size,
            child: CircularProgressIndicator(
              value: value.clamp(0, 1).toDouble(),
              strokeWidth: 7,
              strokeCap: StrokeCap.round,
              color: color,
              backgroundColor: RevisionColors.border,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: RevisionColors.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 0,
                ),
              ),
              if (caption != null)
                Text(
                  caption!,
                  textAlign: TextAlign.center,
                  style: RevisionTypography.caption.copyWith(
                    color: RevisionColors.textMuted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class RevisionResumeCourseCard extends StatelessWidget {
  const RevisionResumeCourseCard({
    required this.title,
    required this.subtitle,
    required this.progressLabel,
    required this.progress,
    required this.accent,
    required this.icon,
    required this.onContinue,
    this.actionLabel = 'Continuer',
    super.key,
  });

  final String title;
  final String subtitle;
  final String progressLabel;
  final double progress;
  final Color accent;
  final IconData icon;
  final VoidCallback onContinue;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      padding: const EdgeInsets.all(RevisionSpacing.m),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [accent.withValues(alpha: 0.92), RevisionColors.blueDeep],
      ),
      borderColor: Colors.white.withValues(alpha: 0.14),
      child: Row(
        children: [
          RevisionIconTile(
            icon: Icons.play_arrow_rounded,
            accent: RevisionColors.cyan,
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: RevisionTypography.caption.copyWith(
                    color: RevisionColors.text.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: RevisionSpacing.xs),
                Text(title, style: RevisionTypography.sectionTitle),
                const SizedBox(height: RevisionSpacing.m),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: RevisionProgressLine(
                        value: progress,
                        color: RevisionColors.cyan,
                      ),
                    ),
                    const SizedBox(width: RevisionSpacing.s),
                    Flexible(
                      flex: 2,
                      child: Text(
                        progressLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RevisionTypography.caption.copyWith(
                          color: RevisionColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: RevisionSpacing.s),
          TextButton(
            onPressed: onContinue,
            style: TextButton.styleFrom(
              backgroundColor: RevisionColors.text,
              foregroundColor: RevisionColors.blueDeep,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(
                horizontal: RevisionSpacing.m,
                vertical: RevisionSpacing.s,
              ),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class RevisionCourseCard extends StatelessWidget {
  const RevisionCourseCard({
    required this.title,
    required this.progressLabel,
    required this.durationLabel,
    required this.progress,
    required this.accent,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String title;
  final String progressLabel;
  final String durationLabel;
  final double progress;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(RevisionSpacing.m),
      child: Row(
        children: [
          RevisionIconTile(icon: icon, accent: accent, size: 48, iconSize: 27),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: RevisionTypography.sectionTitle,
                ),
                const SizedBox(height: RevisionSpacing.s),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        progressLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RevisionTypography.caption.copyWith(
                          color: accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: RevisionSpacing.m),
                    Expanded(
                      child: RevisionProgressLine(
                        value: progress,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: RevisionSpacing.m),
          Flexible(
            flex: 3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  color: RevisionColors.textMuted,
                  size: 15,
                ),
                const SizedBox(width: RevisionSpacing.xs),
                Flexible(
                  child: Text(
                    durationLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RevisionTypography.caption,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: RevisionSpacing.s),
          const Icon(
            Icons.chevron_right_rounded,
            color: RevisionColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class RevisionModeCard extends StatelessWidget {
  const RevisionModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    this.onTap,
    this.enabled = true,
    this.trailingLabel,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;
  final bool enabled;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      onTap: enabled ? onTap : null,
      padding: const EdgeInsets.all(RevisionSpacing.m),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          accent.withValues(alpha: enabled ? 0.78 : 0.28),
          RevisionColors.glassStrong,
        ],
      ),
      borderColor: accent.withValues(alpha: 0.30),
      child: Row(
        children: [
          RevisionIconTile(icon: icon, accent: accent, size: 48),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: RevisionTypography.sectionTitle),
                const SizedBox(height: RevisionSpacing.xs),
                Text(description, style: RevisionTypography.body),
              ],
            ),
          ),
          if (trailingLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: RevisionSpacing.s,
                vertical: RevisionSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: RevisionColors.ink.withValues(alpha: 0.28),
                borderRadius: RevisionRadius.pill,
              ),
              child: Text(
                trailingLabel!,
                style: RevisionTypography.caption.copyWith(
                  color: enabled
                      ? RevisionColors.text
                      : RevisionColors.textMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else
            Icon(
              Icons.chevron_right_rounded,
              color: enabled ? RevisionColors.text : RevisionColors.textFaint,
            ),
        ],
      ),
    );
  }
}

class RevisionSourceFileCard extends StatelessWidget {
  const RevisionSourceFileCard({
    required this.fileName,
    required this.statusLabel,
    this.sizeLabel,
    this.statusColor = RevisionColors.red,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String fileName;
  final String? sizeLabel;
  final String statusLabel;
  final Color statusColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(RevisionSpacing.m),
      child: Row(
        children: [
          RevisionIconTile(
            icon: Icons.picture_as_pdf_rounded,
            accent: statusColor,
            size: 42,
            iconSize: 23,
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: RevisionTypography.sectionTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: RevisionSpacing.xs),
                Text(
                  sizeLabel == null ? statusLabel : '$sizeLabel · $statusLabel',
                  style: RevisionTypography.caption,
                ),
              ],
            ),
          ),
          trailing ??
              const Icon(
                Icons.more_vert_rounded,
                color: RevisionColors.textMuted,
              ),
        ],
      ),
    );
  }
}

class RevisionBottomSheetFrame extends StatelessWidget {
  const RevisionBottomSheetFrame({
    required this.title,
    required this.children,
    this.subtitle,
    this.floatingAction,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? floatingAction;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: RevisionColors.ink2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                RevisionSpacing.xl,
                RevisionSpacing.m,
                RevisionSpacing.xl,
                floatingAction == null ? RevisionSpacing.xl : 112,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 52,
                      height: 5,
                      decoration: BoxDecoration(
                        color: RevisionColors.borderBright,
                        borderRadius: RevisionRadius.pill,
                      ),
                    ),
                  ),
                  const SizedBox(height: RevisionSpacing.xl),
                  Text(title, style: RevisionTypography.pageTitle),
                  if (subtitle != null) ...[
                    const SizedBox(height: RevisionSpacing.s),
                    Text(subtitle!, style: RevisionTypography.body),
                  ],
                  const SizedBox(height: RevisionSpacing.l),
                  for (final child in children) ...[
                    child,
                    if (child != children.last)
                      const SizedBox(height: RevisionSpacing.m),
                  ],
                ],
              ),
            ),
            if (floatingAction != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: RevisionSpacing.l,
                child: Center(child: floatingAction),
              ),
          ],
        ),
      ),
    );
  }
}

class RevisionSheetSectionCard extends StatelessWidget {
  const RevisionSheetSectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.accent = RevisionColors.blue,
    super.key,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RevisionIconTile(
                icon: icon,
                accent: accent,
                size: 28,
                iconSize: 16,
              ),
              const SizedBox(width: RevisionSpacing.s),
              Expanded(
                child: Text(title, style: RevisionTypography.sectionTitle),
              ),
            ],
          ),
          const SizedBox(height: RevisionSpacing.m),
          for (final child in children) ...[
            child,
            if (child != children.last)
              const SizedBox(height: RevisionSpacing.s),
          ],
        ],
      ),
    );
  }
}

class RevisionSegmentedControl<T> extends StatelessWidget {
  const RevisionSegmentedControl({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    super.key,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      padding: const EdgeInsets.all(RevisionSpacing.xxs),
      radius: RevisionRadius.radiusM,
      child: Row(
        children: [
          for (final value in values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    vertical: RevisionSpacing.s,
                  ),
                  decoration: BoxDecoration(
                    gradient: value == selected
                        ? const LinearGradient(
                            colors: [
                              RevisionColors.blue,
                              RevisionColors.blueDeep,
                            ],
                          )
                        : null,
                    borderRadius: RevisionRadius.radiusS,
                  ),
                  child: Text(
                    labelOf(value),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: value == selected
                          ? RevisionColors.text
                          : RevisionColors.textMuted,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class RevisionStatTriplet extends StatelessWidget {
  const RevisionStatTriplet({required this.items, super.key});

  final List<RevisionStatItem> items;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            Expanded(child: _StatItemView(item: items[index])),
            if (index != items.length - 1)
              Container(width: 1, height: 44, color: RevisionColors.border),
          ],
        ],
      ),
    );
  }
}

class RevisionStatItem {
  const RevisionStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
}

class _StatItemView extends StatelessWidget {
  const _StatItemView({required this.item});

  final RevisionStatItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(item.icon, color: item.color, size: 20),
        const SizedBox(height: RevisionSpacing.xs),
        Text(item.label, style: RevisionTypography.caption),
        const SizedBox(height: RevisionSpacing.xs),
        Text(
          item.value,
          textAlign: TextAlign.center,
          style: RevisionTypography.sectionTitle.copyWith(
            color: item.color,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class RevisionSectionHeader extends StatelessWidget {
  const RevisionSectionHeader({required this.title, this.subtitle, super.key});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: RevisionTypography.sectionTitle),
        if (subtitle != null) ...[
          const SizedBox(height: RevisionSpacing.xs),
          Text(subtitle!, style: RevisionTypography.body),
        ],
      ],
    );
  }
}

class RevisionFloatingAddButton extends StatelessWidget {
  const RevisionFloatingAddButton({required this.onTap, super.key});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Ajouter une source',
      child: Opacity(
        opacity: enabled ? 1 : 0.42,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [RevisionColors.pink, RevisionColors.pinkDeep],
              ),
              border: Border.all(
                color: RevisionColors.pink.withValues(alpha: 0.55),
                width: 6,
              ),
              boxShadow: enabled
                  ? RevisionShadows.soft(RevisionColors.pink)
                  : const [],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: RevisionColors.text,
              size: 38,
            ),
          ),
        ),
      ),
    );
  }
}

class RevisionConfettiOverlay extends StatefulWidget {
  const RevisionConfettiOverlay({this.particleCount = 180, super.key});

  final int particleCount;

  @override
  State<RevisionConfettiOverlay> createState() =>
      _RevisionConfettiOverlayState();
}

class _RevisionConfettiOverlayState extends State<RevisionConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<_RevisionConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = _buildRevisionConfettiParticles(widget.particleCount);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7600),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant RevisionConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.particleCount != widget.particleCount) {
      _particles = _buildRevisionConfettiParticles(widget.particleCount);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animationsDisabled = MediaQuery.disableAnimationsOf(context);

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (!animationsDisabled && _controller.isCompleted) {
            return child!;
          }

          return CustomPaint(
            painter: _RevisionConfettiOverlayPainter(
              progress: animationsDisabled ? 0.72 : _controller.value,
              particles: _particles,
            ),
            child: child,
          );
        },
        child: const SizedBox.expand(),
      ),
    );
  }
}

List<_RevisionConfettiParticle> _buildRevisionConfettiParticles(int count) {
  final random = math.Random(20260617);
  return List<_RevisionConfettiParticle>.generate(count, (index) {
    return _RevisionConfettiParticle(
      x: random.nextDouble(),
      start: random.nextDouble() * 0.42,
      yOffset: random.nextDouble() * 0.22,
      drift: (random.nextDouble() - 0.5) * 0.28,
      size: 3 + random.nextDouble() * 8,
      spin: random.nextDouble() * math.pi * 2,
      speed: 0.28 + random.nextDouble() * 0.42,
      colorIndex: random.nextInt(8),
      shapeIndex: random.nextInt(4),
    );
  });
}

class _RevisionConfettiParticle {
  const _RevisionConfettiParticle({
    required this.x,
    required this.start,
    required this.yOffset,
    required this.drift,
    required this.size,
    required this.spin,
    required this.speed,
    required this.colorIndex,
    required this.shapeIndex,
  });

  final double x;
  final double start;
  final double yOffset;
  final double drift;
  final double size;
  final double spin;
  final double speed;
  final int colorIndex;
  final int shapeIndex;
}

class _RevisionConfettiOverlayPainter extends CustomPainter {
  _RevisionConfettiOverlayPainter({
    required this.progress,
    required this.particles,
  });

  static const _strokeWidth = 3.0;
  static const _colors = [
    RevisionColors.blue,
    RevisionColors.cyan,
    RevisionColors.green,
    RevisionColors.amber,
    RevisionColors.pink,
    RevisionColors.violet,
    RevisionColors.mint,
    RevisionColors.coral,
  ];

  final double progress;
  final List<_RevisionConfettiParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || particles.isEmpty) return;

    final paint = Paint()..strokeCap = StrokeCap.round;

    for (final particle in particles) {
      final phase = (progress * (0.55 + particle.speed) - particle.start).clamp(
        0.0,
        1.0,
      );
      final eased = Curves.easeInOutSine.transform(phase);
      final sway = math.sin((phase * math.pi * 3) + particle.spin);
      final x =
          (particle.x + particle.drift * eased + sway * 0.018) * size.width;
      final y =
          -size.height * (0.18 + particle.yOffset) +
          (size.height * (1.2 + particle.yOffset)) * eased;
      final rotation = particle.spin + phase * math.pi * 3.5;
      final introOpacity = (phase / 0.18).clamp(0.0, 1.0);
      final exitOpacity = (1 - ((phase - 0.88) / 0.12).clamp(0.0, 1.0));
      final opacity = introOpacity * exitOpacity * (0.62 + (1 - phase) * 0.24);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      paint
        ..color = _colors[particle.colorIndex % _colors.length].withValues(
          alpha: opacity,
        )
        ..strokeWidth = _strokeWidth;
      _paintShape(canvas, paint, particle);
      canvas.restore();
    }
  }

  void _paintShape(
    Canvas canvas,
    Paint paint,
    _RevisionConfettiParticle particle,
  ) {
    final size = particle.size;

    switch (particle.shapeIndex) {
      case 0:
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(Offset.zero, size * 0.45, paint);
        break;
      case 1:
        paint.style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: size * 0.72,
              height: size * 1.85,
            ),
            const Radius.circular(RevisionSpacing.xs),
          ),
          paint,
        );
        break;
      case 2:
        paint.style = PaintingStyle.stroke;
        canvas.drawLine(Offset(-size, 0), Offset(size, 0), paint);
        break;
      default:
        paint.style = PaintingStyle.fill;
        final path = Path()
          ..moveTo(0, -size)
          ..lineTo(size * 0.88, size * 0.72)
          ..lineTo(-size * 0.88, size * 0.72)
          ..close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _RevisionConfettiOverlayPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        particles != oldDelegate.particles;
  }
}

class RevisionConfettiStrip extends StatelessWidget {
  const RevisionConfettiStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: RevisionConfettiOverlay(particleCount: 90),
    );
  }
}
