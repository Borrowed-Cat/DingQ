/// 딩벳 엔티티
class Dingbat {
  final String id;
  final String name;
  final String assetPath;
  final List<String> tags;
  final String unicode;

  const Dingbat({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.tags,
    required this.unicode,
  });

  /// 태그가 일치하는지 확인
  bool hasTag(String tag) {
    return tags.contains(tag.toLowerCase());
  }

  /// 모든 태그를 포함하는지 확인
  bool hasAllTags(List<String> tags) {
    return tags.every((tag) => this.tags.contains(tag.toLowerCase()));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Dingbat && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Dingbat(id: $id, name: $name, tags: $tags)';
} 