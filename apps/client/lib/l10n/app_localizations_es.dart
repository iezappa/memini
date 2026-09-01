// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Memini';

  @override
  String get navStats => 'Estadísticas';

  @override
  String get navSettings => 'Ajustes';

  @override
  String greeting(String name) {
    return 'Hola, $name';
  }

  @override
  String get greetingAnonymous => 'Tu colección';

  @override
  String get searchHint => 'Buscar salas, notas, reseñas';

  @override
  String roomCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count salas',
      one: '1 sala',
      zero: 'Sin salas',
    );
    return '$_temp0';
  }

  @override
  String get filterEscaped => 'Escapaste';

  @override
  String get filterFailed => 'No escapaste';

  @override
  String get filterFranchise => 'Franquicia';

  @override
  String get filterAllFranchises => 'Todas las franquicias';

  @override
  String get sortRatingHigh => 'Mejor puntaje';

  @override
  String get sortRatingLow => 'Peor puntaje';

  @override
  String get clearFilters => 'Limpiar filtros';

  @override
  String get emptyTitle => 'Todavía no registraste nada';

  @override
  String get emptyBody =>
      'Agregá la primera sala que jugaste y empezá a armar tu historial.';

  @override
  String get emptyFiltered => 'Ninguna sala coincide con estos filtros.';

  @override
  String get addRoom => 'Agregar sala';

  @override
  String get editRoom => 'Editar sala';

  @override
  String get newRoom => 'Nueva sala';

  @override
  String get deleteRoom => 'Eliminar sala';

  @override
  String deleteConfirm(String name) {
    return '¿Eliminar «$name»? No se puede deshacer.';
  }

  @override
  String get fieldName => 'Nombre';

  @override
  String get fieldNameRequired => 'La sala necesita un nombre.';

  @override
  String get fieldDescription => 'Descripción';

  @override
  String get fieldFranchise => 'Franquicia';

  @override
  String get fieldRating => 'Puntaje';

  @override
  String get fieldReview => 'Reseña';

  @override
  String get fieldPlayedOn => 'Fecha jugada';

  @override
  String get fieldOutcome => '¿Escapaste?';

  @override
  String get fieldTimeLeft => 'Tiempo restante (minutos)';

  @override
  String get fieldTimeLeftHint => 'Solo si escapaste';

  @override
  String get photoAdd => 'Agregar foto';

  @override
  String get photoReplace => 'Cambiar foto';

  @override
  String get photoRemove => 'Quitar foto';

  @override
  String get photoFailed => 'No se pudo cargar esa imagen.';

  @override
  String get franchiseHint => 'Escribí un nombre; se crea si es nueva';

  @override
  String get franchises => 'Franquicias';

  @override
  String get notRated => 'Sin puntuar';

  @override
  String get escapedYes => 'Escapaste';

  @override
  String get escapedNo => 'No escapaste';

  @override
  String timeLeftValue(int minutes) {
    return '$minutes min restantes';
  }

  @override
  String get statsEmpty =>
      'Registrá una sala y acá van a aparecer tus estadísticas.';

  @override
  String get statsEscapeRate => 'Tasa de escape';

  @override
  String get statsAverage => 'Puntaje promedio';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsAccent => 'Color de acento';

  @override
  String get settingsProfile => 'Perfil';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get settingsDisplayName => 'Tu nombre';

  @override
  String get settingsDisplayNameHint => 'Se usa en el saludo';

  @override
  String get settingsSecurity => 'Seguridad';

  @override
  String get settingsPinLock => 'Bloqueo por PIN';

  @override
  String get settingsPinLockOff => 'Desactivado';

  @override
  String get settingsPinLockOn => 'Activado';

  @override
  String get pinSet => 'Definir un PIN';

  @override
  String get pinChange => 'Cambiar el PIN';

  @override
  String get pinDisable => 'Desactivar el PIN';

  @override
  String get pinEnter => 'Ingresá tu PIN';

  @override
  String get pinCurrent => 'PIN actual';

  @override
  String get pinNew => 'PIN nuevo';

  @override
  String get pinConfirm => 'Repetí el PIN';

  @override
  String get pinTooShort => 'Usá al menos 4 dígitos.';

  @override
  String get pinMismatch => 'Los dos PIN no coinciden.';

  @override
  String get pinWrong => 'PIN incorrecto.';

  @override
  String get pinUnlock => 'Desbloquear';

  @override
  String get settingsData => 'Tus datos';

  @override
  String get settingsSupport => 'Apoyo';

  @override
  String get exportJson => 'Exportar backup (JSON)';

  @override
  String get exportCsv => 'Exportar como planilla (CSV)';

  @override
  String get importJson => 'Importar backup';

  @override
  String get importWarningTitle => '¿Reemplazar todo?';

  @override
  String get importWarningBody =>
      'Importar reemplaza todas las salas y franquicias guardadas. Exportá un backup primero si querés conservarlas.';

  @override
  String get importConfirm => 'Reemplazar';

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count salas restauradas',
      one: '1 sala restaurada',
    );
    return '$_temp0';
  }

  @override
  String get importFailed => 'Ese archivo no es un backup válido de Memini.';

  @override
  String get exportDone => 'Backup guardado.';

  @override
  String get exportFailed => 'No se pudo guardar el archivo.';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get disclaimerTitle => 'Qué es Memini';

  @override
  String get disclaimerBody =>
      'Memini es un registro personal de las cosas que hiciste: salas de escape, comidas afuera, recitales, cine y series, y juegos. Guarda todo únicamente en este dispositivo: sin cuenta, sin servidor, sin sincronización. Si desinstalás la app o perdés el dispositivo, los datos se van con él, así que exportá un backup con regularidad. Los puntajes y las reseñas son tu opinión personal y no se comparten con nadie.';

  @override
  String get disclaimerAccept => 'Entendido';

  @override
  String get supportTitle => 'Apoyá mis proyectos';

  @override
  String get supportBody =>
      'Memini es gratis y va a seguir siéndolo. Si te sirve, podés invitarme un café.';

  @override
  String get supportCafecito => 'Cafecito (Argentina)';

  @override
  String get supportPatreon => 'Patreon (resto del mundo)';

  @override
  String get linkFailed => 'No se pudo abrir el enlace.';

  @override
  String get tutorialSkip => 'Saltar';

  @override
  String get tutorialNext => 'Siguiente';

  @override
  String get tutorialAgain => 'Ver el tutorial de nuevo';

  @override
  String get tutorial1Title => 'Todo lo que hiciste, en un solo lugar';

  @override
  String get tutorial1Body =>
      'Registrá salas de escape, comidas, recitales, películas, series y juegos: una foto, la fecha y los datos que importan en cada caso.';

  @override
  String get tutorial2Title => 'Puntuálas como un crítico';

  @override
  String get tutorial2Body =>
      'Ponéle a cada entrada un puntaje sobre 10 y escribí la reseña que te habría gustado leer antes.';

  @override
  String get tutorial3Title => 'Solo tuyo';

  @override
  String get tutorial3Body =>
      'Todo vive en este dispositivo. Exportá un backup cuando quieras tenerlo a salvo.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get close => 'Cerrar';

  @override
  String get retry => 'Reintentar';

  @override
  String get navHome => 'Inicio';

  @override
  String get homeTagline => 'Todo lo que vale la pena recordar';

  @override
  String get homeRecent => 'Registrado hace poco';

  @override
  String get homeRecentEmpty =>
      'Todavía no registraste nada. Elegí una sección de arriba y sumá la primera.';

  @override
  String get domainRooms => 'Salas de escape';

  @override
  String get domainDining => 'Lugares donde comí';

  @override
  String get domainConcerts => 'Bandas que vi';

  @override
  String get domainScreen => 'Películas y series';

  @override
  String get domainGames => 'Videojuegos';

  @override
  String get sortTitle => 'Título A–Z';

  @override
  String get sortDateNewest => 'Más reciente';

  @override
  String get sortDateOldest => 'Más antiguo';

  @override
  String mealCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comidas',
      one: '1 comida',
      zero: 'Sin comidas',
    );
    return '$_temp0';
  }

  @override
  String get mealSearchHint => 'Buscar lugares, platos, notas';

  @override
  String get mealEmptyTitle => 'No hay comidas registradas';

  @override
  String get mealEmptyBody =>
      'Registrá el lugar apenas salís, mientras el plato sigue fresco.';

  @override
  String get mealEmptyFiltered => 'Ninguna comida coincide con estos filtros';

  @override
  String get addMeal => 'Agregar comida';

  @override
  String get newMeal => 'Nueva comida';

  @override
  String get editMeal => 'Editar comida';

  @override
  String get deleteMeal => 'Eliminar comida';

  @override
  String get fieldPlace => 'Lugar';

  @override
  String get fieldPlaceRequired => 'El lugar necesita un nombre';

  @override
  String get fieldDish => 'Plato';

  @override
  String get fieldPrice => 'Precio';

  @override
  String get fieldCompany => 'Con';

  @override
  String get fieldLocation => 'Barrio o ciudad';

  @override
  String get filterLocation => 'Ubicación';

  @override
  String get filterAllLocations => 'En cualquier lado';

  @override
  String gigCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recitales',
      one: '1 recital',
      zero: 'Sin recitales',
    );
    return '$_temp0';
  }

  @override
  String get gigSearchHint => 'Buscar bandas, venues, notas';

  @override
  String get gigEmptyTitle => 'No hay recitales registrados';

  @override
  String get gigEmptyBody => 'Anotá la noche mientras todavía la escuchás.';

  @override
  String get gigEmptyFiltered => 'Ningún recital coincide con estos filtros';

  @override
  String get addGig => 'Agregar recital';

  @override
  String get newGig => 'Nuevo recital';

  @override
  String get editGig => 'Editar recital';

  @override
  String get deleteGig => 'Eliminar recital';

  @override
  String get fieldBand => 'Banda';

  @override
  String get fieldBandRequired => 'La banda necesita un nombre';

  @override
  String get fieldVenue => 'Venue';

  @override
  String get fieldCity => 'Ciudad';

  @override
  String get fieldSupportActs => 'Teloneros';

  @override
  String get fieldSupportActsHint => 'Separalos con comas';

  @override
  String get fieldSetlist => 'Setlist';

  @override
  String get fieldSetlistHint => 'Una canción por línea';

  @override
  String get filterCity => 'Ciudad';

  @override
  String get filterAllCities => 'En todas';

  @override
  String viewingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count títulos',
      one: '1 título',
      zero: 'Nada visto',
    );
    return '$_temp0';
  }

  @override
  String get viewingSearchHint => 'Buscar títulos, directores, notas';

  @override
  String get viewingEmptyTitle => 'Todavía no viste nada';

  @override
  String get viewingEmptyBody =>
      'Registrá lo que ves y el año te va a contar una historia.';

  @override
  String get viewingEmptyFiltered => 'Nada coincide con estos filtros';

  @override
  String get addViewing => 'Agregar título';

  @override
  String get newViewing => 'Nuevo título';

  @override
  String get editViewing => 'Editar título';

  @override
  String get deleteViewing => 'Eliminar título';

  @override
  String get fieldTitle => 'Título';

  @override
  String get fieldTitleRequired => 'Necesita un título';

  @override
  String get fieldKind => 'Tipo';

  @override
  String get kindFilm => 'Película';

  @override
  String get kindSeries => 'Serie';

  @override
  String get kindMiniseries => 'Miniserie';

  @override
  String get kindDocumentary => 'Documental';

  @override
  String get fieldReleaseYear => 'Año de estreno';

  @override
  String get fieldDirector => 'Dirección';

  @override
  String get fieldCast => 'Reparto';

  @override
  String get fieldCastHint => 'Separalos con comas';

  @override
  String get fieldSeason => 'Temporada';

  @override
  String seasonValue(int number) {
    return 'Temporada $number';
  }

  @override
  String get fieldWatchedOn => 'Visto el';

  @override
  String get filterKind => 'Tipo';

  @override
  String get filterAllKinds => 'Todo';

  @override
  String gameCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count juegos',
      one: '1 juego',
      zero: 'Sin juegos',
    );
    return '$_temp0';
  }

  @override
  String get gameSearchHint => 'Buscar juegos, plataformas, notas';

  @override
  String get gameEmptyTitle => 'No hay juegos registrados';

  @override
  String get gameEmptyBody =>
      'Abandonar un juego también es un veredicto. Registralo igual.';

  @override
  String get gameEmptyFiltered => 'Ningún juego coincide con estos filtros';

  @override
  String get addGame => 'Agregar juego';

  @override
  String get newGame => 'Nuevo juego';

  @override
  String get editGame => 'Editar juego';

  @override
  String get deleteGame => 'Eliminar juego';

  @override
  String get fieldStatus => 'Estado';

  @override
  String get statusPlaying => 'Jugando';

  @override
  String get statusFinished => 'Terminado';

  @override
  String get statusHundredPercent => '100%';

  @override
  String get statusDropped => 'Abandonado';

  @override
  String get fieldPlatform => 'Plataforma';

  @override
  String get fieldHoursPlayed => 'Horas jugadas';

  @override
  String get fieldPlayedUntil => 'Última vez jugado';

  @override
  String hoursValue(String hours) {
    return '${hours}h';
  }

  @override
  String get filterStatus => 'Estado';

  @override
  String get filterAllStatuses => 'Cualquier estado';

  @override
  String get filterPlatform => 'Plataforma';

  @override
  String get filterAllPlatforms => 'Cualquier plataforma';

  @override
  String get fieldAte => 'Comido el';

  @override
  String get fieldSawOn => 'Visto el';

  @override
  String get enrich => 'Buscar datos';

  @override
  String get enrichSearching => 'Buscando…';

  @override
  String get enrichNoResults => 'No se encontró nada. Completá a mano.';

  @override
  String get enrichOffline => 'Sin conexión. Igual podés completar a mano.';

  @override
  String get enrichFailed => 'La búsqueda falló. Igual podés completar a mano.';

  @override
  String enrichCredit(String source) {
    return 'Datos de $source';
  }

  @override
  String get statsEntries => 'Registros';

  @override
  String get statsRated => 'Puntuados';

  @override
  String get statsByDomain => 'Por sección';

  @override
  String get statsBestOverall => 'Tu puntaje más alto';

  @override
  String get statsPerYearAll => 'Registros por año';

  @override
  String get statsHoursPlayed => 'Horas jugadas';

  @override
  String get statsMoneySpent => 'Gastado en comidas';

  @override
  String get statsNothingRated => 'Todavía no puntuaste nada';

  @override
  String get enrichMissingKey =>
      'No hay clave configurada. Agregá una en Ajustes, o completá a mano.';

  @override
  String get settingsLookups => 'Búsquedas';

  @override
  String get settingsLookupsBody =>
      'Opcional. Pegá tus propias claves gratuitas para completar portadas y datos automáticamente. Memini funciona completo sin ellas.';

  @override
  String get settingsTmdbKey => 'Clave de TMDB (películas y series)';

  @override
  String get settingsRawgKey => 'Clave de RAWG (videojuegos)';

  @override
  String get settingsKeyNotSet => 'Sin configurar';

  @override
  String get settingsKeySet => 'Configurada';

  @override
  String get settingsMusicBrainzNote =>
      'Las bandas usan MusicBrainz, que no necesita clave.';
}
