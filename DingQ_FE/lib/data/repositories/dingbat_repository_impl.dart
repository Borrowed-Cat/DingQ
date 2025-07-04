import '../../domain/entities/dingbat.dart';
import '../../domain/repositories/dingbat_repository.dart';
import '../datasources/dingbat_data_source.dart';

/// 딩벳 리포지토리의 구현체
class DingbatRepositoryImpl implements DingbatRepository {
  final DingbatDataSource _dataSource;

  const DingbatRepositoryImpl(this._dataSource);

  @override
  List<Dingbat> getAllDingbats() {
    return _dataSource.getAllDingbats();
  }

  @override
  List<Dingbat> getDingbatsByTag(String tag) {
    return _dataSource.getDingbatsByTag(tag);
  }

  @override
  List<Dingbat> getDingbatsByTags(List<String> tags) {
    return _dataSource.getDingbatsByTags(tags);
  }

  @override
  List<String> getAllTags() {
    return _dataSource.getAllTags();
  }
} 