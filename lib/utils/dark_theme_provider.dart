import 'package:flutter_riverpod/flutter_riverpod.dart';

class DarkThemeNotifier extends StateNotifier<bool> {
  // by defaul the theme is `light`.
  DarkThemeNotifier() : super(false);

  void toggle() {
    state = !state;
  }
}

final darkThemeProvider = StateNotifierProvider<DarkThemeNotifier, bool>(
    (ref) => DarkThemeNotifier());
