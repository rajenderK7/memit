import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userInfoProvider =
    StateNotifierProvider<UserInfoNotifer, String>((ref) => UserInfoNotifer());

class UserInfoNotifer extends StateNotifier<String> {
  UserInfoNotifer() : super("") {
    loadPrefs();
  }

  void loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString("username") ?? "Human";
  }

  void updateUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("username", username);
    loadPrefs();
  }
}
