# 🎯 **DingQ API - Flutter 개발자 가이드**

## 📋 **API 개요**

**서비스 이름:** DingQ Image Search API  
**기능:** CLIP 기반 이미지 유사도 검색  
**배포 위치:** Google Cloud Run (Seoul)  
**인증:** Public API (인증 불필요)

### **🌐 API Base URL**
```
https://[YOUR-SERVICE-URL].a.run.app
```
> ⚠️ **중요**: 백엔드 개발자에게 정확한 URL을 요청하세요

---

## 🔗 **API 엔드포인트**

### **1. 서버 상태 확인**
```http
GET /
```
**응답 예시:**
```json
{
  "message": "DingQ Image Search API",
  "status": "running",
  "model_status": "loaded",
  "features": ["CLIP search", "PostgreSQL integration", "Sketch storage"]
}
```

### **2. 헬스 체크**
```http
GET /health
```
**응답 예시:**
```json
{
  "status": "healthy",
  "model_loaded": true,
  "database": "disabled"
}
```

### **3. 이미지 검색 (메인 기능)**
```http
POST /search
Content-Type: multipart/form-data
```
**요청:**
- `image`: 이미지 파일 (PNG, JPG, JPEG 등)

**응답 예시:**
```json
{
  "top5": [
    {
      "label": "home",
      "score": 0.9234,
      "url": "https://storage.googleapis.com/dingq-svg-icons/home.svg"
    },
    {
      "label": "house",
      "score": 0.8765,
      "url": "https://storage.googleapis.com/dingq-svg-icons/house.svg"
    },
    {
      "label": "building",
      "score": 0.8123,
      "url": "https://storage.googleapis.com/dingq-svg-icons/building.svg"
    },
    {
      "label": "apartment",
      "score": 0.7890,
      "url": "https://storage.googleapis.com/dingq-svg-icons/apartment.svg"
    },
    {
      "label": "office",
      "score": 0.7456,
      "url": "https://storage.googleapis.com/dingq-svg-icons/office.svg"
    }
  ],
  "processing_time": 2.345,
  "total_results": 1000
}
```

---

## 📱 **Flutter 구현 코드**

### **1. 패키지 설치**
`pubspec.yaml`에 추가:
```yaml
dependencies:
  http: ^1.1.0
  image_picker: ^1.0.4
  dio: ^5.3.2  # 파일 업로드에 더 편리
```

### **2. API 서비스 클래스**
```dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class DingQApiService {
  static const String baseUrl = 'https://[YOUR-SERVICE-URL].a.run.app';
  final Dio _dio = Dio();
  
  DingQApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  /// 서버 상태 확인
  Future<Map<String, dynamic>> getServerStatus() async {
    try {
      final response = await _dio.get('/');
      return response.data;
    } catch (e) {
      throw Exception('서버 상태 확인 실패: $e');
    }
  }

  /// 헬스 체크
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.data;
    } catch (e) {
      throw Exception('헬스 체크 실패: $e');
    }
  }

  /// 이미지 검색 (메인 기능)
  Future<SearchResult> searchImage(File imageFile) async {
    try {
      // FormData 생성
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      // API 호출
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
```

### **3. 데이터 모델**
```dart
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
```

### **4. 사용 예시 위젯**
```dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DingQ 이미지 검색')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 이미지 선택 버튼
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('이미지 선택'),
            ),
            SizedBox(height: 20),
            
            // 선택된 이미지 표시
            if (_selectedImage != null)
              Container(
                height: 200,
                width: 200,
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
            
            SizedBox(height: 20),
            
            // 검색 버튼
            ElevatedButton(
              onPressed: _selectedImage != null && !_isLoading 
                  ? _searchImage 
                  : null,
              child: _isLoading 
                  ? CircularProgressIndicator() 
                  : Text('검색'),
            ),
            
            SizedBox(height: 20),
            
            // 에러 메시지
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Colors.red),
              ),
            
            // 검색 결과 표시
            if (_searchResult != null)
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResult!.top5.length,
                  itemBuilder: (context, index) {
                    final match = _searchResult!.top5[index];
                    return Card(
                      child: ListTile(
                        leading: Image.network(
                          match.url,
                          width: 50,
                          height: 50,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.error);
                          },
                        ),
                        title: Text(match.label),
                        subtitle: Text('유사도: ${(match.score * 100).toStringAsFixed(1)}%'),
                        trailing: Icon(Icons.open_in_new),
                        onTap: () {
                          // 이미지 URL 열기 또는 다른 동작
                          print('선택된 이미지: ${match.label}');
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
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
}
```

---

## 🔧 **개발 팁**

### **1. 에러 처리**
```dart
// 주요 에러 코드
switch (response.statusCode) {
  case 400:
    throw Exception('이미지 파일만 업로드 가능합니다');
  case 503:
    throw Exception('모델 로딩 중입니다. 잠시 후 다시 시도해주세요');
  case 500:
    throw Exception('서버 오류가 발생했습니다');
  default:
    throw Exception('알 수 없는 오류: ${response.statusCode}');
}
```

### **2. 이미지 최적화**
```dart
// 이미지 크기 최적화 (업로드 속도 향상)
Future<File> _optimizeImage(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  final image = img.decodeImage(bytes);
  
  // 최대 1024x1024로 리사이즈
  final resized = img.copyResize(image!, width: 1024, height: 1024);
  
  final compressedBytes = img.encodeJpg(resized, quality: 85);
  
  final tempDir = await getTemporaryDirectory();
  final compressedFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
  await compressedFile.writeAsBytes(compressedBytes);
  
  return compressedFile;
}
```

### **3. 캐싱 구현**
```dart
// 검색 결과 캐싱
class SearchCache {
  static final Map<String, SearchResult> _cache = {};
  static const int maxCacheSize = 100;
  
  static String _generateKey(File imageFile) {
    return imageFile.path.hashCode.toString();
  }
  
  static SearchResult? get(File imageFile) {
    return _cache[_generateKey(imageFile)];
  }
  
  static void set(File imageFile, SearchResult result) {
    if (_cache.length >= maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[_generateKey(imageFile)] = result;
  }
}
```

---

## 🚀 **배포 및 테스트**

### **1. API 연결 테스트**
```dart
// 앱 시작 시 서버 연결 확인
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
    // 사용자에게 오프라인 상태 알림
  }
}
```

### **2. 권한 설정 (Android)**
`android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />
```

### **3. 권한 설정 (iOS)**
`ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>이미지 검색을 위해 카메라 접근이 필요합니다</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>이미지 검색을 위해 사진 라이브러리 접근이 필요합니다</string>
```

---

## 📞 **지원 및 문의**

### **API 문제 해결**
1. **503 에러**: 모델 로딩 중 - 2-3분 후 재시도
2. **400 에러**: 이미지 파일 형식 확인 (PNG, JPG, JPEG만 가능)
3. **500 에러**: 서버 오류 - 백엔드 개발자 문의

### **성능 최적화**
- 이미지 크기: 1MB 이하 권장
- 네트워크 타임아웃: 30초 설정
- 결과 캐싱: 동일한 이미지 재검색 방지

---

## 🎯 **Quick Start 체크리스트**

- [ ] 백엔드 개발자에게 정확한 API URL 확인
- [ ] `pubspec.yaml`에 패키지 추가
- [ ] 권한 설정 (Android/iOS)
- [ ] API 서비스 클래스 구현
- [ ] 데이터 모델 클래스 구현
- [ ] UI 위젯 구현
- [ ] 에러 처리 및 로딩 상태 구현
- [ ] 실제 기기에서 테스트

**🎉 완성! 이제 DingQ 이미지 검색 기능을 Flutter 앱에 통합할 수 있습니다!** 