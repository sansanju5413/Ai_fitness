import 'package:google_generative_ai/google_generative_ai.dart';

abstract class BaseAiService {
  static const String _kGeminiApiKey = 'AIzaSyBVWSJXVBqPGpMnXXiZt4BQ4VhaHs8IHOY';
  
  final GenerativeModel _jsonModel;
  final GenerativeModel _plainModel;

  BaseAiService({String model = 'gemini-1.5-flash'})
      : _jsonModel = GenerativeModel(
          model: model,
          apiKey: _kGeminiApiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
          ),
        ),
        _plainModel = GenerativeModel(
          model: model,
          apiKey: _kGeminiApiKey,
        );

  GenerativeModel get jsonModel => _jsonModel;
  GenerativeModel get plainModel => _plainModel;

  /// Helper for JSON generation
  Future<String?> generateJsonContent(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _jsonModel.generateContent(content);
      return response.text;
    } catch (e) {
      return null;
    }
  }

  /// Helper for plain text generation
  Future<String?> generatePlainContent(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _plainModel.generateContent(content);
      return response.text;
    } catch (e) {
      return null;
    }
  }
}
