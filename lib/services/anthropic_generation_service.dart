import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/languages.dart';
import 'edge_function_auth_exception.dart';

class AnthropicGenerationService {
  Map<String, String> _authHeaders(SupabaseClient client) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${client.auth.currentSession!.accessToken}',
    };
  }

  Future<FunctionResponse> _invoke({
    required String functionName,
    required Map<String, dynamic> body,
  }) async {
    final client = Supabase.instance.client;
    final session = client.auth.currentSession;
    if (session == null || session.accessToken.trim().isEmpty) {
      throw EdgeFunctionReauthRequiredException(
        functionName: functionName,
        reason: 'missing_session',
      );
    }

    try {
      final response = await client.functions
          .invoke(functionName, body: body, headers: _authHeaders(client));
      if (response.status == 401) {
        throw EdgeFunctionReauthRequiredException(
          functionName: functionName,
          reason: 'unauthorized',
        );
      }
      return response;
    } on FunctionException catch (e) {
      if (e.status == 401) {
        throw EdgeFunctionReauthRequiredException(
          functionName: functionName,
          reason: 'unauthorized',
        );
      }
      rethrow;
    }
  }

  Future<String?> generateExampleSentenceWithAnthropic({
    required String word,
    required String translatedWord,
    required String targetLanguageCode,
  }) async {
    if (word.trim().isEmpty) return null;

    final targetLanguageName = languageNameFromCode(targetLanguageCode);
    try {
      final response = await _invoke(
        functionName: 'generate-sentence',
        body: {
          'word': word,
          'translated_word': translatedWord,
          'target_language_name': targetLanguageName,
        },
      );

      if (response.status >= 400) {
        debugPrint(
            'generate-sentence edge function error (${response.status}): ${response.data}');
        return null;
      }

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final sentence = data['sentence']?.toString().trim();
        return (sentence != null && sentence.isNotEmpty) ? sentence : null;
      }
      return null;
    } catch (e) {
      if (e is EdgeFunctionReauthRequiredException) rethrow;
      debugPrint('Sentence generation request failed: $e');
      return null;
    }
  }
}
