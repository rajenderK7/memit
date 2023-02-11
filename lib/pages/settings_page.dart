import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:go_router/go_router.dart';
import 'package:memit/pages/home_page.dart';
import 'package:memit/utils/dark_theme_provider.dart';
import 'package:memit/utils/user_info_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final TextEditingController _controller = TextEditingController();
  List<String>? qna;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadQnA();
    _loadInfo();
    ref.read(passcodeProvider);
  }

  void _loadInfo() async {
    _controller.text = ref.read(userInfoProvider);
  }

  void _loadQnA() async {
    setState(() {
      loading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    qna = prefs.getStringList("qna");
    setState(() {
      loading = false;
    });
  }

  void _setPasscodeHandler() {
    screenLockCreate(
      title: const Text("Enter new passcode"),
      confirmTitle: const Text("Confirm new passcode"),
      context: context,
      onConfirmed: (newPasscode) {
        ref.read(passcodeProvider.notifier).setPasscode(newPasscode);
        if (qna == null) {
          context.pop();
          context.push("/forgot_passcode");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Passcode set successfully"),
            ),
          );
          context.pop();
        }
      },
    );
  }

  void _passcodeHandler() {
    if (ref.read(passcodeProvider) != null) {
      screenLock(
        context: context,
        title: const Text("Enter previous passcode to continue"),
        cancelButton: const Icon(Icons.close),
        onCancelled: () => context.pop(),
        correctString: ref.read(passcodeProvider).toString(),
        onUnlocked: () {
          context.pop(); // pop the lock screen.
          _setPasscodeHandler();
        },
        footer: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: TextButton(
            onPressed: () {
              context.pop();
              context.push("/forgot_passcode");
            },
            child: const Text(
              "Forgot passcode",
            ),
          ),
        ),
      );
    } else {
      _setPasscodeHandler();
    }
  }

  void _themeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Choose theme"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  ref.read(darkThemeProvider.notifier).toggle(dark: false);
                  context.pop();
                },
                leading: const Icon(
                  Icons.light_mode_rounded,
                ),
                title: const Text("Light"),
              ),
              ListTile(
                onTap: () {
                  ref.read(darkThemeProvider.notifier).toggle(dark: true);
                  context.pop();
                },
                leading: const Icon(
                  Icons.dark_mode_rounded,
                ),
                title: const Text("Dark"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 50,
          ),
          const Image(
            height: 100,
            width: 100,
            image: AssetImage("assets/logo.png"),
          ),
          // Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18.0),
            child: Column(
              children: [
                TextField(
                  style: const TextStyle(fontSize: 20),
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Username',
                    labelStyle: TextStyle(fontSize: 14),
                  ),
                  controller: _controller,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.check,
                  ),
                  onPressed: () {
                    ref
                        .read(userInfoProvider.notifier)
                        .updateUsername(_controller.text.trim());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Username saved successfully"),
                      ),
                    );
                  },
                  label: const Text("Save"),
                ),
              ],
            ),
          ),
          ListTile(
            onTap: _passcodeHandler,
            leading: const Icon(
              Icons.lock,
            ),
            title: const Text("Set / Reset Passcode"),
          ),
          ListTile(
            onTap: _themeDialog,
            leading: const Icon(
              Icons.color_lens,
            ),
            title: const Text("Theme"),
          ),
          ListTile(
            onTap: () => context.push("/forgot_passcode"),
            leading: const Icon(
              Icons.lock_reset,
            ),
            title: const Text("Forgot Passcode"),
          ),
        ],
      ),
    );
  }
}
