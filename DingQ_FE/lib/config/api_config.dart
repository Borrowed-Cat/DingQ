class ApiConfig {
  // AI Generation API
  static const String genAIBaseUrl = 'https://dingq-api-n5rvmws25a-du.a.run.app';
  static const String genAIGenerateEndpoint = '/generate';
  
  // Timeout settings
  static const Duration requestTimeout = Duration(seconds: 120);
  
  // Get full URL for AI generation
  static String get genAIFullUrl => '$genAIBaseUrl$genAIGenerateEndpoint';
} 