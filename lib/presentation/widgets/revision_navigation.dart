import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../design_system/tokens/revision_colors.dart';
import '../design_system/tokens/revision_shadows.dart';

class RevisionNavigationDestination {
  const RevisionNavigationDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class RevisionBottomNavigation extends StatelessWidget {
  const RevisionBottomNavigation({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final List<RevisionNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: RevisionColors.glassStrong,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: RevisionColors.borderBright),
            boxShadow: RevisionShadows.nav,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s,
              vertical: AppSpacing.s,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var index = 0; index < destinations.length; index++)
                  Expanded(
                    child: _NavigationItem(
                      destination: destinations[index],
                      isSelected: selectedIndex == index,
                      onTap: () => onDestinationSelected(index),
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

class RevisionNavigationRail extends StatelessWidget {
  const RevisionNavigationRail({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final List<RevisionNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: RevisionColors.glassStrong,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: RevisionColors.borderBright),
          boxShadow: RevisionShadows.nav,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s,
            vertical: AppSpacing.l,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < destinations.length; index++) ...[
                _NavigationItem(
                  destination: destinations[index],
                  isSelected: selectedIndex == index,
                  onTap: () => onDestinationSelected(index),
                  isRail: true,
                ),
                if (index != destinations.length - 1)
                  const SizedBox(height: AppSpacing.s),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
    this.isRail = false,
  });

  final RevisionNavigationDestination destination;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isRail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const activeColor = RevisionColors.blue;
    final inactiveColor = theme.colorScheme.onSurface.withValues(alpha: 0.58);
    final foreground = isSelected ? activeColor : inactiveColor;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(
        horizontal: isRail ? AppSpacing.l : AppSpacing.s,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  activeColor.withValues(alpha: 0.26),
                  RevisionColors.blueDeep.withValues(alpha: 0.18),
                ],
              )
            : null,
        borderRadius: AppRadius.radiusPill,
        boxShadow: isSelected ? RevisionShadows.soft(activeColor) : null,
      ),
      child: isRail
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavigationIcon(
                  icon: isSelected
                      ? destination.selectedIcon
                      : destination.icon,
                  color: foreground,
                  glow: isSelected,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  destination.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: foreground,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavigationIcon(
                  icon: isSelected
                      ? destination.selectedIcon
                      : destination.icon,
                  color: foreground,
                  glow: isSelected,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: foreground,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
    );

    return Semantics(
      selected: isSelected,
      button: true,
      label: destination.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      ),
    );
  }
}

class _NavigationIcon extends StatelessWidget {
  const _NavigationIcon({
    required this.icon,
    required this.color,
    required this.glow,
  });

  final IconData icon;
  final Color color;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          if (glow)
            BoxShadow(
              color: RevisionColors.blue.withValues(alpha: 0.38),
              blurRadius: 18,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
