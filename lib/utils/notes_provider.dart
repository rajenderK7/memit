import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memit/db/db_helper.dart';
import 'package:memit/models/note.dart';

class NotesNotifier extends StateNotifier<List<Note>> {
  NotesNotifier() : super([]) {
    refreshNotes();
  }

  void refreshNotes() async {
    // state = await DBHelper.instance.getNotes();
    state = await DBHelper.instance.getNotesSorted();
  }

  void deleteNote(int id) async {
    await DBHelper.instance.deleteNote(id);
    refreshNotes();
  }
}
