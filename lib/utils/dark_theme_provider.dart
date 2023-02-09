import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final darkThemeProvider = StateNotifierProvider<DarkThemeNotifier, bool>(
    (ref) => DarkThemeNotifier());

class DarkThemeNotifier extends StateNotifier<bool> {
  late SharedPreferences prefs;

  // by defaul the theme is `light`.
  DarkThemeNotifier() : super(false) {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    var darkMode = prefs.getBool("darkMode");
    state = darkMode ?? false;
  }

  void toggle({bool? dark}) {
    if (dark != null) {
      state = dark;
    } else {
      state = !state;
    }
    // persist the user's preffered mode.
    prefs.setBool("darkMode", state);
  }
}
