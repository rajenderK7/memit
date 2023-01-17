import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memit/models/note.dart';
import 'package:memit/pages/home_page.dart';
import 'package:memit/widgets/note_card.dart';

final currentCollectionProvider = StateProvider.autoDispose<int>((ref) => -1);

final collectionNotesProvider = Provider.autoDispose<List<Note>>((ref) {
  final notes = ref.watch(notesProvider);
  final currentCollection = ref.watch(currentCollectionProvider);
  return notes.where((note) => note.collection == currentCollection).toList();
});

class CollectionNotesPage extends ConsumerWidget {
  final String collectionTitle;
  const CollectionNotesPage({required this.collectionTitle, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(collectionNotesProvider);
    return Scaffold(
      appBar: AppBar(),
      body: notes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                      left: 8.0,
                      right: 8.0,
                    ),
                    child: Text(
                      "$collectionTitle collection",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      Note note = notes[index];
                      return NoteCard(note: note);
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
