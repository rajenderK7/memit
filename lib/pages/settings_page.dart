import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memit/utils/dark_theme_provider.dart';
import 'package:memit/utils/user_info_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  void _loadInfo() async {
    _controller.text = ref.read(userInfoProvider);
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Username',
                labelStyle: TextStyle(fontSize: 16),
              ),
              controller: _controller,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            onPressed: () {
              ref
                  .read(userInfoProvider.notifier)
                  .updateUsername(_controller.text.trim());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Username saved succesfully 😀"),
                ),
              );
            },
            label: const Text("Save"),
          ),
          const SizedBox(
            height: 20,
          ),
          Switch(
            value: ref.watch(darkThemeProvider),
            onChanged: (onChanged) {
              ref.read(darkThemeProvider.notifier).toggle();
            },
          ),
          const SizedBox(
            height: 5,
          ),
          ref.read(darkThemeProvider)
              ? const Text("Switch to Light mode")
              : const Text("Switch to Dark mode")
        ],
      ),
    );
  }
}
