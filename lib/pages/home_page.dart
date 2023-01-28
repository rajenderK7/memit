import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memit/models/note.dart';
import 'package:memit/utils/notes_provider.dart';
import 'package:memit/widgets/note_card.dart';

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  return NotesNotifier();
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
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
