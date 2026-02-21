import '../models/audiobook.dart';


void printAudiobook(Audiobook book) {
    print('Audiobook:');
    print('audiobookID: ${book.id}');
    print('Title: ${book.title}');    
    print('Author: ${book.author}');
    print('Description: ${book.description}');
    print('Image URL: ${book.imageUrl}');
    print('Level: ${book.level}');
    print('Category1: ${book.category1}');
    print('Category2: ${book.category2}');
    print('Category3: ${book.category3}');
    print('Chapters: ${book.chapters}');
    print('Created At: ${book.createdAt}');
}
