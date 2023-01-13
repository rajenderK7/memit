import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memit/utils/dark_theme_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) => Center(
        child: TextButton(
          onPressed: () {
            ref.read(darkThemeProvider.notifier).toggle();
          },
          child: const Text("Change Theme"),
        ),
      ),
    );
  }
}
