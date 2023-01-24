import 'package:flutter/material.dart';
import 'package:memit/models/note.dart';
import 'package:memit/widgets/note_card.dart';

class MemitSearchDelegate extends SearchDelegate {
  final List<Note> notes;

  MemitSearchDelegate(this.notes);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = "",
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestions = notes
        .where((note) => note.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return query.isEmpty
        ? Container()
        : ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              return NoteCard(note: suggestions[index]);
            },
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = notes
        .where((note) => note.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return query.isEmpty
        ? Container()
        : ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              return NoteCard(note: suggestions[index]);
            },
          );
  }
}
