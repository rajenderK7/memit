import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memit/utils/dark_theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: MemitApp()));
}

class MemitApp extends ConsumerWidget {
  const MemitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkThemeProvider);
    return MaterialApp(
      title: 'Memit',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Memit"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Text("Memit App."),
          Consumer(
            builder: (context, ref, child) {
              final isDark = ref.watch(darkThemeProvider);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      ref.read(darkThemeProvider.notifier).toggle();
                    },
                    child: const Text("Click"),
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    color: isDark ? Colors.black : Colors.yellow,
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
