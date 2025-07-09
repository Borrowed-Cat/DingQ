import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/gcs_image.dart';
import '../../application/usecases/fetch_gcs_images_usecase.dart';
import '../../data/datasources/gcs_image_data_source.dart';
import '../../data/repositories/gcs_image_repository_impl.dart';

final gcsImageListProvider = FutureProvider.autoDispose.family<List<GcsImage>, GcsImageQueryParams>((ref, params) async {
  final useCase = ref.watch(fetchGcsImagesUseCaseProvider);
  return useCase(
    prefix: params.prefix,
    limit: params.limit,
    sortBy: params.sortBy,
    order: params.order,
  );
});

class GcsImageQueryParams {
  final String prefix;
  final int limit;
  final String sortBy;
  final String order;
  const GcsImageQueryParams({
    this.prefix = 'generated/',
    this.limit = 100,
    this.sortBy = 'created',
    this.order = 'desc',
  });
}

final fetchGcsImagesUseCaseProvider = Provider<FetchGcsImagesUseCase>((ref) {
  final dataSource = GcsImageDataSource(baseUrl: 'https://dingq-api-n5rvmws25a-du.a.run.app');
  final repository = GcsImageRepositoryImpl(dataSource);
  return FetchGcsImagesUseCase(repository);
}); 