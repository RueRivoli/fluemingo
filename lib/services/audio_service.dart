import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edge_function_auth_exception.dart';
import 'rate_limit_exception.dart';

class AudioService {
  final SupabaseClient _supabase;

  AudioService(this._supabase);

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
    final session = _supabase.auth.currentSession;
    if (session == null || session.accessToken.trim().isEmpty) {
      throw EdgeFunctionReauthRequiredException(
        functionName: functionName,
        reason: 'missing_session',
      );
    }

    try {
      final response = await _supabase.functions
          .invoke(functionName, body: body, headers: _authHeaders(_supabase));
      if (response.status == 401) {
        throw EdgeFunctionReauthRequiredException(
          functionName: functionName,
          reason: 'unauthorized',
        );
      }
      if (response.status == 429) {
        throw RateLimitExceededException(functionName: functionName);
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

  /// Generate audio via Edge Function (proxies ElevenLabs) and upload to Supabase Storage.
  Future<String?> generateAndUploadWordAudio({
    required String word,
    required String language,
    required String userId,
    int? contentType,
    String? contentTitle,
    int? chapterOrder,
  }) async {
    if (word.trim().isEmpty) return null;

    try {
      final body = <String, dynamic>{
        'word': word,
        'language': language,
      };
      if (contentType != null) body['content_type'] = contentType;
      if (contentTitle != null) body['content_title'] = contentTitle;
      if (chapterOrder != null) body['chapter_order'] = chapterOrder;
      final response = await _invoke(
        functionName: 'text-to-speech',
        body: body,
      );

      if (response.status >= 400) {
        debugPrint(
            'text-to-speech edge function error (${response.status}): ${response.data}');
        return null;
      }

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['audio_url']?.toString();
      }
      return null;
    } catch (e) {
      if (e is EdgeFunctionReauthRequiredException) rethrow;
      if (e is RateLimitExceededException) rethrow;
      debugPrint('Audio generation request failed: $e');
      return null;
    }
  }
}
