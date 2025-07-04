import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/dingbat.dart';
import '../../data/datasources/dingbat_data_source.dart';
import '../../data/repositories/dingbat_repository_impl.dart';
import '../../application/usecases/dingbat_usecases.dart';

/// 딩벳 데이터 소스 프로바이더
final dingbatDataSourceProvider = Provider<DingbatDataSource>((ref) {
  return DingbatDataSource();
});

/// 딩벳 리포지토리 프로바이더
final dingbatRepositoryProvider = Provider<DingbatRepositoryImpl>((ref) {
  final dataSource = ref.watch(dingbatDataSourceProvider);
  return DingbatRepositoryImpl(dataSource);
});

/// 딩벳 유스케이스 프로바이더들
final getAllDingbatsUseCaseProvider = Provider<GetAllDingbatsUseCase>((ref) {
  final repository = ref.watch(dingbatRepositoryProvider);
  return GetAllDingbatsUseCase(repository);
});

final getDingbatsByTagUseCaseProvider = Provider<GetDingbatsByTagUseCase>((ref) {
  final repository = ref.watch(dingbatRepositoryProvider);
  return GetDingbatsByTagUseCase(repository);
});

final getAllTagsUseCaseProvider = Provider<GetAllTagsUseCase>((ref) {
  final repository = ref.watch(dingbatRepositoryProvider);
  return GetAllTagsUseCase(repository);
});

/// 딩벳 상태 관리 Notifier
class DingbatNotifier extends StateNotifier<List<Dingbat>> {
  final GetAllDingbatsUseCase _getAllDingbatsUseCase;
  final GetDingbatsByTagUseCase _getDingbatsByTagUseCase;
  final GetAllTagsUseCase _getAllTagsUseCase;

  DingbatNotifier({
    required GetAllDingbatsUseCase getAllDingbatsUseCase,
    required GetDingbatsByTagUseCase getDingbatsByTagUseCase,
    required GetAllTagsUseCase getAllTagsUseCase,
  })  : _getAllDingbatsUseCase = getAllDingbatsUseCase,
        _getDingbatsByTagUseCase = getDingbatsByTagUseCase,
        _getAllTagsUseCase = getAllTagsUseCase,
        super([]) {
    loadAllDingbats();
  }

  /// 모든 딩벳 로드
  void loadAllDingbats() {
    state = _getAllDingbatsUseCase();
  }

  /// 특정 태그로 필터링
  void filterByTag(String tag) {
    if (tag.isEmpty) {
      loadAllDingbats();
    } else {
      state = _getDingbatsByTagUseCase(tag);
    }
  }

  /// 모든 태그 목록 반환
  List<String> getAllTags() {
    return _getAllTagsUseCase();
  }
}

/// 선택된 태그에 따른 딩벳 필터링 프로바이더
final filteredDingbatsProvider = Provider<List<Dingbat>>((ref) {
  final dingbats = ref.watch(dingbatsProvider);
  final selectedTag = ref.watch(selectedTagProvider);
  final notifier = ref.read(dingbatsProvider.notifier);
  
  if (selectedTag.isEmpty) {
    return dingbats;
  } else {
    return notifier._getDingbatsByTagUseCase(selectedTag);
  }
});

/// 딩벳 상태 관리 프로바이더
final dingbatsProvider = StateNotifierProvider<DingbatNotifier, List<Dingbat>>((ref) {
  return DingbatNotifier(
    getAllDingbatsUseCase: ref.watch(getAllDingbatsUseCaseProvider),
    getDingbatsByTagUseCase: ref.watch(getDingbatsByTagUseCaseProvider),
    getAllTagsUseCase: ref.watch(getAllTagsUseCaseProvider),
  );
});

/// 선택된 태그 상태 관리
final selectedTagProvider = StateProvider<String>((ref) => ''); 