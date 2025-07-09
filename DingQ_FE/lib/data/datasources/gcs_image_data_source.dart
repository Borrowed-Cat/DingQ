import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/gcs_image.dart';

class GcsImageDataSource {
  final String baseUrl;
  GcsImageDataSource({required this.baseUrl});

  Future<List<GcsImage>> fetchImages({
    String prefix = 'generated/',
    int limit = 100,
    String sortBy = 'created',
    String order = 'desc',
  }) async {
    final uri = Uri.parse('$baseUrl/images').replace(queryParameters: {
      'prefix': prefix,
      'limit': limit.toString(),
      'sort_by': sortBy,
      'order': order,
    });
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final images = (data['images'] as List)
          .map((e) => GcsImage.fromJson(e))
          .toList();
      return images;
    } else {
      throw Exception('Failed to fetch images');
    }
  }
} 