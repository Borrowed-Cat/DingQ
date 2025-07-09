import '../../domain/entities/gcs_image.dart';
import '../../domain/repositories/gcs_image_repository.dart';

class FetchGcsImagesUseCase {
  final GcsImageRepository repository;
  FetchGcsImagesUseCase(this.repository);

  Future<List<GcsImage>> call({
    String prefix = 'generated/',
    int limit = 100,
    String sortBy = 'created',
    String order = 'desc',
  }) {
    return repository.fetchImages(
      prefix: prefix,
      limit: limit,
      sortBy: sortBy,
      order: order,
    );
  }
} 