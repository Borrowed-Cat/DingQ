import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// API service for image similarity search
class ApiService {
  static const String baseUrl = 'https://dingq-backend-595082861157.asia-northeast3.run.app';
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

      // Debug: Print request details
      print('=== API Request ===');
      print('URL: $url');
      print('Method: POST');
      print('Image Size: ${imageBytes.length} bytes');
      print('Filename: drawing_${DateTime.now().millisecondsSinceEpoch}.png');
      print('==================');

      // Send request
      final response = await request.send();
      
      if (response.statusCode == 200) {
        // Read response body
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody) as Map<String, dynamic>;
        
        // Log response to console
        print('=== API Response ===');
        print('Status Code: ${response.statusCode}');
        print('Processing Time: ${jsonResponse['processing_time']} seconds');
        print('Total Results: ${jsonResponse['total_results']}');
        print('Top 5 Results:');
        
        final top5 = jsonResponse['top5'] as List;
        for (int i = 0; i < top5.length; i++) {
          final result = top5[i] as Map<String, dynamic>;
          print('  ${i + 1}. ${result['label']} (Score: ${result['score']})');
          print('     URL: ${result['url']}');
        }
        print('===================');
        
        // Call callback if provided
        onResponse?.call(jsonResponse);
        
        return jsonResponse;
      } else {
        print('API Error: Status Code ${response.statusCode}');
        final errorBody = await response.stream.bytesToString();
        print('Error Body: $errorBody');
        print('Response Headers: ${response.headers}');
        return null;
      }
    } catch (e) {
      print('API Request Error: $e');
      return null;
    }
  }
} 