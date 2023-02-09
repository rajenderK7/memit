import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasscodeProviderNotifier extends StateNotifier<String?> {
  PasscodeProviderNotifier() : super(null) {
    getPasscode();
  }

  Future<void> getPasscode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state = prefs.getString("passcode");
  }

  Future<void> setPasscode(String passcode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("passcode", passcode);
    getPasscode();
  }
}
