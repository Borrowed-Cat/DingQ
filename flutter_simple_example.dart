import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class DingQApi {
  static const String baseUrl = 'https://example.com';
  final Dio _dio = Dio();

  Future<List<Map<String, dynamic>>> searchImage(File imageFile) async {
    try {
      // 이미지 파일을 FormData로 생성
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path),
      });

      // API 호출
      final response = await _dio.post(
        '$baseUrl/search',
        data: formData,
      );

      // 응답에서 top5 결과 반환
      return List<Map<String, dynamic>>.from(response.data['top5']);
    } catch (e) {
      throw Exception('검색 실패: $e');
    }
  }
}

// 사용 예시
class ImageSearchWidget extends StatefulWidget {
  @override
  _ImageSearchWidgetState createState() => _ImageSearchWidgetState();
}

class _ImageSearchWidgetState extends State<ImageSearchWidget> {
  final DingQApi _api = DingQApi();
  final ImagePicker _picker = ImagePicker();
  
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  Future<void> _searchImage() async {
    // 이미지 선택
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _loading = true);

    try {
      // API 호출
      final results = await _api.searchImage(File(image.path));
      setState(() => _results = results);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('검색 실패: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _loading ? null : _searchImage,
          child: _loading ? CircularProgressIndicator() : Text('이미지 검색'),
        ),
        
        // 결과 표시
        ..._results.map((result) => ListTile(
          leading: Image.network(result['url'], width: 50, height: 50),
          title: Text(result['label']),
          subtitle: Text('유사도: ${(result['score'] * 100).toInt()}%'),
        )).toList(),
      ],
    );
  }
}

// pubspec.yaml에 추가할 패키지
/*
dependencies:
  dio: ^5.3.2
  image_picker: ^1.0.4
*/ 