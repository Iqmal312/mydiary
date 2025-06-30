class DiaryEntry {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String mood;
  final String? imagePath; // new field

  DiaryEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'mood': mood,
      'imagePath': imagePath, // new
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: DateTime.parse(map['date']),
      mood: map['mood'],
      imagePath: map['imagePath'], // new
    );
  }

  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
