class Note {
  final int? id;
  final String title;
  final String desc;
  final DateTime updated;
  final bool? pinned;
  final bool? secured;
  final int? color;
  final int? collection;

  Note({
    this.id,
    required this.title,
    required this.desc,
    required this.updated,
    this.pinned,
    this.secured,
    this.color,
    this.collection,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'desc': desc,
      'updated': updated,
      'pinned': pinned ?? 0,
      'secured': secured ?? 0,
      'color': color ?? 0,
      'collection': collection,
    };
  }

  static Note fromMap(Map<String, dynamic> map) => Note(
        id: map["id"] as int?,
        title: map["title"] as String,
        desc: map["desc"] as String,
        updated: DateTime.parse(map["updated"] as String),
        pinned: map["pinned"] == 1,
        secured: map["secured"] == 1,
        color: map["color"] as int?,
        collection: map["collection"] as int?,
      );
}
