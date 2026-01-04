import '../models/article.dart';
import '../models/vocabulary_item.dart';
import '../models/grammar_point.dart';
import '../models/article_paragraph.dart';

List<Article> getSampleArticles() {
  return [
    Article(
      id: '1',
      title: 'La constellation Galileo a été lancée avec succès',
      description: 'An article about last launched satellites from the EU',
      imageUrl: 'https://images.unsplash.com/photo-1516849841032-87cbac4d88f7?w=800',
      level: 'B1',
      category: 'Science',
      isFavorite: false,
      vocabulary: [
        VocabularyItem(word: 'une fusée', translation: 'launcher', type: 'n'),
        VocabularyItem(word: "l'espace", translation: 'the space', type: 'n', isSaved: true),
        VocabularyItem(word: 'un satellite', translation: 'a satellite', type: 'n'),
        VocabularyItem(word: 'lancer', translation: 'to launch', type: 'v'),
      ],
      grammarPoints: [
        GrammarPoint(
          title: 'Present simple',
          description: 'Present simple is made by adding ...',
        ),
        GrammarPoint(
          title: 'Passive voice',
          description: 'The passive voice is formed with être + past participle...',
        ),
      ],
      paragraphs: [
        ArticleParagraph(
          originalText: "Le 17 décembre 2025, Arianespace a mis en orbite deux satellites Galileo avec Ariane 6 pour l'Agence spatiale européenne (ESA), au nom de la Commission européenne et de l'Agence de l'Union européenne pour le programme spatial (EUSPA).",
          translationText: "On December 17, 2025, Arianespace launched two Galileo satellites with Ariane 6 for the European Space Agency (ESA), on behalf of the European Commission and the European Union Space Programme Agency (EUSPA).",
        ),
      ],
      audioUrl: null,
    ),
    Article(
      id: '2',
      title: 'Un incendie en Suisse fait 10 morts pendant le réveillon du 31',
      description: 'During the New Year\'s Eve, a fire broke out in a building in Switzerland, killing 10 people....',
      imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
      level: 'A2',
      category: 'Politics',
      isFavorite: true,
      vocabulary: [
        VocabularyItem(word: 'le climat', translation: 'the climate', type: 'n'),
        VocabularyItem(word: 'un sommet', translation: 'a summit', type: 'n'),
        VocabularyItem(word: 'discuter', translation: 'to discuss', type: 'v'),
      ],
      grammarPoints: [
        GrammarPoint(
          title: 'Past tense',
          description: 'The passé composé is formed with avoir/être + past participle...',
        ),
      ],
      paragraphs: [
        ArticleParagraph(
          originalText: "Le 31 décembre 2024, un incendie s'est déclaré dans un immeuble résidentiel à Genève, en Suisse. Les pompiers sont arrivés rapidement sur les lieux, mais malheureusement, dix personnes ont perdu la vie dans cette tragédie.",
          translationText: "On December 31, 2024, a fire broke out in a residential building in Geneva, Switzerland. Firefighters arrived quickly at the scene, but unfortunately, ten people lost their lives in this tragedy.",
        ),
      ],
      audioUrl: null,
    ),
    Article(
      id: '3',
      title: 'The Art of Coffee',
      description: 'Discover the secrets behind the perfect espresso and latte art....',
      imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
      level: 'A1',
      category: 'Culture',
      isFavorite: false,
      vocabulary: [
        VocabularyItem(word: 'le café', translation: 'the coffee', type: 'n'),
        VocabularyItem(word: 'une tasse', translation: 'a cup', type: 'n'),
        VocabularyItem(word: 'boire', translation: 'to drink', type: 'v'),
      ],
      grammarPoints: [
        GrammarPoint(
          title: 'Articles',
          description: 'Definite articles: le, la, les. Indefinite: un, une, des...',
        ),
      ],
      paragraphs: [
        ArticleParagraph(
          originalText: "Le café est l'une des boissons les plus populaires au monde. Pour préparer un bon espresso, il faut utiliser des grains de café frais et de l'eau chaude.",
          translationText: "Coffee is one of the most popular drinks in the world. To make a good espresso, you need to use fresh coffee beans and hot water.",
        ),
      ],
      audioUrl: null,
    ),
  ];
}

