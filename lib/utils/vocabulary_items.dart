import '../models/vocabulary_item.dart';

void printVocabularyItem(VocabularyItem item) {
    print('Vocabulary Item:');
    print('vocabularyID: ${item.id}');
    print('Word: ${item.word}');    
    print('Translation: ${item.translation}');
    print('Type: ${item.type}');
    print('Example Sentence: ${item.exampleSentence}');
    print('Example Translation: ${item.exampleTranslation}');
    print('Audio URL: ${item.audioUrl}');
    print('Flashcard ID: ${item.flashcardId}');
    print('Status: ${item.status}');
    print('Is Added By User: ${item.isAddedByUser}'); 
}
