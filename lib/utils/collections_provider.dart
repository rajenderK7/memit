import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memit/db/db_helper.dart';
import 'package:memit/models/collection.dart';

class CollectionNotifier extends StateNotifier<List<Collection>> {
  CollectionNotifier() : super([]) {
    refreshCollections();
  }

  void refreshCollections() async {
    state = await DBHelper.instance.getCollections();
  }

  void addCollection(Collection collection) async {
    await DBHelper.instance.addCollection(collection);
    refreshCollections();
  }

  void deleteCollection(int id) async {
    await DBHelper.instance.deleteCollection(id);
    refreshCollections();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
