class Collection {
  final int? id;
  final String title;

  Collection({
    this.id,
    required this.title,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
    };
  }

  static Collection fromMap(Map<String, dynamic> map) => Collection(
        id: map["id"] as int?,
        title: map["title"] as String,
      );
}
