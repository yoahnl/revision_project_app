import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _wideLayoutBreakpoint) {
          return _WideHomeScaffold(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _goToDestination,
            child: navigationShell,
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: RevisionBackground(child: SafeArea(child: navigationShell)),
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
    required this.child,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RevisionBackground(
          child: Row(
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
