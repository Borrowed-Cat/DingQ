class GeneratedIcon {
  final String base64;
  final String format;
  final String filename;
  final String? gcsUrl;
  final bool gcsUploaded;

  GeneratedIcon({
    required this.base64,
    required this.format,
    required this.filename,
    this.gcsUrl,
    required this.gcsUploaded,
  });

  factory GeneratedIcon.fromJson(Map<String, dynamic> json) {
    // 다양한 필드명 처리
    final base64 = json['base64'] ?? json['image_base64'] ?? json['data'] ?? json['image'] ?? '';
    final format = json['format'] ?? json['type'] ?? 'PNG';
    final filename = json['filename'] ?? json['name'] ?? json['file'] ?? 'generated_icon.png';
    final gcsUrl = json['gcs_url'] ?? json['url'] ?? json['gcsUrl'];
    final gcsUploaded = json['gcs_uploaded'] ?? json['uploaded'] ?? false;
    
    if (base64.isEmpty) {
      throw Exception('Base64 데이터가 없습니다');
    }
    
    return GeneratedIcon(
      base64: base64,
      format: format,
      filename: filename,
      gcsUrl: gcsUrl,
      gcsUploaded: gcsUploaded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base64': base64,
      'format': format,
      'filename': filename,
      'gcs_url': gcsUrl,
      'gcs_uploaded': gcsUploaded,
    };
  }
} 