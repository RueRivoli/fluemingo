import '../config/config.dart';
import 'dart:convert';
import 'dart:io';
import '../constants/languages.dart';

const String ANTHROPIC_URL = 'https://api.anthropic.com/v1/messages';

class AnthropicGenerationService {
  static String generatePrompt(
    String targetLanguageName,
    String word,
    String translatedWord,
  ) =>
      'Create exactly one short natural sentence in $targetLanguageName with less than 20 words using the word "$word" with the meaning "$translatedWord". Return only the sentence without quotes.';

  Future<String?> generateExampleSentenceWithAnthropic({
    required String word,
    required String translatedWord,
    required String targetLanguageCode,
  }) async {
    final apiKey = Config.anthropicApiKey.trim();
    if (word.trim().isEmpty || apiKey.isEmpty) return null;

    final targetLanguageName = languageNameFromCode(targetLanguageCode);
    final client = HttpClient();
    final prompt = generatePrompt(targetLanguageName, word, translatedWord);
    try {
      final uri = Uri.parse(ANTHROPIC_URL);
      final models = <String>[
        'claude-sonnet-4-20250514',
        'claude-3-5-sonnet-latest',
        'claude-3-5-haiku-latest',
      ];

      for (final model in models) {
        final request = await client.postUrl(uri);
        request.headers.contentType =
            ContentType('application', 'json', charset: 'utf-8');
        request.headers.set('x-api-key', apiKey);
        request.headers.set('anthropic-version', '2023-06-01');

        final payload = jsonEncode({
          'model': model,
          'max_tokens': 120,
          'temperature': 0.3,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        });

        request.add(utf8.encode(payload));
        final response = await request.close();
        final body = await response.transform(utf8.decoder).join();
        if (response.statusCode < 200 || response.statusCode >= 300) {
          final isModelIssue =
              (response.statusCode == 400 || response.statusCode == 404) &&
                  (body.toLowerCase().contains('model') ||
                      body.toLowerCase().contains('not_found_error'));
          if (isModelIssue && model != models.last) {
            print('Anthropic model unavailable ($model), trying next model...');
            continue;
          }
          print('Anthropic error (${response.statusCode}): $body');
          return null;
        }

        final decoded = jsonDecode(body);
        if (decoded is! Map<String, dynamic>) return null;
        final content = decoded['content'];
        if (content is! List || content.isEmpty) return null;
        final first = content.first;
        if (first is! Map<String, dynamic>) return null;
        final text = (first['text'] ?? '').toString().trim();
        if (text.isNotEmpty) return text;
      }

      return null;
    } catch (e) {
      print('Anthropic request failed: $e');
      return null;
    } finally {
      client.close(force: true);
    }
  }
}
