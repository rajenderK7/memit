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
  final TextEditingController _questionQnAController = TextEditingController();
  final TextEditingController _answerQnAController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  String? err;
  bool loading = false;
  bool validQnA = false;
  List<String>? qna;

  @override
  void initState() {
    super.initState();
    _loadQnA();
  }

  @override
  void dispose() {
    _answerController.dispose();
    _questionQnAController.dispose();
    _answerQnAController.dispose();
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

  void setQnA() async {
    final prefs = await SharedPreferences.getInstance();
    qna = prefs.getStringList("qna");
    final q = _questionQnAController.text.trim();
    final a = _answerQnAController.text.trim();
    prefs.setStringList("qna", [q, a]);
    _questionQnAController.clear();
    _answerQnAController.clear();
    _loadQnA();
  }

  void _qnaEditor() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Enter security question"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _questionQnAController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      label: Text("Question"),
                      hintText: "Enter a question that only you can answer",
                      hintStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        validQnA = _questionQnAController.text.isNotEmpty &&
                            _answerQnAController.text.isNotEmpty;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _answerQnAController,
                    decoration: const InputDecoration(
                      label: Text("Answer"),
                      hintText: "Tip: Use all lower case letters",
                      hintStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        validQnA = _answerQnAController.text.isNotEmpty &&
                            _questionQnAController.text.isNotEmpty;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _questionQnAController.clear();
                    _answerQnAController.clear();
                    context.pop();
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: validQnA
                      ? () {
                          setQnA();
                          context.pop();
                        }
                      : null,
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _resetQuestionHandler(BuildContext ctx) {
    if (qna != null) {
      screenLock(
        context: context,
        title: const Text("Enter passcode to continue"),
        correctString: ref.read(passcodeProvider).toString(),
        cancelButton: const Icon(Icons.close),
        onCancelled: () => ctx.pop(),
        onUnlocked: () {
          ctx.pop();
          _qnaEditor();
        },
      );
    } else {
      _qnaEditor();
    }
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
                        Text(
                          qna![0],
                          style: const TextStyle(
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
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: const [
                            Expanded(
                              child: Divider(
                                endIndent: 10,
                                thickness: 0.1,
                              ),
                            ),
                            Text("or"),
                            Expanded(
                              child: Divider(
                                indent: 10,
                                thickness: 0.1,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _answerController.clear();
                        _resetQuestionHandler(context);
                      },
                      child: (qna != null)
                          ? const Text("Reset security question")
                          : const Text("Set security question"),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Memit strongly recommends to set a security question if not already set 😀",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.orangeAccent,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
