import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memit/models/collection.dart';
import 'package:memit/pages/collection_notes_page.dart';
import 'package:memit/utils/collections_provider.dart';
import 'package:go_router/go_router.dart';

final collectionsProvider =
    StateNotifierProvider<CollectionNotifier, List<Collection>>(
        (ref) => CollectionNotifier());

class CollectionsPage extends ConsumerStatefulWidget {
  const CollectionsPage({super.key});

  @override
  ConsumerState<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends ConsumerState<CollectionsPage> {
  final TextEditingController _collectionController = TextEditingController();

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
              onPressed: () {
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

  void _deleteCollection(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete this collection ?"),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                ref.read(collectionsProvider.notifier).deleteCollection(id);
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
  void dispose() {
    _collectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(collectionsProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_box),
              onPressed: () {
                _showCreateCollectionDialog(context);
              },
              label: const Text("Add new collection"),
            ),
          ),
          collections.isEmpty
              ? Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    child:
                        const Text("Make collections to organize your work."),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: collections.length,
                    itemBuilder: (context, index) {
                      Collection collection = collections[index];
                      return Card(
                        clipBehavior: Clip.hardEdge,
                        margin: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            ref.read(currentCollectionProvider.notifier).state =
                                collection.id!;
                            context.push(
                                "/collectionNotes/${collection.id}/${collection.title}");
                          },
                          child: ListTile(
                            leading: const Icon(Icons.bookmark),
                            title: Text(collection.title),
                            trailing: IconButton(
                              onPressed: () {
                                _deleteCollection(context, collection.id!);
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
