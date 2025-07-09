import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// API service for image similarity search
class ApiService {
  static const String baseUrl = 'https://dingq-api-n5rvmws25a-du.a.run.app';
  static const String searchEndpoint = '/search';

  /// Send image to similarity search API
  static Future<Map<String, dynamic>?> searchSimilarImages(
    Uint8List imageBytes, {
    Function(Map<String, dynamic>)? onResponse,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$searchEndpoint');
      
      // Create multipart request
      final request = http.MultipartRequest('POST', url);
      
      // Add image file with proper content type
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'drawing_${DateTime.now().millisecondsSinceEpoch}.png',
          contentType: MediaType('image', 'png'),
        ),
      );

      // Send request
      final response = await request.send();
      
      if (response.statusCode == 200) {
        // Read response body
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody) as Map<String, dynamic>;
        
        // Call callback if provided
        onResponse?.call(jsonResponse);
        
        return jsonResponse;
      } else {
        final errorBody = await response.stream.bytesToString();
        return null;
      }
    } catch (e) {
      return null;
    }
  }
} 