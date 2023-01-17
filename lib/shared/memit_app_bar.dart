import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memit/shared/constants.dart';
import 'package:memit/utils/dark_theme_provider.dart';

class MemitAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MemitAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(Constants.appName),
      centerTitle: true,
      actions: [
        Consumer(builder: (context, ref, child) {
          final bool darkMode = ref.watch(darkThemeProvider);
          return IconButton(
            onPressed: () {
              ref.read(darkThemeProvider.notifier).toggle();
            },
            icon: darkMode
                ? const Icon(
                    Icons.light_mode_rounded,
                  )
                : const Icon(
                    Icons.dark_mode_rounded,
                  ),
          );
        })
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
