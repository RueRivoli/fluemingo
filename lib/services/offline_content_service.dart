import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/article.dart';
import '../models/article_paragraph.dart';
import '../models/article_sentence.dart';
import '../models/grammar_point.dart';
import '../models/unit.dart';
import '../models/vocabulary_item.dart';

class OfflineContentService {
  static const String _offlineFolder = 'offline_content';
  static const String _manifestFileName = 'article.json';

  Future<bool> isArticleCached({
    required int contentType,
    required String contentId,
    String? chapterId,
  }) async {
    final dir = await _contentDirectory(
      contentType: contentType,
      contentId: contentId,
      chapterId: chapterId,
    );
    final manifest = File('${dir.path}/$_manifestFileName');
    return manifest.exists();
  }

  Future<Article?> getCachedArticle({
    required int contentType,
    required String contentId,
    String? chapterId,
  }) async {
    try {
      final dir = await _contentDirectory(
        contentType: contentType,
        contentId: contentId,
        chapterId: chapterId,
      );
      final manifest = File('${dir.path}/$_manifestFileName');
      if (!await manifest.exists()) return null;
      final jsonString = await manifest.readAsString();
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) return null;
      return _articleFromMap(decoded);
    } catch (e) {
      debugPrint('Error reading cached article: $e');
      return null;
    }
  }

  Future<Article> cacheArticle(Article article) async {
    final dir = await _contentDirectory(
      contentType: article.contentType,
      contentId: article.id,
      chapterId: article.chapterId,
      create: true,
    );

    final localImagePath = await _downloadToLocalFile(
      source: article.imageUrl,
      targetFilePath:
          '${dir.path}/cover${_extensionFromUrl(article.imageUrl, '.jpg')}',
    );
    final localAudioPath = await _downloadToLocalFile(
      source: article.audioUrl,
      targetFilePath:
          '${dir.path}/audio${_extensionFromUrl(article.audioUrl, '.mp3')}',
    );

    final map = _articleToMap(
      article,
      imageUrlOverride: localImagePath ?? article.imageUrl,
      audioUrlOverride: localAudioPath ?? article.audioUrl,
    );
    final manifest = File('${dir.path}/$_manifestFileName');
    await manifest.writeAsString(jsonEncode(map), flush: true);
    return _articleFromMap(map);
  }

  Future<Directory> _baseDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return Directory('${appDocDir.path}/$_offlineFolder');
  }

  Future<Directory> _contentDirectory({
    required int contentType,
    required String contentId,
    String? chapterId,
    bool create = false,
  }) async {
    final base = await _baseDirectory();
    final key = _cacheKey(
      contentType: contentType,
      contentId: contentId,
      chapterId: chapterId,
    );
    final dir = Directory('${base.path}/$key');
    if (create && !await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _cacheKey({
    required int contentType,
    required String contentId,
    String? chapterId,
  }) {
    final chapterPart =
        chapterId != null && chapterId.isNotEmpty ? '_ch$chapterId' : '';
    return 'ct${contentType}_c$contentId$chapterPart';
  }

  Future<String?> _downloadToLocalFile({
    required String? source,
    required String targetFilePath,
  }) async {
    if (source == null || source.isEmpty) return null;

    final normalized = source.startsWith('file://')
        ? source.replaceFirst('file://', '')
        : source;
    if (normalized.startsWith('/')) {
      final localFile = File(normalized);
      return await localFile.exists() ? localFile.path : null;
    }
    if (!normalized.startsWith('http://') &&
        !normalized.startsWith('https://')) {
      return null;
    }

    try {
      final uri = Uri.parse(normalized);
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(uri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        httpClient.close();
        return null;
      }
      final bytes = await consolidateHttpClientResponseBytes(response);
      httpClient.close();
      final file = File(targetFilePath);
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (e) {
      debugPrint('Error downloading offline file: $e');
      return null;
    }
  }

  String _extensionFromUrl(String? source, String fallback) {
    if (source == null || source.isEmpty) return fallback;
    final withoutQuery = source.split('?').first;
    final fileName = withoutQuery.split('/').last;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == fileName.length - 1) return fallback;
    final extension = fileName.substring(dotIndex);
    if (extension.length > 8) return fallback;
    return extension;
  }

  Map<String, dynamic> _articleToMap(
    Article article, {
    String? imageUrlOverride,
    String? audioUrlOverride,
  }) {
    return {
      'id': article.id,
      'chapterId': article.chapterId,
      'title': article.title,
      'description': article.description,
      'author': article.author,
      'imageUrl': imageUrlOverride ?? article.imageUrl,
      'readingStatus': article.readingStatus,
      'level': article.level,
      'category1': article.category1,
      'category2': article.category2,
      'category3': article.category3,
      'contentType': article.contentType,
      'audioUrl': audioUrlOverride ?? article.audioUrl,
      'orderId': article.orderId,
      'duration': article.duration,
      'isFavorite': article.isFavorite,
      'isFree': article.isFree,
      'vocabulary': article.vocabulary.map(_vocabularyToMap).toList(),
      'grammarPoints': article.grammarPoints.map(_grammarToMap).toList(),
      'paragraphs': article.paragraphs.map(_paragraphToMap).toList(),
    };
  }

  Article _articleFromMap(Map<String, dynamic> map) {
    final vocabularyRaw = map['vocabulary'];
    final grammarRaw = map['grammarPoints'];
    final paragraphsRaw = map['paragraphs'];

    return Article(
      id: map['id']?.toString() ?? '',
      chapterId: map['chapterId']?.toString(),
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      author: map['author']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      readingStatus: map['readingStatus']?.toString(),
      level: map['level']?.toString() ?? 'A1',
      category1: map['category1']?.toString() ?? '',
      category2: map['category2']?.toString(),
      category3: map['category3']?.toString(),
      contentType: (map['contentType'] as num?)?.toInt() ?? 1,
      audioUrl: map['audioUrl']?.toString(),
      orderId: (map['orderId'] as num?)?.toInt(),
      duration: (map['duration'] as num?)?.toInt(),
      isFavorite: map['isFavorite'] == true,
      isFree: map['isFree'] == true,
      vocabulary: vocabularyRaw is List
          ? vocabularyRaw
              .whereType<Map>()
              .map((e) => _vocabularyFromMap(e.cast<String, dynamic>()))
              .toList()
          : const [],
      grammarPoints: grammarRaw is List
          ? grammarRaw
              .whereType<Map>()
              .map((e) => _grammarFromMap(e.cast<String, dynamic>()))
              .toList()
          : const [],
      paragraphs: paragraphsRaw is List
          ? paragraphsRaw
              .whereType<Map>()
              .map((e) => _paragraphFromMap(e.cast<String, dynamic>()))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> _vocabularyToMap(VocabularyItem item) {
    return {
      'id': item.id,
      'word': item.word,
      'translation': item.translation,
      'type': item.type,
       'properName': item.properName,
      'exampleSentence': item.exampleSentence,
      'exampleTranslation': item.exampleTranslation,
      'audioUrl': item.audioUrl,
      'basis': item.basis,
      'flashcardId': item.flashcardId,
      'status': item.status,
      'isAddedByUser': item.isAddedByUser,
    };
  }

  VocabularyItem _vocabularyFromMap(Map<String, dynamic> map) {
    return VocabularyItem(
      id: (map['id'] as num?)?.toInt(),
      word: map['word']?.toString() ?? '',
      translation: map['translation']?.toString() ?? '',
      properName: map['properName'],
      type: map['type']?.toString() ?? 'expr',
      exampleSentence: map['exampleSentence']?.toString(),
      exampleTranslation: map['exampleTranslation']?.toString(),
      audioUrl: map['audioUrl']?.toString() ?? '',
      basis: map['basis']?.toString(),
      flashcardId: (map['flashcardId'] as num?)?.toInt(),
      status: map['status']?.toString(),
      isAddedByUser: map['isAddedByUser'] == true,
    );
  }

  Map<String, dynamic> _grammarToMap(GrammarPoint point) {
    return {
      'title': point.title,
      'description': point.description,
    };
  }

  GrammarPoint _grammarFromMap(Map<String, dynamic> map) {
    return GrammarPoint(
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> _paragraphToMap(ArticleParagraph paragraph) {
    return {
      'sentences': paragraph.sentences.map(_sentenceToMap).toList(),
    };
  }

  ArticleParagraph _paragraphFromMap(Map<String, dynamic> map) {
    final sentencesRaw = map['sentences'];
    return ArticleParagraph(
      sentences: sentencesRaw is List
          ? sentencesRaw
              .whereType<Map>()
              .map((e) => _sentenceFromMap(e.cast<String, dynamic>()))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> _sentenceToMap(ArticleSentence sentence) {
    return {
      'originalText': sentence.originalText,
      'translationText': sentence.translationText,
      'startTime': sentence.startTime,
      'endTime': sentence.endTime,
      'units': sentence.units.map(_unitToMap).toList(),
    };
  }

  ArticleSentence _sentenceFromMap(Map<String, dynamic> map) {
    final unitsRaw = map['units'];
    return ArticleSentence(
      originalText: map['originalText']?.toString() ?? '',
      translationText: map['translationText']?.toString() ?? '',
      startTime: (map['startTime'] as num?)?.toDouble(),
      endTime: (map['endTime'] as num?)?.toDouble(),
      units: unitsRaw is List
          ? unitsRaw
              .whereType<Map>()
              .map((e) => _unitFromMap(e.cast<String, dynamic>()))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> _unitToMap(Unit unit) {
    return {
      'text': unit.text,
      'translatedText': unit.translatedText,
      'type': unit.type,
      'punctuation': unit.punctuation,
      'properName': unit.properName,
      'originVerb': unit.originVerb,
      'basis': unit.basis,
    };
  }

  Unit _unitFromMap(Map<String, dynamic> map) {
    return Unit(
      text: map['text']?.toString() ?? '',
      translatedText: map['translatedText']?.toString() ?? '',
      type: map['type']?.toString() ?? 'other',
      punctuation: map['punctuation'] as bool?,
      properName: map['properName'] as bool?,
      originVerb: map['originVerb']?.toString(),
      basis: map['basis']?.toString(),
    );
  }
}
