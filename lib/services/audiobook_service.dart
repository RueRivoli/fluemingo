import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/audiobook.dart';
import '../models/vocabulary_item.dart';

class AudiobookService {
  final SupabaseClient _supabase;
  static const String _storageBucket = 'content'; // Main storage bucket

  AudiobookService(this._supabase);

  /// Get full public URL for a file stored in Supabase Storage
  String _getStorageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }
    
    // If the path already contains the full URL, return it as is
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    
    // Remove leading slash if present
    String cleanPath = path.startsWith('/') ? path.substring(1) : path;
    
    // If path starts with "content/", remove it since bucket is already "content"
    if (cleanPath.startsWith('content/')) {
      cleanPath = cleanPath.substring('content/'.length);
    }
    
    try {
      final url = _supabase.storage.from(_storageBucket).getPublicUrl(cleanPath);
      return url;
    } catch (e) {
      print('Error constructing storage URL: $e');
      return '';
    }
  }

  /// Get full public URL for an image stored in Supabase Storage
  String _getImageUrl(String? imgPath) {
    return _getStorageUrl(imgPath);
  }

  /// Get full public URL for an audio file stored in Supabase Storage
  String? _getAudioUrl(String? audioPath) {
    if (audioPath == null || audioPath.isEmpty) {
      return null;
    }
    return _getStorageUrl(audioPath);
  }

  /// Fetch all audiobooks from Supabase (content_fr table with content_type = 2)
  Future<List<Audiobook>> getAudiobooks({String? level}) async {
    try {
      var query = _supabase.from('content_fr').select().eq('content_type', 2);

      // Filter by level if provided
      if (level != null && level != 'All') {
        query = query.eq('level', level);
      }

      final response = await query;

      return (response as List).map((json) => _audiobookFromJson(json)).toList();
    } catch (e) {
      print('Error fetching audiobooks: $e');
      rethrow;
    }
  }

  /// Fetch a single audiobook by ID with all related data (chapters, vocabulary)
  Future<Audiobook?> getAudiobookById(int id) async {
    try {
      // Fetch audiobook from content_fr table
      final audiobookResponse = await _supabase
          .from('content_fr')
          .select()
          .eq('id', id)
          .eq('content_type', 2)
          .single();

      if (audiobookResponse == null) return null;

      // Fetch related chapters
      // Note: chapters_fr table might reference content_fr.id instead of long_format_id
      // Adjust the column name if needed
      final chaptersResponse = await _supabase
          .from('chapters_fr')
          .select()
          .eq('long_format_id', id)
          .order('order_id');

      final chapters = (chaptersResponse as List).map((json) => Chapter(
            id: json['id'] as int,
            longFormatId: json['long_format_id'] as int? ?? id,
            title: json['title'] ?? '',
            description: json['description'],
            content: json['content'],
            contentEn: json['content_en'],
            audioUrl: _getAudioUrl(json['audio_url']),
            orderIndex: json['order_id'] as int? ?? 0,
          )).toList();

      // Fetch related vocabulary from vocabulary_fr table
      final vocabularyResponse = await _supabase
          .from('vocabulary_fr')
          .select()
          .eq('reference_id', id)
          .eq('content_type', 2);

      final vocabulary = (vocabularyResponse as List).map((json) => VocabularyItem(
            word: json['text'] ?? '',
            translation: json['text_en'] ?? '',
            type: json['function'] ?? 'n',
            audioUrl: _getAudioUrl(json['audio_url']) ?? '',
            isSaved: false,
          )).toList();

      // Create audiobook with all related data
      return Audiobook(
        id: audiobookResponse['id'] as int,
        title: audiobookResponse['title'] ?? '',
        author: audiobookResponse['author'] ?? '',
        description: audiobookResponse['description'] ?? '',
        imageUrl: _getImageUrl(audiobookResponse['img_url']),
        level: audiobookResponse['level'] ?? 'A1',
        category: audiobookResponse['category'] ?? '',
        vocabulary: vocabulary,
        chapters: chapters,
        createdAt: DateTime.parse(audiobookResponse['created_at']),
      );
    } catch (e) {
      print('Error fetching audiobook: $e');
      return null;
    }
  }

  /// Convert JSON to Audiobook model (basic info only)
  Audiobook _audiobookFromJson(Map<String, dynamic> json) {
    return Audiobook(
      id: json['id'] as int,
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      description: json['description'] ?? '',
      imageUrl: _getImageUrl(json['img_url']),
      level: json['level'] ?? 'A1',
      category: json['category'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

