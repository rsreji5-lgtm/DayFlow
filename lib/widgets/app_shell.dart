import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final int currentIndex;
  final Widget child;

  const AppShell({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  void _go(
    BuildContext context,
    int index,
  ) {
    const routes = [
      '/home',
      '/tasks',
      '/notes',
      '/settings',
    ];

    context.go(
      routes[index],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: child,
      ),

      bottomNavigationBar:
          NavigationBar(
        selectedIndex:
            currentIndex,

        onDestinationSelected:
            (index) {
          _go(
            context,
            index,
          );
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.check_circle_outline,
            ),
            selectedIcon: Icon(
              Icons.check_circle,
            ),
            label: 'Tasks',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.note_outlined,
            ),
            selectedIcon: Icon(
              Icons.note,
            ),
            label: 'Notes',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.settings_outlined,
            ),
            selectedIcon: Icon(
              Icons.settings,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}