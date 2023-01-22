import 'package:memit/models/collection.dart';
import 'package:memit/models/note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

// This ```DBHelper``` class is a ```Singleton``` because we only want a
// single instance to be created at any point.

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    return _database ??= await _initDB();
  }

  Future<Database> _initDB() async {
    final String platformPath = await getDatabasesPath();
    final String databasePath = p.join(platformPath, "memit.db");

    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute(
        '''CREATE TABLE collections (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL)''');
    await db
        .execute('''CREATE TABLE notes (id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL, desc TEXT, note TEXT, updated TEXT NOT NULL, pinned INTEGER,
    secured INTEGER, color INTEGER, collection INTEGER, FOREIGN KEY(collection) REFERENCES artist(collections))''');
  }

  Future<int> insertNote(Note note) async {
    final db = await instance.database;
    return await db.insert(
      "notes",
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateNote(Note note) async {
    final db = await instance.database;
    return await db.update(
      "notes",
      note.toMap(),
      where: "id = ?",
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete(
      "notes",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<Note> getSingleNote(int id) async {
    final db = await instance.database;
    var res = await db.query(
      "notes",
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );

    if (res.isNotEmpty) {
      return Note.fromMap(res.first);
    } else {
      throw Exception("$id not found.");
    }
  }

  Future<List<Note>> getNotes() async {
    final db = await instance.database;
    var res = await db.query(
      "notes",
      orderBy: "updated DESC",
    );
    return res.map((map) => Note.fromMap(map)).toList();
  }

  Future<List<Note>> getNotesSorted() async {
    final db = await instance.database;
    var res = await db.query(
      "notes",
      orderBy: "pinned DESC, updated DESC",
    );
    return res.map((map) => Note.fromMap(map)).toList();
  }

  Future<int> addCollection(Collection collection) async {
    final db = await instance.database;
    return await db.insert(
      "collections",
      collection.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Collection>> getCollections() async {
    final db = await instance.database;
    var res = await db.query(
      "collections",
      orderBy: "id DESC",
    );
    return res.map((map) => Collection.fromMap(map)).toList();
  }

  Future<Collection?> getCollectionById(int id) async {
    final db = await instance.database;
    var res = await db.query("collections", where: "id = ?", whereArgs: [id]);
    if (res.isEmpty) return null;
    return Collection.fromMap(res.first);
  }

  Future<void> deleteCollection(int id) async {
    final db = await instance.database;
    final batch = db.batch();
    batch.delete("collections", where: "id = ?", whereArgs: [id]);
    batch.update("notes", {"collection": -1},
        where: "collection = ?", whereArgs: [id]);
    await batch.commit(noResult: true);
  }

  Future<List<Note>> getCollectionNotes(int collectionId) async {
    final db = await instance.database;
    var res = await db.query(
      "notes",
      where: "collection = ?",
      whereArgs: [collectionId],
      orderBy: "pinned DESC, updated DESC",
    );
    return res.map((map) => Note.fromMap(map)).toList();
  }

  Future<void> removeNoteFromCollection(int noteId) async {
    final db = await instance.database;
    final query = "UPDATE notes SET collection = -1 WHERE id = $noteId";
    await db.rawQuery(query);
  }
}
