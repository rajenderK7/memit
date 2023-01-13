import 'package:flutter/material.dart';
import 'package:memit/shared/constants.dart';

class MemitAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MemitAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(Constants.appName),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
