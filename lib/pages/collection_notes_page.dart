import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memit/db/db_helper.dart';
import 'package:memit/models/note.dart';
import 'package:memit/pages/home_page.dart';
import 'package:memit/widgets/note_card.dart';

final currentCollectionProvider = StateProvider.autoDispose<int>((ref) => -1);

final collectionNotesProvider = Provider.autoDispose<List<Note>>((ref) {
  final notes = ref.watch(notesProvider);
  final currentCollection = ref.watch(currentCollectionProvider);
  return notes.where((note) => note.collection == currentCollection).toList();
});

class CollectionNotesPage extends StatefulWidget {
  final int collectionId;
  final String collectionTitle;
  const CollectionNotesPage(
      {required this.collectionId, required this.collectionTitle, super.key});

  @override
  State<CollectionNotesPage> createState() => _CollectionNotesPageState();
}

class _CollectionNotesPageState extends State<CollectionNotesPage> {
  late List<Note> notes;

  void _loadNotes() async {
    notes = await DBHelper.instance.getCollectionNotes(widget.collectionId);
  }

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
          ),
          child: Text(
            widget.collectionTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: FutureBuilder(
          future: DBHelper.instance.getCollectionNotes(widget.collectionId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return const Center(
                child: Text("No notes added to this collection 😥"),
              );
            } else if (snapshot.hasData) {
              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  Note note = snapshot.data?.elementAt(index) as Note;
                  return NoteCard(note: note);
                },
              );
            }
            return const Center(
              child: Text("No notes added to this collection 😥"),
            );
          },
        ),
      ),
    );
  }
}
