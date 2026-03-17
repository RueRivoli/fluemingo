import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/config.dart';
import 'language_table_resolver.dart';

class DeeplService {
  final SupabaseClient _supabase;

  DeeplService(this._supabase);

  String _table(String name) => LanguageTableResolver.table(name);

  Uri _deepLTranslateUri() {
    final key = Config.deepLApiKey.trim();
    final isFreeKey = key.endsWith(':fx');
    final host = isFreeKey ? 'api-free.deepl.com' : 'api.deepl.com';
    return Uri.https(host, '/v2/translate');
  }

  Future<String?> translateWithDeepL({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    String? context,
  }) async {
    if (text.trim().isEmpty || Config.deepLApiKey.trim().isEmpty) return null;
    print('--------------------------------');
    print('text: $text');
    print('sourceLanguage: $sourceLanguage');
    print('targetLanguage: $targetLanguage');
    print('context: $context');
    final client = HttpClient();
    try {
      final uri = _deepLTranslateUri();
      final request = await client.postUrl(uri);
      request.headers.set(
          HttpHeaders.contentTypeHeader, 'application/x-www-form-urlencoded');
      request.headers.set(HttpHeaders.authorizationHeader,
          'DeepL-Auth-Key ${Config.deepLApiKey.trim()}');

      final bodyParts = <String>[
        'text=${Uri.encodeQueryComponent(text)}',
        'source_lang=${Uri.encodeQueryComponent(sourceLanguage)}',
        'target_lang=${Uri.encodeQueryComponent(targetLanguage)}',
      ];
      if (context != null && context.trim().isNotEmpty) {
        bodyParts.add('context=${Uri.encodeQueryComponent(context)}');
      }
      request.write(bodyParts.join('&'));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        print('DeepL error (${response.statusCode}): $responseBody');
        return null;
      }

      final decoded = jsonDecode(responseBody);
      if (decoded is! Map<String, dynamic>) return null;
      final translations = decoded['translations'];
      if (translations is! List || translations.isEmpty) return null;
      return (translations.first['text'] ?? '').toString();
    } catch (e) {
      print('DeepL request failed: $e');
      return null;
    } finally {
      client.close(force: true);
    }
  }
}
