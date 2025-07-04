import '../entities/stroke.dart';

/// Stroke 데이터를 관리하는 리포지토리 인터페이스
abstract class StrokeRepository {
  /// 현재 저장된 모든 Stroke 목록을 반환
  List<Stroke> get strokes;
  
  /// 새로운 Stroke를 추가
  void addStroke(Stroke stroke);
  
  /// 가장 최근에 추가된 Stroke를 제거 (Undo)
  void undo();
  
  /// 모든 Stroke를 제거 (Clear)
  void clear();
  
  /// Stroke가 비어있는지 확인
  bool get isEmpty;
  
  /// Stroke 개수 반환
  int get length;
} 