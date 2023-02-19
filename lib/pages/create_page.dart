import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:memit/db/db_helper.dart';
import 'package:memit/models/collection.dart';
import 'package:memit/models/note.dart';
import 'package:memit/pages/collections_page.dart';
import 'package:memit/pages/home_page.dart';
import 'package:memit/utils/dark_theme_provider.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';

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
  final ScreenshotController _screenshotController = ScreenshotController();
  late quill.QuillController _quillController;
  late TextEditingController _textEditingController;
  late bool _isUpdating;
  bool _isPinned = false;
  bool _isSecured = false;
  int? _currentCollectionId;
  bool _isLoading = false;
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  final TextEditingController _collectionController = TextEditingController();

  String _createDesc(var json) {
    if (_quillController.document.isEmpty()) return "";
    String plainText = _quillController.document.toPlainText();
    String desc = plainText.length > 150
        ? plainText.substring(0, 151).trim()
        : plainText.trim();
    return desc.replaceAll(RegExp(r'(\n){2,}'), "\n");
  }

  SnackBar customSnackbar(String content, {Color? color}) {
    return SnackBar(
      content: Text(
        content,
        style: TextStyle(color: color),
      ),
    );
  }

  bool notUpdated(String noteJson) {
    return widget.note!.title == _textEditingController.text &&
        widget.note!.note == noteJson &&
        widget.note!.pinned == _isPinned &&
        widget.note!.secured == _isSecured &&
        widget.note!.color == 0 &&
        widget.note!.collection == _currentCollectionId;
  }

  void _saveOrUpdateNote() {
    if (_textEditingController.text.isEmpty &&
        _quillController.document.isEmpty()) {
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackbar("Both the title and content can't be empty!"),
      );
      return;
    }

    var json = jsonEncode(_quillController.document.toDelta().toJson());

    if (_isUpdating) {
      if (notUpdated(json)) {
        context.pop();
        return;
      }
      _updateNote(json);
    } else {
      _saveNote(json);
    }
    ref.read(notesProvider.notifier).refreshNotes();
    final String content =
        _isUpdating ? "Note updated successfully" : "Note created successfully";
    ScaffoldMessenger.of(context).showSnackBar(customSnackbar(content));
    context.pop();
  }

  Note createNote(String json, {int? id}) {
    return Note(
      title: _textEditingController.text,
      id: id ?? widget.note?.id,
      desc: _createDesc(json),
      note: json,
      updated: DateTime.now(),
      pinned: _isPinned,
      color: 0,
      secured: _isSecured,
      collection: _currentCollectionId ?? -1,
    );
  }

  void _saveNote(String json) async {
    final note = createNote(json);
    await DBHelper.instance.insertNote(note);
  }

  void _updateNote(String json) async {
    final note = createNote(json);
    await DBHelper.instance.updateNote(note);
  }

  void _loadNote() async {
    setState(() {
      _isLoading = true;
    });
    _isUpdating = true;
    _isPinned = widget.note!.pinned;
    _isSecured = widget.note!.secured;
    _currentCollectionId = widget.note!.collection;
    var noteJSON = jsonDecode(widget.note!.note);
    _textEditingController = TextEditingController(text: widget.note!.title);
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
            textCapitalization: TextCapitalization.words,
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
            contentPadding: const EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: 16.0,
              bottom: 0.0,
            ),
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

  Future<String?> _onImagePickCallback(File file) async {
    // Copies the picked file from temporary cache to applications directory
    final appDocDir = await path.getApplicationDocumentsDirectory();
    final copiedFile =
        await file.copy('${appDocDir.path}/${p.basename(file.path)}');

    return copiedFile.path.toString();
  }

  // Future<void> _shareAsImage() async {
  //   if (_quillController.document.isEmpty() &&
  //       _textEditingController.text.isEmpty) return;
  //   try {
  //     RenderRepaintBoundary boundary = _globalKey.currentContext!
  //         .findRenderObject() as RenderRepaintBoundary;

  //     if (boundary.debugNeedsPaint) {
  //       Timer(const Duration(seconds: 1), () => _shareAsImage());
  //       return;
  //     }

  //     ui.Image image = await boundary.toImage();
  //     final directory = (await path.getExternalStorageDirectory())!.path;
  //     debugPrint(directory);

  //     ByteData? byteData =
  //         await image.toByteData(format: ui.ImageByteFormat.png);

  //     if (byteData != null) {
  //       Uint8List pngBytes = byteData.buffer.asUint8List();
  //       String filePathAndName =
  //           "$directory/note_${DateTime.now().toIso8601String().replaceAllMapped(RegExp(r'[-:.]'), (Match match) {
  //         return '';
  //       })}.png";
  //       debugPrint(filePathAndName);
  //       File imgFile = File(filePathAndName);
  //       imgFile.writeAsBytesSync(pngBytes);
  //       await Share.shareXFiles([XFile(imgFile.path)]);
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(const SnackBar(content: Text("Something went wrong!")));
  //     return;
  //   }
  // }

  Future<void> _shareAsImage() async {
    if (_quillController.document.isEmpty() &&
        _textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Note is empty")));
      return;
    }
    try {
      final image = await _screenshotController.capture();

      final directory = (await path.getExternalStorageDirectory())!.path;
      debugPrint(directory);

      if (image != null) {
        String filePathAndName =
            "$directory/note_${DateTime.now().toIso8601String().replaceAllMapped(RegExp(r'[-:.]'), (Match match) {
          return '';
        })}.png";
        debugPrint(filePathAndName);
        File imgFile = File(filePathAndName);
        imgFile.writeAsBytesSync(image);
        await Share.shareXFiles([XFile(imgFile.path)]);
      }
    } catch (e) {
      debugPrint(e.toString());
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Something went wrong!")));
      return;
    }
  }

  Future<void> _shareAsText() async {
    String text = "";
    if (_textEditingController.text.isNotEmpty) {
      text += "${_textEditingController.text}\n";
    }
    text += _quillController.document.toPlainText();
    if (text.isNotEmpty) {
      await Share.share(text);
    }
  }

  void _shareDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                onTap: () {
                  context.pop();
                  _shareAsText();
                },
                leading: const Icon(
                  Icons.text_fields,
                ),
                title: const Text(
                  "Share as Text",
                ),
                subtitle: Text(
                  "Recommended for large notes",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                onTap: () {
                  context.pop();
                  _shareAsImage();
                },
                leading: const Icon(
                  Icons.image,
                ),
                title: const Text("Share as Image"),
              ),
            ],
          ),
        );
      },
    );
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
    ref.read(collectionsProvider);
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
    return WillPopScope(
      onWillPop: () async {
        if (_textEditingController.text.isNotEmpty ||
            !_quillController.document.isEmpty()) {
          _saveOrUpdateNote();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor:
            !ref.read(darkThemeProvider) ? Colors.white : Colors.black,
        appBar: AppBar(
          backgroundColor:
              !ref.read(darkThemeProvider) ? Colors.white : Colors.black,
          leading: IconButton(
            onPressed: () {
              if (_textEditingController.text.isEmpty &&
                  _quillController.document.isEmpty()) {
                context.pop();
              } else {
                _saveOrUpdateNote();
              }
            },
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            IconButton(
              onPressed: () {
                final securedPrefs = ref.read(passcodeProvider);
                if (securedPrefs == null) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                          title: Text("Security passcode not set"),
                          content:
                              Text("Add a security code in the settings page."),
                        );
                      });
                } else {
                  setState(() {
                    _isSecured = !_isSecured;
                  });
                }
              },
              icon: _isSecured
                  ? const Icon(Icons.lock)
                  : const Icon(Icons.lock_open),
              tooltip: "Secure Note",
            ),
            IconButton(
              onPressed: () {
                _showCollectionsDialog(context);
              },
              icon: _currentCollectionId == null || _currentCollectionId == -1
                  ? const Icon(Icons.bookmark_add_outlined)
                  : const Icon(Icons.bookmark),
              disabledColor: Colors.grey,
              tooltip: "Add to collection",
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
              onPressed: _shareDialog,
              icon: const Icon(Icons.share_rounded),
              tooltip: "Share note",
            ),
            const SizedBox(
              width: 5,
            ),
          ],
        ),
        body: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isUpdating)
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, left: 12.0, right: 12.0),
                      child: Row(
                        children: [
                          if (_currentCollectionId != null &&
                              _currentCollectionId != -1)
                            Expanded(
                              child: FutureBuilder(
                                future: DBHelper.instance
                                    .getCollectionById(_currentCollectionId!),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Row(
                                      children: [
                                        Icon(
                                          Icons.bookmark,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          size: 16,
                                        ),
                                        const SizedBox(
                                          width: 5.0,
                                        ),
                                        Expanded(
                                          child: Text(
                                            snapshot.data!.title,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return const SizedBox(
                                    height: 0.0,
                                  );
                                },
                              ),
                            ),
                          Row(
                            children: [
                              Text(
                                DateFormat.yMMMd().format(widget.note!.updated),
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                DateFormat("hh:mm a")
                                    .format(widget.note!.updated),
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: TextField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: _textEditingController,
                      focusNode: _titleFocusNode,
                      onSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_editorFocusNode);
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
                    ),
                  ),
                  Expanded(
                    child: Screenshot(
                      controller: _screenshotController,
                      child: Container(
                        color: !ref.read(darkThemeProvider)
                            ? Colors.white
                            : Colors.black,
                        padding: MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? const EdgeInsets.only(
                                top: 10.0, left: 12.0, right: 12.0)
                            : const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 20.0),
                        child: quill.QuillEditor(
                          controller: _quillController,
                          readOnly: false,
                          autoFocus: !_isUpdating,
                          expands: true,
                          scrollable: true,
                          showCursor:
                              MediaQuery.of(context).viewInsets.bottom > 0,
                          scrollController: _editorScrollController,
                          focusNode: _editorFocusNode,
                          padding: const EdgeInsets.all(0),
                          embedBuilders: [
                            ...FlutterQuillEmbeds.builders(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: BorderDirectional(
                        top: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: quill.QuillToolbar.basic(
                        controller: _quillController,
                        multiRowsDisplay: false,
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
                  )
                ],
              ),
      ),
    );
  }
}
