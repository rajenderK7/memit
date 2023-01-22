import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({super.key});

  void _onTap(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go("/");
        break;
      case 1:
        context.go("/collections");
        break;
      default:
        context.go("/");
        break;
    }
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).location;
    if (location.contains("collections")) {
      return 1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _calculateSelectedIndex(context),
      onDestinationSelected: (int index) => _onTap(index, context),
      destinations: const [
        NavigationDestination(
          label: "Home",
          icon: Icon(
            Icons.home_filled,
          ),
          tooltip: "Home",
        ),
        NavigationDestination(
          label: "Collections",
          icon: Icon(
            Icons.bookmarks,
          ),
          tooltip: "Collections",
        ),
      ],
    );
  }
}
