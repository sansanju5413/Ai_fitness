import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Base AI service using OpenRouter API
/// 
/// Features:
/// - Secure API key loading from environment variables
/// - Retry logic for failed requests
/// - JSON validation and cleanup
/// - Compatible with OpenAI API format
class BaseAiService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String _defaultModel = 'openai/gpt-4o-mini-2024-07-18';
  
  /// Get API key from environment variables (checks multiple key names)
  static String get _apiKey {
    // Debug: print all available env keys
    print('[AI] 🔍 Available env keys: ${dotenv.env.keys.toList()}');
    
    // Try multiple possible key names
    String? apiKey = dotenv.env['OPENROUTER_API_KEY'];
    apiKey ??= dotenv.env['API_KEY'];
    apiKey ??= dotenv.env['OPENROUTER_KEY'];
    
    if (apiKey == null || apiKey.isEmpty) {
      print('[AI] ❌ No API key found in .env');
      print('[AI] 📋 Expected: OPENROUTER_API_KEY=sk-or-v1-...');
      throw Exception('❌ OPENROUTER_API_KEY not found in .env file. '
          'Please add: OPENROUTER_API_KEY=your_key_here');
    }
    
    print('[AI] ✅ API key found (${apiKey.substring(0, 10)}...)');
    return apiKey;
  }
  
  final String model;
  final http.Client _client;

  BaseAiService({String? model}) 
      : model = model ?? _defaultModel,
        _client = http.Client() {
    print('[AI] ✅ OpenRouter initialized with model: ${this.model}');
  }

  /// Generate JSON content using OpenRouter API
  Future<String?> generateJsonContent(
    String prompt, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
    int maxTokens = 4096, // Default, can be reduced for simple queries
  }) async {
    return _generateContent(
      prompt,
      jsonMode: true,
      maxRetries: maxRetries,
      retryDelay: retryDelay,
      maxTokens: maxTokens,
    );
  }

  /// Generate plain text content using OpenRouter API
  Future<String?> generatePlainContent(
    String prompt, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
    int maxTokens = 2048,
  }) async {
    return _generateContent(
      prompt,
      jsonMode: false,
      maxRetries: maxRetries,
      retryDelay: retryDelay,
      maxTokens: maxTokens,
    );
  }

  /// Core method to call OpenRouter API
  Future<String?> _generateContent(
    String prompt, {
    required bool jsonMode,
    required int maxRetries,
    required Duration retryDelay,
    required int maxTokens,
  }) async {
    print('[AI] 📤 Sending ${jsonMode ? "JSON" : "text"} request to OpenRouter...');
    print('[AI] Prompt preview: ${prompt.substring(0, prompt.length > 100 ? 100 : prompt.length)}...');
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final requestBody = {
          'model': model,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': jsonMode ? 0.7 : 0.8,
          'max_tokens': maxTokens,
          if (jsonMode) 'response_format': {'type': 'json_object'},
        };

        final response = await _client.post(
          Uri.parse(_baseUrl),
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://ai-fitness-app.com',
            'X-Title': 'AI Fitness App',
          },
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final content = responseData['choices']?[0]?['message']?['content'];
          
          if (content == null || content.isEmpty) {
            print('[AI] ⚠️ Attempt ${attempt + 1}: Response content is null or empty');
            if (attempt < maxRetries - 1) {
              await Future.delayed(retryDelay);
              continue;
            }
            return null;
          }
          
          print('[AI] 📥 Response received (${content.length} chars)');
          
          // For JSON mode, validate and clean the response
          if (jsonMode) {
            try {
              jsonDecode(content);
              print('[AI] ✅ Valid JSON response');
              return content;
            } catch (e) {
              print('[AI] ⚠️ Invalid JSON format, attempting cleanup...');
              final cleaned = _cleanJsonResponse(content);
              try {
                jsonDecode(cleaned);
                print('[AI] ✅ JSON cleaned and validated');
                return cleaned;
              } catch (e) {
                print('[AI] ❌ JSON still invalid after cleanup: $e');
                if (attempt < maxRetries - 1) {
                  await Future.delayed(retryDelay);
                  continue;
                }
                throw Exception('Failed to parse JSON response after cleanup');
              }
            }
          }
          
          return content;
          
        } else if (response.statusCode == 429) {
          // Rate limited
          print('[AI] ⚠️ Rate limited. Waiting before retry...');
          await Future.delayed(const Duration(seconds: 5));
          continue;
          
        } else {
          final errorBody = jsonDecode(response.body);
          final errorMessage = errorBody['error']?['message'] ?? 'Unknown error';
          print('[AI] ❌ Attempt ${attempt + 1} ERROR (${response.statusCode}): $errorMessage');
          
          if (attempt < maxRetries - 1) {
            print('[AI] 🔄 Retrying in ${retryDelay.inSeconds} seconds...');
            await Future.delayed(retryDelay);
          } else {
            throw Exception('API Error: $errorMessage');
          }
        }
        
      } catch (e) {
        print('[AI] ❌ Attempt ${attempt + 1} ERROR: $e');
        if (attempt < maxRetries - 1) {
          print('[AI] 🔄 Retrying in ${retryDelay.inSeconds} seconds...');
          await Future.delayed(retryDelay);
        } else {
          rethrow;
        }
      }
    }
    
    return null;
  }

  /// Clean and validate JSON responses from AI
  String _cleanJsonResponse(String text) {
    String cleaned = text.trim();
    
    // Remove markdown code blocks
    if (cleaned.startsWith('```')) {
      cleaned = cleaned
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
    }
    
    // Remove any text before the first { or [
    final jsonStart = cleaned.indexOf(RegExp(r'[\{\[]'));
    if (jsonStart > 0) {
      cleaned = cleaned.substring(jsonStart);
    }
    
    // Remove any text after the last } or ]
    final jsonEnd = cleaned.lastIndexOf(RegExp(r'[\}\]]'));
    if (jsonEnd < cleaned.length - 1 && jsonEnd > 0) {
      cleaned = cleaned.substring(0, jsonEnd + 1);
    }
    
    return cleaned;
  }

  /// Test connection to OpenRouter API
  Future<bool> testConnection() async {
    try {
      print('[AI] 🧪 Testing OpenRouter API connection...');
      final response = await generatePlainContent(
        'Say "OK" if you can hear me.',
        maxRetries: 1,
      );
      if (response != null && response.isNotEmpty) {
        print('[AI] ✅ Connection test successful');
        return true;
      }
      print('[AI] ❌ Connection test failed: Empty response');
      return false;
    } catch (e) {
      print('[AI] ❌ Connection test failed: $e');
      return false;
    }
  }

  /// Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}
