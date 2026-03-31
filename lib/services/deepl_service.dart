import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edge_function_auth_exception.dart';

class DeeplService {
  const DeeplService();

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

  Future<String?> translateWithDeepL({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    String? context,
  }) async {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) return null;
    if (sourceLanguage.isEmpty || targetLanguage.isEmpty) return null;

    try {
      final body = <String, dynamic>{
        'text': normalizedText,
        'source_lang': sourceLanguage,
        'target_lang': targetLanguage,
      };
      if (context != null && context.trim().isNotEmpty) {
        body['context'] = context;
      }
      final response = await _invoke(
        functionName: 'translate',
        body: body,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['translated_text']?.toString();
      }
      return null;
    } catch (e) {
      if (e is EdgeFunctionReauthRequiredException) rethrow;
      debugPrint('Translation request failed: $e');
      return null;
    }
  }
}
