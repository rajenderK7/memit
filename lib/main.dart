import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memit/shared/color_schemes.g.dart';
import 'package:memit/shared/constants.dart';
import 'package:memit/utils/dark_theme_provider.dart';
import 'package:memit/utils/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const ProviderScope(child: MemitApp()));
}

class MemitApp extends ConsumerWidget {
  const MemitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkThemeProvider);
    return MaterialApp.router(
      title: Constants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: lightColorScheme,
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      darkTheme: ThemeData.from(
        colorScheme: darkColorScheme,
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context)
            .textTheme
            .apply(bodyColor: Theme.of(context).colorScheme.onPrimary)),
      ),
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
