class GcsImage {
  final String filename;
  final String url;
  final int size;
  final DateTime created;
  final DateTime updated;

  GcsImage({
    required this.filename,
    required this.url,
    required this.size,
    required this.created,
    required this.updated,
  });

  factory GcsImage.fromJson(Map<String, dynamic> json) {
    return GcsImage(
      filename: json['filename'] as String,
      url: json['url'] as String,
      size: json['size'] as int,
      created: DateTime.parse(json['created'] as String),
      updated: DateTime.parse(json['updated'] as String),
    );
  }
} 