import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:memit/pages/home_page.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasscodePage extends ConsumerStatefulWidget {
  const ForgotPasscodePage({super.key});

  @override
  ConsumerState<ForgotPasscodePage> createState() => _ForgotPasscodePageState();
}

class _ForgotPasscodePageState extends ConsumerState<ForgotPasscodePage> {
  final TextEditingController _answerController = TextEditingController();
  String? err;
  bool loading = false;
  List<String>? qna;

  @override
  void initState() {
    super.initState();
    _loadQnA();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
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

  void _setPasscodeHandler(BuildContext ctx) {
    screenLockCreate(
      title: const Text("Enter new passcode"),
      confirmTitle: const Text("Confirm new passcode"),
      context: context,
      onConfirmed: (newPasscode) {
        ref.read(passcodeProvider.notifier).setPasscode(newPasscode);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Passcode reset successfully ✅"),
          ),
        );
        ctx.pop();
        _answerController.clear();
      },
    );
  }

  void _validateAns(BuildContext ctx, String answer) {
    if (answer.trim() == qna![1]) {
      setState(() {
        err = null;
      });
      _setPasscodeHandler(ctx);
    } else {
      setState(() {
        err = "Incorrect answer";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  if (qna != null)
                    Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "What is your favorite color ?",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextField(
                          controller: _answerController,
                          decoration: InputDecoration(
                            hintText:
                                "Answer the question correctly to reset passcode",
                            hintStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) {
                            if (err != null) {
                              setState(() {
                                err = null;
                              });
                            }
                          },
                          onSubmitted: (answer) {
                            // TODO: Validate answer
                            _validateAns(context, answer);
                          },
                        ),
                        if (err != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              err.toString(),
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  // TODO: Set or Reset QnA
                ],
              ),
            ),
    );
  }
}
