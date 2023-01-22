import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memit/db/db_helper.dart';
import 'package:memit/models/collection.dart';
import 'package:memit/models/note.dart';
import 'package:memit/pages/collections_page.dart';
import 'package:memit/pages/home_page.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path;

final showMultiRowProvider = StateProvider.autoDispose<bool>((ref) => false);

class CreatePage extends ConsumerStatefulWidget {
  final Note? note;

  const CreatePage({
    Key? key,
    this.note,
  }) : super(key: key);

  @override
  ConsumerState<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends ConsumerState<CreatePage> {
  late quill.QuillController _quillController;
  late TextEditingController _textEditingController;
  late bool _isUpdating;
  bool _isPinned = false;
  int? _currentCollectionId;
  bool _isLoading = false;
  bool _canSaveOrUpdate = false;
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  final TextEditingController _collectionController = TextEditingController();

  String _createDesc(var json) {
    String plainText = _quillController.document.toPlainText().toString();
    if (plainText.isEmpty) return "";
    String desc =
        plainText.length > 150 ? plainText.substring(0, 151) : plainText.trim();
    return desc;
  }

  SnackBar customSnackbar(String content) {
    return SnackBar(content: Text(content));
  }

  void _saveOrUpdateNote() {
    if (!_canSaveOrUpdate) return;
    if (_isUpdating) {
      _updateNote();
    } else {
      _saveNote();
    }
    ref.read(notesProvider.notifier).refreshNotes();
    final String content = _isUpdating ? "Note updated" : "Note created";
    ScaffoldMessenger.of(context).showSnackBar(customSnackbar(content));
    context.pop();
  }

  void _saveNote() async {
    var json = jsonEncode(_quillController.document.toDelta().toJson());
    final Note note = Note(
      title: _textEditingController.text,
      desc: _createDesc(json),
      note: json,
      updated: DateTime.now(),
      pinned: _isPinned,
      color: 0,
      secured: false,
      collection: _currentCollectionId ?? -1,
    );

    await DBHelper.instance.insertNote(note);
  }

  void _updateNote() async {
    var json = jsonEncode(_quillController.document.toDelta().toJson());
    final Note note = Note(
      id: widget.note!.id,
      title: _textEditingController.text,
      desc: _createDesc(json),
      note: json,
      updated: DateTime.now(),
      pinned: _isPinned,
      color: 0,
      secured: false,
      collection: _currentCollectionId ?? -1,
    );
    await DBHelper.instance.updateNote(note);
  }

  void _loadNote() async {
    setState(() {
      _isLoading = true;
    });
    _isUpdating = true;
    _isPinned = widget.note!.pinned;
    _currentCollectionId = widget.note!.collection;
    var noteJSON = jsonDecode(widget.note!.note);
    _textEditingController = TextEditingController(text: widget.note!.title);
    _canSaveOrUpdate = true;
    _quillController = quill.QuillController(
      document: quill.Document.fromJson(noteJSON),
      selection: const TextSelection.collapsed(offset: 0),
    );
    setState(() {
      _isLoading = false;
    });
  }

  void _showCreateCollectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Collection Name"),
          content: TextField(
            controller: _collectionController,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _collectionController.clear();
                context.pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Collection collection =
                    Collection(title: _collectionController.text);
                ref
                    .read(collectionsProvider.notifier)
                    .addCollection(collection);
                _collectionController.clear();
                context.pop();
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  void _showCollectionsDialog(BuildContext context) {
    final collections = ref.read(collectionsProvider);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateLocal) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.center,
            title: const Text("Choose a collection"),
            content: _currentCollectionId == null || _currentCollectionId == -1
                ? ElevatedButton.icon(
                    icon: const Icon(Icons.add_box),
                    onPressed: () {
                      context.pop();
                      _showCreateCollectionDialog(context);
                    },
                    label: const Text("Add new collection"),
                  )
                : null,
            actions: _currentCollectionId != null && _currentCollectionId != -1
                ? <Widget>[
                    const Text(
                      "Remove the note from current collection to add it to a another collection.",
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (!_isUpdating) {
                            setState(() {
                              _currentCollectionId = null;
                            });
                          } else {
                            removeNoteFromCollection(widget.note!.id!);
                          }
                          context.pop();
                        },
                        child: const Text(
                          "Remove from current collection",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ]
                : List<Widget>.generate(
                    collections.length,
                    (index) => ListTile(
                      onTap: () {
                        setState(() {
                          _currentCollectionId = collections[index].id;
                        });
                        context.pop();
                      },
                      title: Text(collections[index].title),
                    ),
                  ),
          );
        });
      },
    );
  }

  Future<void> removeNoteFromCollection(int noteId) async {
    await DBHelper.instance.removeNoteFromCollection(noteId).then((value) {
      setState(() {
        _currentCollectionId = null;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _loadNote();
    } else {
      _isUpdating = false;
      _quillController = quill.QuillController(
        document: quill.Document(),
        selection: const TextSelection.collapsed(offset: 0),
      );
      _textEditingController = TextEditingController();
    }
  }

  Future<String?> _onImagePickCallback(File file) async {
    // Copies the picked file from temporary cache to applications directory
    final appDocDir = await path.getApplicationDocumentsDirectory();
    final copiedFile =
        await file.copy('${appDocDir.path}/${p.basename(file.path)}');

    return copiedFile.path.toString();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _quillController.dispose();
    _editorScrollController.dispose();
    _editorFocusNode.dispose();
    _titleFocusNode.dispose();
    _collectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              _showCollectionsDialog(context);
            },
            icon: _currentCollectionId == null || _currentCollectionId == -1
                ? const Icon(Icons.bookmark_add_outlined)
                : const Icon(Icons.bookmark),
            disabledColor: Colors.grey,
            tooltip: "Save Note",
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isPinned = !_isPinned;
              });
            },
            icon: _isPinned
                ? const Icon(Icons.push_pin_rounded)
                : const Icon(Icons.push_pin_outlined),
            tooltip: "Pin this note",
          ),
          IconButton(
            onPressed: _canSaveOrUpdate ? _saveOrUpdateNote : null,
            icon: const Icon(Icons.check_rounded),
            disabledColor: Colors.grey,
            tooltip: "Save Note",
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
            tooltip: "More",
          ),
        ],
      ),
      body: _isLoading
          ? const CircularProgressIndicator()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_currentCollectionId != null && _currentCollectionId != -1)
                  FutureBuilder(
                    future: DBHelper.instance
                        .getCollectionById(_currentCollectionId!),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, left: 12.0, right: 12.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.bookmark,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 16,
                              ),
                              const SizedBox(
                                width: 5.0,
                              ),
                              Expanded(
                                child: Text(
                                  snapshot.data!.title,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox(
                        height: 0.0,
                      );
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          autofocus: true,
                          textCapitalization: TextCapitalization.sentences,
                          controller: _textEditingController,
                          focusNode: _titleFocusNode,
                          onSubmitted: (value) {
                            FocusScope.of(context)
                                .requestFocus(_editorFocusNode);
                          },
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Title',
                            labelStyle: TextStyle(fontSize: 16),
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                          onChanged: (value) {
                            setState(() {
                              if (_textEditingController.text.isNotEmpty) {
                                _canSaveOrUpdate = true;
                              } else {
                                _canSaveOrUpdate = false;
                              }
                            });
                          },
                        ),
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final bool showMultiRow =
                              ref.watch(showMultiRowProvider);
                          return IconButton(
                            onPressed: () {
                              bool showMultiRowValue =
                                  ref.read(showMultiRowProvider);
                              ref.read(showMultiRowProvider.notifier).state =
                                  !showMultiRowValue;
                            },
                            icon: showMultiRow
                                ? const Icon(Icons.expand_more)
                                : const Icon(Icons.expand_less),
                            tooltip: "Show all controls",
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: quill.QuillEditor(
                    controller: _quillController,
                    readOnly: false,
                    autoFocus: false,
                    expands: true,
                    scrollable: true,
                    scrollController: _editorScrollController,
                    focusNode: _editorFocusNode,
                    padding: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0)
                        : const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 20.0),
                    embedBuilders: [
                      ...FlutterQuillEmbeds.builders(),
                    ],
                  ),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    bool showMultiRow = ref.watch(showMultiRowProvider);
                    return Container(
                      decoration: BoxDecoration(
                        border: BorderDirectional(
                          top: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Center(
                        child: quill.QuillToolbar.basic(
                          controller: _quillController,
                          multiRowsDisplay: showMultiRow,
                          showAlignmentButtons: false,
                          showLeftAlignment: false,
                          showCenterAlignment: false,
                          showRightAlignment: false,
                          showJustifyAlignment: false,
                          showIndent: false,
                          showSearchButton: false,
                          showBackgroundColorButton: false,
                          showClearFormat: false,
                          showCodeBlock: false,
                          showInlineCode: false,
                          fontFamilyValues: const {
                            "Sans Serif": "Sans Serif",
                            "Serif": "Serif",
                          },
                          embedButtons: FlutterQuillEmbeds.buttons(
                            onImagePickCallback: _onImagePickCallback,
                            showCameraButton: false,
                            showVideoButton: false,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
