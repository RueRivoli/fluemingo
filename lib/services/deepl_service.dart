import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edge_function_auth_exception.dart';
import 'rate_limit_exception.dart';

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
    var session = client.auth.currentSession;
    debugPrint('[_invoke:$functionName] session exists=${session != null}, '
        'tokenLength=${session?.accessToken.length ?? 0}');
    // print('token ==> ${session?.accessToken}');

      final token = session?.accessToken ?? '';                                                                                                   
  const chunkSize = 800;                                    
  for (var i = 0; i < token.length; i += chunkSize) {                                                                                         
    final end = (i + chunkSize < token.length) ? i + chunkSize : token.length;
    print('token[$i..$end] ==> ${token.substring(i, end)}');                                                                                  
  }                                                         
    

    if (session == null || session.accessToken.trim().isEmpty) {
      try {
        final refreshed = await client.auth.refreshSession();
        session = refreshed.session;
      } catch (e) {
        debugPrint('[_invoke:$functionName] refresh FAILED: $e');
      }
      if (session == null || session.accessToken.trim().isEmpty) {
        throw EdgeFunctionReauthRequiredException(
          functionName: functionName,
          reason: 'missing_session',
        );
      }
    }

    try {
      final response = await client.functions
          .invoke(functionName, body: body, headers: _authHeaders(client));
      debugPrint('[_invoke:$functionName] SUCCESS status=${response.status}');
      return response;
    } on FunctionException catch (e) {
      debugPrint('[_invoke:$functionName] FunctionException '
          'status=${e.status} reason=${e.reasonPhrase} details=${e.details}');
      if (e.status == 401) {
        try {
          await client.auth.refreshSession();
          final retryResponse = await client.functions
              .invoke(functionName, body: body, headers: _authHeaders(client));
          return retryResponse;
        } on FunctionException catch (retryError) {
          if (retryError.status == 401) {
            throw EdgeFunctionReauthRequiredException(
              functionName: functionName,
              reason: 'unauthorized',
            );
          }
          rethrow;
        } catch (retryErr) {
          debugPrint('[_invoke:$functionName] RETRY error: $retryErr');
          throw EdgeFunctionReauthRequiredException(
            functionName: functionName,
            reason: 'unauthorized',
          );
        }
      }
      if (e.status == 429) {
        throw RateLimitExceededException(functionName: functionName);
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
      if (e is RateLimitExceededException) rethrow;
      debugPrint('Translation request failed: $e');
      return null;
    }
  }
}
