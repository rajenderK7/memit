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

  Future<int> addCollection(Collection collection) async {
    int id = await DBHelper.instance.addCollection(collection);
    refreshCollections();
    return id;
  }

  void deleteCollection(int id) async {
    await DBHelper.instance.deleteCollection(id);
    refreshCollections();
  }
}
