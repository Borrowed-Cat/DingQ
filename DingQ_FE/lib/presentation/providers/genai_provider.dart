import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/usecases/generate_ai_icon_usecase.dart';
import '../../data/datasources/genai_data_source.dart';
import '../../domain/entities/genai_icon_result.dart';
import 'dart:typed_data';

class GenAIState {
  final bool loading;
  final GenAIIconResult? result;
  final String? error;
  final String description;
  final double temperature;
  final bool showModal;
  GenAIState({
    this.loading = false,
    this.result,
    this.error,
    this.description = '',
    this.temperature = 0.5,
    this.showModal = false,
  });

  GenAIState copyWith({
    bool? loading,
    GenAIIconResult? result,
    String? error,
    String? description,
    double? temperature,
    bool? showModal,
  }) {
    return GenAIState(
      loading: loading ?? this.loading,
      result: result ?? this.result,
      error: error ?? this.error,
      description: description ?? this.description,
      temperature: temperature ?? this.temperature,
      showModal: showModal ?? this.showModal,
    );
  }
}

class GenAINotifier extends StateNotifier<GenAIState> {
  final GenerateAIIconUseCase useCase;
  GenAINotifier(this.useCase) : super(GenAIState());

  void setDescription(String desc) {
    state = state.copyWith(description: desc);
  }
  void setTemperature(double temp) {
    state = state.copyWith(temperature: temp);
  }

  Future<void> generate(Uint8List imageBytes) async {
    state = state.copyWith(loading: true, error: null, result: null);
    try {
      final result = await useCase(
        description: state.description,
        imageBytes: imageBytes,
        temperature: state.temperature,
      );
      state = state.copyWith(loading: false, result: result);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void clearResult() {
    state = state.copyWith(result: null, error: null);
  }

  void showModal() {
    state = state.copyWith(showModal: true);
  }

  void hideModal() {
    state = state.copyWith(showModal: false);
  }
}

final genAIProvider = StateNotifierProvider<GenAINotifier, GenAIState>((ref) {
  return GenAINotifier(GenerateAIIconUseCase(GenAIDataSource()));
}); 