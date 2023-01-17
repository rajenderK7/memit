import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memit/db/db_helper.dart';
import 'package:memit/models/note.dart';
import 'package:memit/pages/home_page.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path;

final showMultiRowProvider = StateProvider.autoDispose<bool>((ref) => false);
final isPinnedProvider = StateProvider.autoDispose<bool>((ref) => false);

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
  bool _isLoading = false;
  bool _canSaveOrUpdate = false;
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  String _createDesc(var json) {
    String plainText = _quillController.document.toPlainText().toString();
    String desc =
        plainText.length > 150 ? plainText.substring(1, 151) : plainText;
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
    context.go("/");
  }

  void _saveNote() async {
    var json = jsonEncode(_quillController.document.toDelta().toJson());
    bool isPinnedValue = ref.read(isPinnedProvider);
    final Note note = Note(
      title: _textEditingController.text,
      desc: _createDesc(json),
      note: json,
      updated: DateTime.now(),
      pinned: isPinnedValue,
      color: 0,
      secured: false,
      collection: -1,
    );

    await DBHelper.instance.insertNote(note);
  }

  void _updateNote() async {
    var json = jsonEncode(_quillController.document.toDelta().toJson());
    bool isPinnedValue = ref.read(isPinnedProvider);
    final Note note = Note(
      id: widget.note!.id,
      title: _textEditingController.text,
      desc: _createDesc(json),
      note: json,
      updated: DateTime.now(),
      pinned: isPinnedValue,
      color: 0,
      secured: false,
      collection: -1,
    );
    await DBHelper.instance.updateNote(note);
  }

  void _loadNote() async {
    setState(() {
      _isLoading = true;
    });
    _isUpdating = true;
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
    super.dispose();
    _textEditingController.dispose();
    _quillController.dispose();
    _editorScrollController.dispose();
    _editorFocusNode.dispose();
    _titleFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final bool isPinned = ref.watch(isPinnedProvider);
              return IconButton(
                onPressed: () {
                  final bool isPinnedValue = ref.read(isPinnedProvider);
                  ref.read(isPinnedProvider.notifier).state = !isPinnedValue;
                },
                icon: isPinned
                    ? const Icon(Icons.push_pin_rounded)
                    : const Icon(Icons.push_pin_outlined),
                tooltip: "Pin this note",
              );
            },
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
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
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
                              vertical: 0, horizontal: 10)
                          : const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 20),
                      embedBuilders: [
                        ...FlutterQuillEmbeds.builders(),
                      ],
                    ),
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
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: quill.QuillToolbar.basic(
                        controller: _quillController,
                        multiRowsDisplay: showMultiRow,
                        embedButtons: FlutterQuillEmbeds.buttons(
                          onImagePickCallback: _onImagePickCallback,
                          // webImagePickImpl: _webImagePickImpl,
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
