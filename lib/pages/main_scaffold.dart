import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memit/shared/memit_app_bar.dart';
import 'package:memit/widgets/bottom_navbar.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MemitDrawer(),
      appBar: const MemitAppBar(),
      body: child,
      floatingActionButton: const FloatingActionButton(
        onPressed: null,
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNavbar(),
    );
  }
}

class MemitDrawer extends StatelessWidget {
  const MemitDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Drawer Header'),
          ),
          ListTile(
            horizontalTitleGap: 5,
            style: ListTileStyle.list,
            leading: const Icon(Icons.settings_sharp),
            title: const Text('Settings'),
            onTap: () {
              context.push("/settings");
            },
          ),
          ListTile(
            horizontalTitleGap: 5,
            style: ListTileStyle.list,
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Feedback'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
        ],
      ),
    );
  }
}
