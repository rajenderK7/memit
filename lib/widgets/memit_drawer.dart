import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memit/utils/user_info_provider.dart';

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
          Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            color: Theme.of(context).colorScheme.primary,
            height: 200,
            child: Consumer(
              builder: (context, ref, child) {
                final username = ref.watch(userInfoProvider);
                return Center(
                  child: Text(
                    'Hi $username!',
                    style: TextStyle(
                        fontSize: 24,
                        color: Theme.of(context).colorScheme.surface),
                  ),
                );
              },
            ),
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
          // ListTile(
          //   horizontalTitleGap: 5,
          //   style: ListTileStyle.list,
          //   leading: const Icon(Icons.help_outline),
          //   title: const Text('Help & Feedback'),
          //   onTap: () {
          //     // final prefs = await SharedPreferences.getInstance();
          //     // prefs.setBool("onBoarded", false);
          //     // TODO: Update the state of the app.
          //     // ...
          //   },
          // ),
        ],
      ),
    );
  }
}
