import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../config/api_config.dart';
import '../../domain/entities/generated_icon.dart';

class GenAIDataSource {
  Future<List<GeneratedIcon>> generateAIIcon({
    required String description,
    required Uint8List imageBytes,
    required double temperature,
    int targetCount = 3,
  }) async {
    try {
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.genAIFullUrl),
      );

      // Add text fields
      request.fields['description'] = description;
      request.fields['temperature'] = temperature.toString();
      request.fields['target_count'] = targetCount.toString();

      // Add image file
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'drawing_${DateTime.now().millisecondsSinceEpoch}.png',
          contentType: MediaType('image', 'png'),
        ),
      );

      // Send request with timeout
      final response = await request.send().timeout(ApiConfig.requestTimeout);
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        
        List<dynamic> results = [];
        
        // 다양한 응답 구조 처리
        if (data['success'] == true && data['data'] != null) {
          results = data['data'];
        } else if (data['data'] != null) {
          results = data['data'];
        } else if (data['results'] != null) {
          results = data['results'];
        } else if (data['icons'] != null) {
          results = data['icons'];
        } else if (data is List) {
          results = data;
        } else {
          throw Exception('API 응답 형식 오류: 예상치 못한 응답 구조');
        }
        
        if (results.isEmpty) {
          throw Exception('API 응답 형식 오류: 빈 결과');
        }
        
        final parsedIcons = <GeneratedIcon>[];
        
        for (int i = 0; i < results.length; i++) {
          try {
            final icon = GeneratedIcon.fromJson(results[i]);
            parsedIcons.add(icon);
          } catch (e) {
            // 개별 아이콘 파싱 실패 시 로그만 출력하고 계속 진행
          }
        }
        
        if (parsedIcons.isEmpty) {
          throw Exception('API 응답 형식 오류: 파싱 가능한 아이콘이 없음');
        }
        
        return parsedIcons;
      } else {
        throw Exception('API 호출 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }
} 