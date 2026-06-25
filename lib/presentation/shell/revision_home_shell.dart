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
                    bottom: 88,
                    child: _ProfileShortcut(
                      onPressed: () => _openProfile(context),
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
              Column(
                children: [
                  RevisionNavigationRail(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: onDestinationSelected,
                    destinations: _navigationDestinations,
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.l),
                    child: _ProfileShortcut(onPressed: onProfileSelected),
                  ),
                ],
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

class _ProfileShortcut extends StatelessWidget {
  const _ProfileShortcut({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
        onPressed: onPressed,
        icon: const Icon(
          Icons.person_outline_rounded,
          color: RevisionColors.text,
          size: 22,
        ),
      ),
    );
  }
}
