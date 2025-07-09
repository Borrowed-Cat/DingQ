import '../../data/datasources/genai_data_source.dart';
import '../../domain/entities/genai_icon_result.dart';
import '../../domain/entities/generated_icon.dart';
import 'dart:typed_data';

class GenerateAIIconUseCase {
  final GenAIDataSource dataSource;
  GenerateAIIconUseCase(this.dataSource);

  Future<GenAIIconResult> call({
    required String description,
    required Uint8List imageBytes,
    required double temperature,
    int targetCount = 3,
  }) async {
    final icons = await dataSource.generateAIIcon(
      description: description,
      imageBytes: imageBytes,
      temperature: temperature,
      targetCount: targetCount,
    );
    return GenAIIconResult(icons: icons);
  }
} 