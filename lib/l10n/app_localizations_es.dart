// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get fiveMinutesADay => '\'5 min/día\'';

  @override
  String get fifteenMinutesADay => '\'15 min/día\'';

  @override
  String get thirtyMinutesADay => '\'30 min/día\'';

  @override
  String get oneHourADay => '\'1 h/día\'';

  @override
  String get activeFilters => 'Filtros activos';

  @override
  String get addedByUser => 'Añadido por ti';

  @override
  String get all => 'Todos';

  @override
  String get allLevels => 'Todos';

  @override
  String get answers => 'respuestas';

  @override
  String get appTitle => 'Fluemingo';

  @override
  String get apply => 'Aplicar';

  @override
  String areYouSureYouWantToDeleteWord(Object word) {
    return '¿Estás seguro de que quieres eliminar $word de la lista de vocabulario?';
  }

  @override
  String areYouSureYouWantToDeleteReferenceLanguage(Object languageName) {
    return '¿Estás seguro de que quieres cambiar tu idioma de referencia a $languageName?\n\nEste cambio afectará a las palabras ya traducidas.';
  }

  @override
  String areYouSureYouWantToDeleteTargetLanguage(Object languageName) {
    return '¿Estás seguro de que quieres cambiar tu idioma de aprendizaje a $languageName?\n\nEste cambio afectará a las palabras ya traducidas.';
  }

  @override
  String get art => 'Arte';

  @override
  String get article => 'Artículo';

  @override
  String get audiobooks => 'Audiolibros';

  @override
  String get back => 'Atrás';

  @override
  String get biography => 'Biografía';

  @override
  String get buildA => 'construir un';

  @override
  String get cancel => 'Cancelar';

  @override
  String get changeStatus => 'Cambiar estado';

  @override
  String get changeLanguage => 'Cambiar idioma';

  @override
  String get chapters => 'Capítulos';

  @override
  String get cinema => 'Cine';

  @override
  String get chooseYourAnswer => 'Elige una respuesta';

  @override
  String get clickOnPlusToAddThisExpressionToYourVocabularyList =>
      'Pulsa + para añadir esta expresión a tu vocabulario';

  @override
  String get clickOnXToRemoveThisExpressionFromYourVocabularyList =>
      'Toca el icono de papelera para eliminar esta expresión de tu vocabulario';

  @override
  String get completedQuizzes => 'Cuestionarios completados';

  @override
  String get confirm => 'Confirmar';

  @override
  String get contentInProgress => 'Contenido en curso';

  @override
  String get continueReadingToEarnXP => 'Sigue leyendo para ganar XP';

  @override
  String get continueButton => 'Continuar';

  @override
  String get contentFittingYou => 'Contenido que se adapta perfectamente a ti:';

  @override
  String get connexion => 'Conexión';

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String get continueWithFacebook => 'Continuar con Facebook';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get culture => 'Cultura';

  @override
  String get dailyGoal => 'Objetivo diario';

  @override
  String get definition => 'Definición';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteVocabularyItem => 'Eliminar este elemento del vocabulario';

  @override
  String get difficult => 'Difícil';

  @override
  String get difficultVocabulary => 'Vocabulario difícil';

  @override
  String get downloadForOfflineAccess => 'Descargar para acceso sin conexión';

  @override
  String get edit => 'Editar';

  @override
  String get education => 'Educación';

  @override
  String get extreme => 'Extremo';

  @override
  String get fashion => 'Moda';

  @override
  String get expressionAddedToFlashcards =>
      'Expresión añadida a las tarjetas de memoria';

  @override
  String get favoritesArticlesOnly => 'Solo artículos favoritos';

  @override
  String get favoritesAudiobooksOnly => 'Solo audiolibros favoritos';

  @override
  String get favoriteContent => 'Contenido favorito';

  @override
  String get favoriteThemes => 'Temas favoritos';

  @override
  String get fiction => 'Ficción';

  @override
  String get filters => 'Filtros';

  @override
  String get finished => 'Terminado';

  @override
  String get finishedArticles => 'Artículos terminados';

  @override
  String get finishedAudiobooks => 'Audiolibros terminados';

  @override
  String get finishedChaptersAudiobooks => 'Capítulos de audio';

  @override
  String get flashcardsVocabulary => 'Tarjetas de vocabulario';

  @override
  String get fontSize => 'Tamaño de fuente';

  @override
  String goalIntensity(String intensity) {
    String _temp0 = intl.Intl.selectLogic(
      intensity,
      {
        'light': 'ligero',
        'regular': 'regular',
        'high': 'alto',
        'extreme': 'extremo',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String goalDuration(String duration) {
    String _temp0 = intl.Intl.selectLogic(
      duration,
      {
        'fiveMinutesADay': '5 min/día',
        'fifteenMinutesADay': '15 min/día',
        'thirtyMinutesADay': '30 min/día',
        'oneHourADay': '1 h/día',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get gastronomy => 'Gastronomía';

  @override
  String get grammarPoints => 'Reglas de gramática';

  @override
  String get greetings => 'Hola';

  @override
  String get health => 'Salud';

  @override
  String get high => 'alto';

  @override
  String get history => 'Historia';

  @override
  String get inProgress => 'En curso';

  @override
  String get includeFinishedArticles => 'Incluir artículos terminados';

  @override
  String get includeFinishedAudiobooks => 'Incluir audiolibros terminados';

  @override
  String get interestingContent => 'Contenido adaptado a tus temas favoritos';

  @override
  String get forYou => 'Para ti';

  @override
  String get items => 'Expresiones';

  @override
  String get languages => 'Idiomas extranjeros';

  @override
  String get languageEn => 'Inglés';

  @override
  String get languageFr => 'Francés';

  @override
  String get languageEs => 'Español';

  @override
  String get languageDe => 'Alemán';

  @override
  String get languageNl => 'Neerlandés';

  @override
  String get languageIt => 'Italiano';

  @override
  String get languagePt => 'Portugués';

  @override
  String get languageJa => 'Japonés';

  @override
  String get learn => 'Aprende';

  @override
  String get literature => 'Literatura';

  @override
  String get level => 'Nivel';

  @override
  String get light => 'Ligero';

  @override
  String get mainVocabulary => 'Vocabulario principal';

  @override
  String get mastered => 'Dominado';

  @override
  String get masteredFlashcards => 'Tarjetas aprendidas';

  @override
  String get masteredVocabulary => 'Vocabulario dominado';

  @override
  String get music => 'Música';

  @override
  String get navAudiobooks => 'Audiolibros';

  @override
  String get navFlashcards => 'Vocabulario';

  @override
  String get navLibrary => 'Artículos';

  @override
  String get navProfile => 'Perfil';

  @override
  String get noAudiobooksFound => 'No se encontraron audiolibros';

  @override
  String get noArticlesFound => 'No se encontraron artículos';

  @override
  String get noAudioAvailableForThisArticle =>
      'No hay audio disponible para este artículo';

  @override
  String get noQuizAvailableForThisArticle =>
      'No hay cuestionario disponible para este artículo';

  @override
  String get noVocabularyItemsFound => 'No se encontró vocabulario';

  @override
  String get news => 'Actualidad';

  @override
  String get next => 'Siguiente';

  @override
  String get notStarted => 'No empezado';

  @override
  String get people => 'Gente';

  @override
  String get philosophy => 'Filosofía';

  @override
  String get psychology => 'Psicología';

  @override
  String get poetry => 'Poesía';

  @override
  String get previous => 'Anterior';

  @override
  String get quiz => 'Cuestionario';

  @override
  String get quizCompleted => '¡Cuestionario completado!';

  @override
  String get readFlashcards => 'Leer tarjetas';

  @override
  String get regular => 'Regular';

  @override
  String get repeat => 'Practicar';

  @override
  String get retry => 'Reintentar';

  @override
  String get dailyLimitReached =>
      'Límite diario alcanzado. Inténtalo de nuevo mañana.';

  @override
  String get saved => 'Guardado';

  @override
  String get savedVocabulary => 'Vocabulario guardado';

  @override
  String get science => 'Ciencia';

  @override
  String get selectGoal => 'Selecciona un objetivo para mantenerte motivado';

  @override
  String selectUpToThemes(Object maxSelection) {
    return 'Selecciona hasta $maxSelection temas.';
  }

  @override
  String get setHowManyXpYouWant =>
      'Establece cuántos XP quieres ganar por semana.';

  @override
  String get signInWithApple => 'Iniciar sesión con Apple';

  @override
  String get signInWithFacebook => 'Continuar con Facebook';

  @override
  String get signInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get showOnlyFavoriteArticles => 'Mostrar solo artículos favoritos';

  @override
  String get showOnlyFavoriteAudiobooks => 'Mostrar solo audiolibros favoritos';

  @override
  String get society => 'Sociedad';

  @override
  String get space => 'Espacio';

  @override
  String get sport => 'Deporte';

  @override
  String get startToRead => 'Empezar a Leer';

  @override
  String get strongLastingVocabulary => 'Vocabulario sólido y duradero';

  @override
  String get tale => 'Cuento';

  @override
  String get targetLanguage => 'Idioma que quiero aprender';

  @override
  String get technology => 'Tecnología';

  @override
  String get testYourKnowledge => 'Pon a prueba tus conocimientos';

  @override
  String get training => 'Entrenamiento';

  @override
  String get trainingVocabulary => 'Vocabulario de entrenamiento';

  @override
  String get travel => 'Viajes';

  @override
  String get themes => 'Temas';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get sourceLanguage => 'Idioma de referencia';

  @override
  String get subscription => 'Suscripción';

  @override
  String get upgradeToPremium => 'Pasar a Premium';

  @override
  String get manageSubscription => 'Gestionar suscripción';

  @override
  String get unlockWithPremium => 'Desbloquear con Premium';

  @override
  String get vocabulary => 'Vocabulario';

  @override
  String get vocabularyAcquired => 'Vocabulario adquirido';

  @override
  String get vocabularyForTraining => 'Vocabulario de entrenamiento';

  @override
  String get watersports => 'Deportes acuáticos';

  @override
  String get week => 'semana';

  @override
  String get weekProgress => 'Esta semana';

  @override
  String weeklyGoal(Object goal) {
    return 'Objetivo semanal: $goal XP';
  }

  @override
  String daysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'días restantes',
      one: 'día restante',
    );
    return '$days $_temp0';
  }

  @override
  String get weekGoal => 'Objetivo semanal';

  @override
  String get whichLanguageDoYouWantToLearn => '¿Qué idioma quieres aprender?';

  @override
  String get selectOne => 'Selecciona uno';

  @override
  String get whichLanguageDoYouSpeakTheBest =>
      '¿Qué idioma deseas usar como referencia?';

  @override
  String get withWord => 'Con';

  @override
  String get withYour => 'con tu';

  @override
  String get unknown => 'Desconocido';

  @override
  String get xpPerWeek => 'XP por semana';

  @override
  String get yoga => 'Yoga';

  @override
  String get yourSavedVocabulary => 'Vocabulario guardado';

  @override
  String get yourPersonalVocabulary => 'Vocabulario personal';

  @override
  String get yourProgress => 'Progreso general';

  @override
  String get yourWeekProgress => 'Progreso semanal';

  @override
  String get yourWeeklyGoal => 'Tu objetivo semanal';

  @override
  String get rateTheApp => 'Valorar la app';

  @override
  String get rateTheAppStoreUnavailable =>
      'Store no disponible (prueba en un dispositivo real o configura el ID de App Store).';

  @override
  String get flashcardCategoryUpdated => 'Categoría de flashcard actualizada';

  @override
  String get flashcardMastered =>
      '¡Felicidades, has dominado una nueva expresión! +1 XP';

  @override
  String get noFlashcardsAvailable => 'No hay flashcards disponibles';

  @override
  String get noFlashcardsFound => 'No se encontraron flashcards';

  @override
  String get deleteFlashcard => 'Eliminar flashcard';

  @override
  String get noContentInProgress => 'No hay contenido en progreso';

  @override
  String get noLikedContentYet => 'Aún no hay contenido favorito';

  @override
  String get noSuggestionsYet => 'Aún no hay sugerencias';

  @override
  String get yourContentInProgress => 'Tu contenido en progreso';

  @override
  String get yourFavoriteContent => 'Tu contenido favorito';

  @override
  String get yourContent => 'Tu contenido';

  @override
  String get finishContentToEarnXP => 'Termina este contenido para ganar XP';

  @override
  String get basedOnYourLikes => 'Basado en tus gustos';

  @override
  String get basedOnYourFavoriteThemes => 'Basado en tus temas favoritos';

  @override
  String get save => 'Guardar';

  @override
  String get pleaseSelectAtLeastOneTheme =>
      'Por favor, selecciona al menos un tema';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get downloading => 'Descargando...';

  @override
  String get availableOffline => 'Disponible sin conexión';

  @override
  String get downloadedForOfflineAccess =>
      'Descargado para acceso sin conexión';

  @override
  String get goBack => 'Volver';

  @override
  String get noAudioAvailable => 'Audio no disponible';

  @override
  String get pleaseEnterValidNumber =>
      'Por favor, introduce un número positivo válido';

  @override
  String get yourTargetLanguage => 'Tu idioma objetivo';

  @override
  String get yourReferenceLanguage => 'Tu idioma de referencia';

  @override
  String get oops => 'Vaya';

  @override
  String get weeklyGoalReached => 'Objetivo semanal alcanzado!';

  @override
  String get wellDone => '¡Muy bien!';

  @override
  String youEarnedXp(Object xp) {
    return '¡Ganaste $xp XP!';
  }

  @override
  String get quizFinishedMarkArticleAsFinished =>
      '¡Terminaste el quiz! ¿Quieres marcar el artículo como terminado también?';

  @override
  String get quizFinishedMarkChapterAsFinished =>
      '¡Terminaste el quiz! ¿Quieres marcar el capítulo como terminado también?';

  @override
  String get congratsQuizAndArticle => '¡Terminaste el quiz y el artículo!';

  @override
  String get congratsQuizAndChapter => '¡Terminaste el quiz y el capítulo!';

  @override
  String get congratsQuiz => '¡Terminaste el quiz!';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get vocabularyAddedToList => 'Vocabulario añadido a la lista';

  @override
  String get retranslate => 'Retraducir';

  @override
  String get withContent => 'con contenido';

  @override
  String get yourTaste => 'tu gusto, tu nivel, tu ritmo';

  @override
  String get fitTasteLevel => 'que se adapta a tus gustos y nivel';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountConfirmation =>
      '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción es irreversible y todos tus datos se eliminarán permanentemente.';

  @override
  String get accountDeleted => 'Tu cuenta ha sido eliminada.';

  @override
  String get deleteAccountError =>
      'No se pudo eliminar la cuenta. Inténtalo de nuevo.';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get termsOfService => 'Términos de servicio';

  @override
  String get termsAndPrivacyNotice =>
      'Al iniciar sesión, aceptas nuestros Términos de servicio y nuestra Política de privacidad.';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get purchasesRestored => 'Compras restauradas con éxito.';

  @override
  String get restorePurchasesFailed => 'No se pudieron restaurar las compras.';

  @override
  String get orContinueWith => 'o continuar con';

  @override
  String get signInWithEmail => 'Iniciar sesión con email';

  @override
  String get email => 'Email';

  @override
  String get password => 'Contraseña';

  @override
  String get enterEmailAndPassword =>
      'Introduce tu email y contraseña para iniciar sesión.';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get start => 'Empezar';

  @override
  String get downloadFailed => 'Error en la descarga';

  @override
  String get errorPlayingAudio => 'Error al reproducir el audio';

  @override
  String get errorSeekingAudio => 'Error al posicionar el audio';

  @override
  String get errorSavingThemes => 'Error al guardar los temas';

  @override
  String get errorUpdatingStatus => 'No se pudo actualizar el estado';

  @override
  String get errorUpdatingGoal => 'No se pudo actualizar el objetivo';

  @override
  String get errorUpdatingTargetLanguage =>
      'No se pudo actualizar el idioma objetivo';

  @override
  String get errorUpdatingReferenceLanguage =>
      'No se pudo actualizar el idioma de referencia';

  @override
  String get errorLoggingOut => 'Error al cerrar sesión';

  @override
  String get authenticationError => 'Error de autenticación';

  @override
  String get incompleteAccountSetup =>
      'La configuración de tu cuenta está incompleta. Por favor, termina el proceso de bienvenida.';

  @override
  String get signInFailed => 'Error al iniciar sesión';

  @override
  String get noParagraphsAvailable => 'No hay párrafos disponibles';

  @override
  String get supabaseConfigMissing =>
      'Configuración de Supabase faltante. Ejecute la app con --dart-define-from-file=.env';

  @override
  String flashcardsDeckTitle(Object category) {
    return 'Flashcards $category';
  }

  @override
  String get allDone => '¡Listo!';

  @override
  String flashcardsReviewedCount(Object count) {
    return 'Has revisado las $count flashcards';
  }

  @override
  String get reveal => 'Revelar';

  @override
  String get example => 'EJEMPLO';

  @override
  String get translation => 'TRADUCCIÓN';

  @override
  String get errorDeletingFlashcard => 'Error al eliminar la flashcard';
}
