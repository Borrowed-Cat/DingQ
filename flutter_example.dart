import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DingQ 이미지 검색',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ImageSearchScreen(),
    );
  }
}

class ImageSearchScreen extends StatefulWidget {
  @override
  _ImageSearchScreenState createState() => _ImageSearchScreenState();
}

class _ImageSearchScreenState extends State<ImageSearchScreen> {
  final DingQApiService _apiService = DingQApiService();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  SearchResult? _searchResult;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkServerConnection();
  }

  Future<void> _checkServerConnection() async {
    try {
      await _apiService.healthCheck();
      print('✅ 서버 연결 성공');
    } catch (e) {
      print('❌ 서버 연결 실패: $e');
      setState(() {
        _error = '서버 연결 실패: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DingQ 이미지 검색'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 서버 상태 표시
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('CLIP 기반 이미지 유사도 검색'),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            // 이미지 선택 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: Icon(Icons.photo_library),
                  label: Text('갤러리'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt),
                  label: Text('카메라'),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // 선택된 이미지 표시
            if (_selectedImage != null)
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            
            SizedBox(height: 20),
            
            // 검색 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedImage != null && !_isLoading 
                    ? _searchImage 
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        '유사한 이미지 검색',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // 에러 메시지
            if (_error != null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            
            // 검색 결과 표시
            if (_searchResult != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '검색 결과 (${_searchResult!.processingTime.toStringAsFixed(2)}초)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _searchResult!.top5.length,
                        itemBuilder: (context, index) {
                          final match = _searchResult!.top5[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            elevation: 3,
                            child: ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Image.network(
                                  match.url,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.image_not_supported);
                                  },
                                ),
                              ),
                              title: Text(
                                match.label,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('유사도: ${(match.score * 100).toStringAsFixed(1)}%'),
                                  SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: match.score,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      match.score > 0.8 ? Colors.green : 
                                      match.score > 0.6 ? Colors.orange : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.open_in_new),
                                onPressed: () {
                                  // 이미지 상세보기 또는 다른 동작
                                  _showImageDetail(match);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _searchResult = null;
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = '이미지 선택 실패: $e';
      });
    }
  }

  Future<void> _searchImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _apiService.searchImage(_selectedImage!);
      setState(() {
        _searchResult = result;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showImageDetail(ImageMatch match) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(match.label),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              match.url,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error, size: 150);
              },
            ),
            SizedBox(height: 16),
            Text('유사도: ${(match.score * 100).toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('닫기'),
          ),
        ],
      ),
    );
  }
}

// API 서비스 클래스
class DingQApiService {
  // ⚠️ 실제 서비스 URL로 변경해야 함
  static const String baseUrl = 'https://[YOUR-SERVICE-URL].a.run.app';
  final Dio _dio = Dio();
  
  DingQApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.data;
    } catch (e) {
      throw Exception('헬스 체크 실패: $e');
    }
  }

  Future<SearchResult> searchImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/search',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return SearchResult.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 503) {
          throw Exception('모델이 로딩 중입니다. 잠시 후 다시 시도해주세요.');
        } else if (e.response?.statusCode == 400) {
          throw Exception('이미지 파일만 업로드 가능합니다.');
        } else {
          throw Exception('검색 실패: ${e.response?.data['detail'] ?? e.message}');
        }
      }
      throw Exception('네트워크 오류: $e');
    }
  }
}

// 데이터 모델
class SearchResult {
  final List<ImageMatch> top5;
  final double processingTime;
  final int totalResults;

  SearchResult({
    required this.top5,
    required this.processingTime,
    required this.totalResults,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      top5: (json['top5'] as List)
          .map((item) => ImageMatch.fromJson(item))
          .toList(),
      processingTime: json['processing_time']?.toDouble() ?? 0.0,
      totalResults: json['total_results'] ?? 0,
    );
  }
}

class ImageMatch {
  final String label;
  final double score;
  final String url;

  ImageMatch({
    required this.label,
    required this.score,
    required this.url,
  });

  factory ImageMatch.fromJson(Map<String, dynamic> json) {
    return ImageMatch(
      label: json['label'] ?? '',
      score: json['score']?.toDouble() ?? 0.0,
      url: json['url'] ?? '',
    );
  }
} 