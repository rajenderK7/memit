import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MemitDrawer extends StatelessWidget {
  const MemitDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Drawer Header'),
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
