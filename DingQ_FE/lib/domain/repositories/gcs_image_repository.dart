import '../entities/gcs_image.dart';

abstract class GcsImageRepository {
  Future<List<GcsImage>> fetchImages({
    String prefix,
    int limit,
    String sortBy,
    String order,
  });
} 