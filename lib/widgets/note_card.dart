import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memit/models/note.dart';
import 'package:memit/pages/home_page.dart';
import 'package:go_router/go_router.dart';

class NoteCard extends ConsumerWidget {
  const NoteCard({
    Key? key,
    required this.note,
  }) : super(key: key);

  final Note note;

  // void _longPressDialog(BuildContext context, WidgetRef ref) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text("To be implemented"),
  //         actions: [
  //           TextButton(
  //             onPressed: () => context.pop(),
  //             child: const Text("Cancel"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

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
                ref.read(notesProvider.notifier).deleteNote(note.id!);
                context.pop();
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
          onTap: () => context.push("/readNote/${note.id}"),
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
                    Text(
                      DateFormat.yMMMd().format(note.updated),
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (note.pinned)
                      const Icon(
                        Icons.push_pin_rounded,
                        size: 18,
                      ),
                  ],
                ),
                const SizedBox(
                  height: 6.0,
                ),
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
                  Text(
                    note.desc,
                    style: TextStyle(
                      fontSize: 13,
                      overflow: TextOverflow.ellipsis,
                      color: Theme.of(context).colorScheme.secondary,
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
