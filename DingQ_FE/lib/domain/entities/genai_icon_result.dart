import 'generated_icon.dart';

class GenAIIconResult {
  final List<GeneratedIcon> icons;
  
  GenAIIconResult({required this.icons});
  
  // Convenience getter for backward compatibility
  List<String> get base64Images => icons.map((icon) => icon.base64).toList();
} 