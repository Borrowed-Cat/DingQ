import '../../domain/entities/gcs_image.dart';
import '../../domain/repositories/gcs_image_repository.dart';
import '../datasources/gcs_image_data_source.dart';

class GcsImageRepositoryImpl implements GcsImageRepository {
  final GcsImageDataSource dataSource;
  GcsImageRepositoryImpl(this.dataSource);

  @override
  Future<List<GcsImage>> fetchImages({
    String prefix = 'generated/',
    int limit = 100,
    String sortBy = 'created',
    String order = 'desc',
  }) {
    return dataSource.fetchImages(
      prefix: prefix,
      limit: limit,
      sortBy: sortBy,
      order: order,
    );
  }
} 