import '../config/config.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../constants/languages.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String VOICE_ID = 'necQJzI1X0vLpdnJteap';
const String _storageBucket = 'content'; // Main storage bucket
const String folderName = 'extra_vocabulary';

class AudioService {
final SupabaseClient _supabase;

  AudioService(this._supabase);

  Future<String?> generateAndUploadWordAudio({
    required String word,
    required String language,
    required String userId,
  }) async {
    if (word.trim().isEmpty || Config.elevenLabsApiKey.trim().isEmpty)
      return null;

    final client = HttpClient();
    try {
      final voiceId = 'pNInz6obpgDQGcFmaJgB';
      final uri =
          Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$VOICE_ID');
      final request = await client.postUrl(uri);
      request.headers.contentType =
          ContentType('application', 'json', charset: 'utf-8');
      request.headers.set('accept', 'audio/mpeg');
      request.headers.set('xi-api-key', Config.elevenLabsApiKey);
      final sanitizedWord =
          word.replaceAll(RegExp(r'[\u0000-\u001F\u007F]'), ' ').trim();
      final payload = jsonEncode({
        'text': sanitizedWord.isNotEmpty ? sanitizedWord : word.trim(),
        'model_id': 'eleven_multilingual_v2',
      });
      request.add(utf8.encode(payload));

      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final body = await response.transform(utf8.decoder).join();
        print('ElevenLabs error (${response.statusCode}): $body');
        return null;
      }

      final audioBytes = await response.fold<BytesBuilder>(
        BytesBuilder(),
        (builder, chunk) => builder..add(chunk),
      );
      final data = Uint8List.fromList(audioBytes.takeBytes());
      if (data.isEmpty) return null;

      final storagePath =
          '$folderName/$language/${userId}_${DateTime.now().millisecondsSinceEpoch}_${_sanitizeForStorage(word)}.mp3';
      final supabase = Supabase.instance.client;
      await supabase.storage.from(_storageBucket).uploadBinary(
            storagePath,
            data,
            fileOptions:
                const FileOptions(contentType: 'audio/mpeg', upsert: false),
          );
      return 'content/$storagePath';
    } catch (e) {
      print('ElevenLabs audio generation/upload failed: $e');
      return null;
    } finally {
      client.close(force: true);
    }
  }

  static String _sanitizeForStorage(String word) {
    return word
        .replaceAll(RegExp(r'[\u0000-\u001F\u007F\\/:*?"<>|]'), '_')
        .trim()
        .replaceAll(RegExp(r'_+'), '_');
  }
}