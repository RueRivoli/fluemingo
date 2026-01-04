import '../models/audiobook.dart';

List<Audiobook> getSampleAudiobooks() {
  return [
    // Fiction
    Audiobook(
      title: 'Gatsby',
      author: 'F. Scott Fitzgerald',
      imageUrl: 'assets/gatsby.jpg',
      level: 'B2',
      category: 'Fiction',
      description: 'A classic American novel about the Jazz Age.',
      audioUrl: 'https://example.com/gatsby.mp3',
    ),
    Audiobook(
      title: 'Space 2078',
      author: 'John Sci-Fi',
      imageUrl: 'assets/space2078.jpg',
      level: 'C1',
      category: 'Fiction',
      description: 'A futuristic tale set in the year 2078.',
      audioUrl: 'https://example.com/space2078.mp3',
    ),
    // History
    Audiobook(
      title: 'Henricks',
      author: 'Historical Author',
      imageUrl: 'assets/henricks.jpg',
      level: 'B1',
      category: 'History',
      description: 'An exploration of historical events.',
      audioUrl: 'https://example.com/henricks.mp3',
    ),
    // More Fiction
    Audiobook(
      title: 'The Great Journey',
      author: 'Adventure Writer',
      imageUrl: 'assets/journey.jpg',
      level: 'A2',
      category: 'Fiction',
      description: 'An epic adventure story.',
      audioUrl: 'https://example.com/journey.mp3',
    ),
    // More History
    Audiobook(
      title: 'Ancient Civilizations',
      author: 'History Expert',
      imageUrl: 'assets/ancient.jpg',
      level: 'B2',
      category: 'History',
      description: 'Discover the secrets of ancient worlds.',
      audioUrl: 'https://example.com/ancient.mp3',
    ),
  ];
}


