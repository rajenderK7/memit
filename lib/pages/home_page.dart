import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memit/models/note.dart';
import 'package:memit/utils/notes_provider.dart';
import 'package:memit/utils/passcode_provider.dart';
import 'package:memit/widgets/note_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  return NotesNotifier();
});

final passcodeProvider =
    StateNotifierProvider<PasscodeProviderNotifier, String?>(
        (ref) => PasscodeProviderNotifier());

final sharedPrefsProvider = FutureProvider<SharedPreferences>(
    (_) async => await SharedPreferences.getInstance());

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    ref.watch(passcodeProvider);
    return notes.isEmpty
        ? const Center(child: Text("Add notes, todos, scripts and more..😀"))
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return NoteCard(note: notes[index]);
              },
            ),
          );
  }
}
