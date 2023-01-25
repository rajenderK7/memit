import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memit/utils/user_info_provider.dart';
import "package:go_router/go_router.dart";

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final TextEditingController _controller = TextEditingController();
  bool canSaveName = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const Image(
            height: 150,
            width: 150,
            image: AssetImage("assets/logo.png"),
          ),
          const SizedBox(height: 5.0),
          const Text(
            "Memit",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20.0),
          const Text(
            "Just one thing..\nWhat is you name?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              textCapitalization: TextCapitalization.words,
              controller: _controller,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Name',
                labelStyle: TextStyle(fontSize: 16),
              ),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              onChanged: (value) {
                setState(() {
                  if (_controller.text.isNotEmpty) {
                    canSaveName = true;
                  } else {
                    canSaveName = false;
                  }
                });
              },
            ),
          ),
          const SizedBox(height: 30.0),
          const Text(
            "With Memit take notes, todos and\nanything you want in a rich editing environment 🚀",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          const Spacer(),
          Consumer(builder: (context, ref, child) {
            return Container(
              width: double.infinity,
              margin:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: ElevatedButton(
                onPressed: canSaveName
                    ? () {
                        ref
                            .read(userInfoProvider.notifier)
                            .updateUsername(_controller.text);
                        ref
                            .read(userInfoProvider.notifier)
                            .updateOnboardingState(true);
                        context.go("/");
                      }
                    : null,
                child: const Text("Let's Go!"),
              ),
            );
          }),
        ],
      ),
    );
  }
}
