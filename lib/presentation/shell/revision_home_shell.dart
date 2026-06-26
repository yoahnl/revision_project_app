import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/app/router/app_routes.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_colors.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_shadows.dart';
import 'package:Neralune/presentation/theme/app_spacing.dart';
import 'package:Neralune/presentation/widgets/revision_background.dart';
import 'package:Neralune/presentation/widgets/revision_navigation.dart';

class RevisionHomeShell extends StatelessWidget {
  const RevisionHomeShell({super.key, required this.navigationShell});

  static const double _wideLayoutBreakpoint = 840;
  static const double _maxContentWidth = 900;

  final StatefulNavigationShell navigationShell;

  void _goToDestination(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _openProfile(BuildContext context) {
    context.push(AppRoutes.profile);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _wideLayoutBreakpoint) {
          return _WideHomeScaffold(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _goToDestination,
            onProfileSelected: () => _openProfile(context),
            child: navigationShell,
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: RevisionBackground(
            child: SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  navigationShell,
                  Positioned(
                    right: AppSpacing.l,
                    top: AppSpacing.l,
                    child: _ProfileMenuButton(
                      onProfileSelected: () => _openProfile(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: RevisionBottomNavigation(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _goToDestination,
            destinations: _navigationDestinations,
          ),
        );
      },
    );
  }
}

class _WideHomeScaffold extends StatelessWidget {
  const _WideHomeScaffold({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onProfileSelected,
    required this.child,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onProfileSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RevisionBackground(
          child: Row(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Row(
                      children: [
                        RevisionNavigationRail(
                          selectedIndex: selectedIndex,
                          onDestinationSelected: onDestinationSelected,
                          destinations: _navigationDestinations,
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: RevisionHomeShell._maxContentWidth,
                              ),
                              child: child,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: AppSpacing.l,
                      right: AppSpacing.l,
                      child: _ProfileMenuButton(
                        onProfileSelected: onProfileSelected,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const List<RevisionNavigationDestination> _navigationDestinations = [
  RevisionNavigationDestination(
    label: 'Aujourd’hui',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
  ),
  RevisionNavigationDestination(
    label: 'Cours',
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book_rounded,
  ),
  RevisionNavigationDestination(
    label: 'Progrès',
    icon: Icons.trending_up_rounded,
    selectedIcon: Icons.trending_up_rounded,
  ),
];

class _ProfileMenuButton extends StatelessWidget {
  const _ProfileMenuButton({required this.onProfileSelected});

  final VoidCallback onProfileSelected;

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.46),
      builder: (sheetContext) {
        return _ProfileBottomSheet(
          onProfileSelected: () {
            Navigator.of(sheetContext).pop();
            onProfileSelected();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('profile-menu-button'),
      decoration: BoxDecoration(
        color: RevisionColors.glassStrong,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: RevisionColors.borderBright),
        boxShadow: RevisionShadows.nav,
      ),
      child: IconButton(
        tooltip: 'Profil',
        constraints: const BoxConstraints.tightFor(width: 44, height: 44),
        padding: EdgeInsets.zero,
        onPressed: () => _openSheet(context),
        icon: const Icon(
          Icons.person_outline_rounded,
          color: RevisionColors.text,
          size: 22,
        ),
      ),
    );
  }
}

class _ProfileBottomSheet extends StatelessWidget {
  const _ProfileBottomSheet({required this.onProfileSelected});

  final VoidCallback onProfileSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('profile-bottom-sheet'),
      decoration: const BoxDecoration(
        color: RevisionColors.ink2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: RevisionColors.borderBright)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.m,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: RevisionColors.borderBright,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const SizedBox(width: 42, height: 4),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Compte',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: RevisionColors.text,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  key: const ValueKey('profile-sheet-profile-action'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: RevisionColors.border),
                  ),
                  tileColor: RevisionColors.glassStrong,
                  leading: const Icon(
                    Icons.person_outline_rounded,
                    color: RevisionColors.textMuted,
                  ),
                  title: Text(
                    'Profil',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: RevisionColors.text,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: RevisionColors.textMuted,
                  ),
                  onTap: onProfileSelected,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
