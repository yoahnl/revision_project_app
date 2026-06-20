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
    this.padding = const EdgeInsets.fromLTRB(
      RevisionSpacing.pageX,
      RevisionSpacing.pageTop,
      RevisionSpacing.pageX,
      110,
    ),
    this.maxWidth = 520,
    super.key,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final child in children) ...[
            child,
            if (child != children.last)
              const SizedBox(height: RevisionSpacing.l),
          ],
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            // Keep the premium screens visually fixed when their content fits,
            // but still allow overflow content to move on shorter panes. This
            // avoids the "web page" feeling on normal screens without risking
            // clipped cards when a course has more state to show.
            child: SingleChildScrollView(child: content),
          ),
        );
      },
    );
  }
}

class RevisionGlassCard extends StatelessWidget {
  const RevisionGlassCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(RevisionSpacing.l),
    this.radius = RevisionRadius.radiusL,
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
          constraints: const BoxConstraints(minHeight: 40, maxWidth: 190),
          padding: const EdgeInsets.symmetric(
            horizontal: RevisionSpacing.m,
            vertical: RevisionSpacing.s,
          ),
          decoration: BoxDecoration(
            color: RevisionColors.glassSoft,
            borderRadius: RevisionRadius.pill,
            border: Border.all(color: accent, width: 1.4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RevisionIconTile(
                icon: icon,
                accent: accent,
                size: 24,
                iconSize: 15,
              ),
              const SizedBox(width: RevisionSpacing.s),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RevisionColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: RevisionSpacing.xs),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: RevisionColors.textMuted,
                size: 20,
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
    super.key,
  });

  final String title;
  final String subtitle;
  final String progressLabel;
  final double progress;
  final Color accent;
  final IconData icon;
  final VoidCallback onContinue;

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
            child: const Text(
              'Continuer',
              style: TextStyle(fontWeight: FontWeight.w900),
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

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ajouter une source',
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
            boxShadow: RevisionShadows.soft(RevisionColors.pink),
          ),
          child: const Icon(
            Icons.add_rounded,
            color: RevisionColors.text,
            size: 38,
          ),
        ),
      ),
    );
  }
}

class RevisionConfettiStrip extends StatefulWidget {
  const RevisionConfettiStrip({super.key});

  @override
  State<RevisionConfettiStrip> createState() => _RevisionConfettiStripState();
}

class _RevisionConfettiStripState extends State<RevisionConfettiStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _RevisionConfettiPainter(_controller.value),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _RevisionConfettiPainter extends CustomPainter {
  const _RevisionConfettiPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const colors = [
      RevisionColors.blue,
      RevisionColors.green,
      RevisionColors.pink,
      RevisionColors.amber,
      RevisionColors.violet,
      RevisionColors.mint,
    ];

    for (var index = 0; index < 22; index++) {
      final baseX = size.width * ((index + 0.5) / 22);
      final wave = math.sin((progress * math.pi * 2) + index) * 5;
      final y = 8 + (progress * 20 * ((index % 3) + 1) / 3);
      final opacity = (1 - (progress * 0.45)).clamp(0.45, 1.0);
      final paint = Paint()
        ..color = colors[index % colors.length].withValues(alpha: opacity);
      final rect = Rect.fromCenter(
        center: Offset(baseX + wave, y),
        width: index.isEven ? 4 : 3,
        height: index.isEven ? 10 : 7,
      );

      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate((index % 5 - 2) * math.pi / 7 + progress);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: rect.width,
            height: rect.height,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _RevisionConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
