class ContentItem {
  final String id;
  final String content;
  final String source;
  final DateTime capturedAt;
  String? summary;
  List<String> tags;
  bool isFavorite;

  ContentItem({
    required this.id,
    required this.content,
    required this.source,
    required this.capturedAt,
    this.summary,
    this.tags = const [],
    this.isFavorite = false,
  });

  ContentItem copyWith({
    String? content,
    String? source,
    String? summary,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return ContentItem(
      id: id,
      content: content ?? this.content,
      source: source ?? this.source,
      capturedAt: capturedAt,
      summary: summary ?? this.summary,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'source': source,
      'capturedAt': capturedAt.toIso8601String(),
      'summary': summary,
      'tags': tags,
      'isFavorite': isFavorite,
    };
  }

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] as String,
      content: json['content'] as String,
      source: json['source'] as String,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      summary: json['summary'] as String?,
      tags: List<String>.from(json['tags'] ?? []),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
