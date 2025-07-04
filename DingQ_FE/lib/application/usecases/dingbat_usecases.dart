import '../../domain/entities/dingbat.dart';
import '../../domain/repositories/dingbat_repository.dart';

/// 모든 딩벳 조회 유스케이스
class GetAllDingbatsUseCase {
  final DingbatRepository _repository;

  const GetAllDingbatsUseCase(this._repository);

  List<Dingbat> call() {
    return _repository.getAllDingbats();
  }
}

/// 태그별 딩벳 조회 유스케이스
class GetDingbatsByTagUseCase {
  final DingbatRepository _repository;

  const GetDingbatsByTagUseCase(this._repository);

  List<Dingbat> call(String tag) {
    return _repository.getDingbatsByTag(tag);
  }
}

/// 여러 태그로 딩벳 조회 유스케이스
class GetDingbatsByTagsUseCase {
  final DingbatRepository _repository;

  const GetDingbatsByTagsUseCase(this._repository);

  List<Dingbat> call(List<String> tags) {
    return _repository.getDingbatsByTags(tags);
  }
}

/// 모든 태그 조회 유스케이스
class GetAllTagsUseCase {
  final DingbatRepository _repository;

  const GetAllTagsUseCase(this._repository);

  List<String> call() {
    return _repository.getAllTags();
  }
} 