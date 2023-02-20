import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:intl/intl.dart';
import 'package:memit/models/note.dart';
import 'package:memit/pages/home_page.dart';
import 'package:go_router/go_router.dart';
import 'package:memit/utils/routes.dart';

class NoteCard extends ConsumerWidget {
  NoteCard({
    Key? key,
    required this.note,
  }) : super(key: key);

  final Note note;
  final _painter = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.grey
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

  void _onTap(BuildContext context, WidgetRef ref, {bool delete = false}) {
    final overlayCtx =
        ref.read(globalNavigatorProvider).currentState?.overlay?.context;
    screenLock(
      context: overlayCtx ?? context,
      title: const Text("Enter passcode to continue"),
      correctString: ref.read(passcodeProvider).toString(),
      cancelButton: const Icon(Icons.close),
      onCancelled: () => context.pop(),
      onUnlocked: () {
        context.pop(); // pop the lock screen.
        if (delete) {
          ref.read(notesProvider.notifier).deleteNote(note.id!);
          context.pop(); // delete dialog context
        } else {
          context.push("/create", extra: note);
        }
      },
      footer: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: TextButton(
          onPressed: () {
            context.pop();
            context.push("/forgot_passcode");
          },
          child: const Text(
            "Forgot passcode",
          ),
        ),
      ),
    );
  }

  void _longPressDialogHandler(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete the note ?"),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (note.secured) {
                  _onTap(context, ref, delete: true);
                } else {
                  ref.read(notesProvider.notifier).deleteNote(note.id!);
                  context.pop(); // delete dialog context
                }
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Hero(
      transitionOnUserGestures: true,
      tag: "${note.id}",
      child: Card(
        color: Theme.of(context).colorScheme.surfaceVariant,
        elevation: 0.0,
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            if (ref.read(passcodeProvider) != null) {
              if (note.secured) {
                _onTap(context, ref);
              } else {
                context.push("/create", extra: note);
              }
            } else {
              context.push("/create", extra: note);
            }
          },
          onLongPress: () {
            _longPressDialogHandler(context, ref);
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat.yMMMd().format(note.updated),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    if (note.secured)
                      const Icon(
                        Icons.lock,
                        size: 17,
                      ),
                    if (note.pinned)
                      const SizedBox(
                        width: 5,
                      ),
                    if (note.pinned)
                      const Icon(
                        Icons.push_pin_rounded,
                        size: 17,
                      ),
                  ],
                ),
                const SizedBox(
                  height: 6.0,
                ),
                if (note.title.isNotEmpty)
                  Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(
                  height: note.desc.isNotEmpty ? 4.0 : 0.0,
                ),
                if (note.desc.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: note.secured
                          ? const EdgeInsets.symmetric(horizontal: 4.0)
                          : const EdgeInsets.all(0),
                      child: Text(
                        note.desc,
                        style: TextStyle(
                          fontSize: 13,
                          overflow: TextOverflow.ellipsis,
                          color: !note.secured
                              ? Theme.of(context).colorScheme.secondary
                              : null,
                          foreground: note.secured ? _painter : null,
                        ),
                        maxLines: 4,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
