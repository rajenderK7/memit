import 'dart:convert';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';
import 'package:memit/db/db_helper.dart';
import 'package:memit/models/note.dart';
import 'package:go_router/go_router.dart';
import 'package:memit/pages/collections_page.dart';
import 'package:memit/pages/home_page.dart';
import 'package:share_plus/share_plus.dart';

class ReadNotePage extends ConsumerStatefulWidget {
  final int id;
  const ReadNotePage({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<ReadNotePage> createState() => _ReadNotePageState();
}

class _ReadNotePageState extends ConsumerState<ReadNotePage> {
  late quill.QuillController _quillController;
  late Note _note;
  bool _isLoading = false;
  final SnackBar deletedSnackbar =
      const SnackBar(content: Text("Note deleted"));
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  void _loadNote() async {
    setState(() {
      _isLoading = true;
    });
    _note = await DBHelper.instance.getSingleNote(widget.id);
    var noteJSON = jsonDecode(_note.note);
    _quillController = quill.QuillController(
      document: quill.Document.fromJson(noteJSON),
      selection: const TextSelection.collapsed(offset: 0),
    );
    setState(() {
      _isLoading = false;
    });
  }

  void _deleteNoteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete this note ?"),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                ref.read(notesProvider.notifier).deleteNote(_note.id!);
                ScaffoldMessenger.of(context).showSnackBar(deletedSnackbar);
                context.pushReplacement("/");
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  // TODO: Implement sharing the note while
  // retaining all the delta features, maybe
  // as a text file or Memit note itself.
  Future<void> _shareNote() async {
    var text = _quillController.document.toPlainText();
    await Share.share(text);
  }

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  @override
  void dispose() {
    super.dispose();
    _quillController.dispose();
    _editorScrollController.dispose();
    _editorFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              _shareNote();
            },
            icon: const Icon(Icons.share_rounded),
            tooltip: "Share note",
          ),
          IconButton(
            onPressed: () {
              context.pushReplacement("/create", extra: _note);
            },
            icon: const Icon(Icons.edit),
            tooltip: "Edit note",
          ),
          IconButton(
            onPressed: () {
              _deleteNoteDialog();
            },
            icon: const Icon(Icons.delete),
            tooltip: "Delete note",
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat.yMMMd().format(_note.updated),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          Expanded(
                            child: Consumer(builder: (context, ref, child) {
                              final allCollections =
                                  ref.watch(collectionsProvider);
                              final collections = allCollections.where(
                                  (collection) =>
                                      collection.id == _note.collection);
                              if (collections.isEmpty) {
                                return const SizedBox(
                                  height: 0,
                                  width: 0,
                                );
                              }
                              final collectionName = collections.first.title;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Center(
                                  child: Text(
                                    collectionName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          Text(
                            DateFormat("hh:mm a").format(_note.updated),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        _note.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
                Expanded(
                  child: quill.QuillEditor(
                    controller: _quillController,
                    readOnly: true,
                    autoFocus: false,
                    expands: true,
                    scrollable: true,
                    scrollController: _editorScrollController,
                    focusNode: _editorFocusNode,
                    padding: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10)
                        : const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 20),
                    embedBuilders: [
                      ...FlutterQuillEmbeds.builders(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
