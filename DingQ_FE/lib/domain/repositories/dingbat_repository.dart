import '../entities/dingbat.dart';

/// 딩벳 데이터를 관리하는 리포지토리 인터페이스
abstract class DingbatRepository {
  /// 모든 딩벳 목록을 반환
  List<Dingbat> getAllDingbats();
  
  /// 특정 태그로 필터링된 딩벳 목록을 반환
  List<Dingbat> getDingbatsByTag(String tag);
  
  /// 여러 태그로 필터링된 딩벳 목록을 반환
  List<Dingbat> getDingbatsByTags(List<String> tags);
  
  /// 사용 가능한 모든 태그 목록을 반환
  List<String> getAllTags();
} 