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
    return 'Bienvenido, $name';
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
  String get settingsSyncer => 'Syncer';

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
      'Importar reemplaza todas las entradas guardadas. Exportá un backup primero si querés conservarlas.';

  @override
  String get importConfirm => 'Reemplazar';

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entradas restauradas',
      one: '1 entrada restaurada',
    );
    return '$_temp0';
  }

  @override
  String importInvalidFormat(String reason) {
    return 'Ese archivo no es un backup válido de Memini ($reason).';
  }

  @override
  String importRestoreFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entradas',
      one: '1 entrada',
    );
    return 'El archivo es válido y contiene $_temp0, pero no se pudo escribir en el almacenamiento del navegador.';
  }

  @override
  String get importFailed => 'Ese archivo no es un backup válido de Memini.';

  @override
  String get syncerBody =>
      'Pasá entradas desde otro dispositivo sin reemplazar este. Memini te muestra nuevas, duplicadas y conflictos antes de escribir nada.';

  @override
  String get syncerExport => 'Exportar paquete de sync';

  @override
  String get syncerImport => 'Importar desde otro dispositivo';

  @override
  String get syncerReceiveWifi => 'Recibir por WiFi';

  @override
  String get syncerSendWifi => 'Enviar por WiFi';

  @override
  String get syncerWifiNativeHint =>
      'Funciona mejor entre apps instaladas en el mismo WiFi. En navegador, mantené el sync por archivo como respaldo.';

  @override
  String get syncerExportDone => 'Paquete de sync guardado.';

  @override
  String get syncerPreviewTitle => 'Vista previa del sync';

  @override
  String syncerPreviewBody(
    int newCount,
    int duplicateCount,
    int conflictCount,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      newCount,
      locale: localeName,
      other: '$newCount entradas nuevas',
      one: '1 entrada nueva',
      zero: 'No hay entradas nuevas',
    );
    String _temp1 = intl.Intl.pluralLogic(
      duplicateCount,
      locale: localeName,
      other: '$duplicateCount duplicadas',
      one: '1 duplicada',
      zero: 'No hay duplicadas',
    );
    String _temp2 = intl.Intl.pluralLogic(
      conflictCount,
      locale: localeName,
      other: '$conflictCount conflictos',
      one: '1 conflicto',
      zero: 'No hay conflictos',
    );
    return '$_temp0. $_temp1 se van a omitir. $_temp2 no se van a sobrescribir.';
  }

  @override
  String get syncerApply => 'Aplicar sync';

  @override
  String syncerApplyDone(int newCount, int duplicateCount, int conflictCount) {
    String _temp0 = intl.Intl.pluralLogic(
      newCount,
      locale: localeName,
      other: '$newCount entradas agregadas',
      one: '1 entrada agregada',
      zero: 'No se agregaron entradas',
    );
    String _temp1 = intl.Intl.pluralLogic(
      duplicateCount,
      locale: localeName,
      other: '$duplicateCount duplicadas omitidas',
      one: '1 duplicada omitida',
      zero: 'No se omitieron duplicadas',
    );
    String _temp2 = intl.Intl.pluralLogic(
      conflictCount,
      locale: localeName,
      other: '$conflictCount conflictos quedaron sin cambios',
      one: '1 conflicto quedó sin cambios',
      zero: 'Sin conflictos',
    );
    return '$_temp0. $_temp1. $_temp2.';
  }

  @override
  String get syncerFailed => 'No se pudo sincronizar ese archivo.';

  @override
  String get syncerWifiUnsupported =>
      'El sync WiFi en vivo no está disponible en esta versión de navegador. Usá exportar/importar paquete de sync.';

  @override
  String get syncerReceiveWifiTitle => 'Recibir por WiFi';

  @override
  String syncerReceiveWifiBody(String url) {
    return 'Dejá esta pantalla abierta. En el otro dispositivo, abrí esta dirección desde Enviar por WiFi de Memini, o abrila en un navegador y subí un paquete de sync:\n\n$url';
  }

  @override
  String get syncerSendWifiTitle => 'Enviar por WiFi';

  @override
  String get syncerSendWifiHint =>
      'Dirección del receptor, ej. http://192.168.1.20:12345/codigo';

  @override
  String get syncerSendWifiAction => 'Enviar';

  @override
  String get syncerWifiBadUrl => 'Esa dirección de recepción no es válida.';

  @override
  String get syncerWifiSent =>
      'Paquete de sync enviado. Revisá el dispositivo receptor.';

  @override
  String get syncerWifiFailed =>
      'No se pudo completar el sync WiFi. Usá exportar/importar paquete de sync.';

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
      'Registrá salas de escape, comidas, recitales, películas, series y juegos: la fecha y los datos que importan en cada caso. Lo que todavía no hiciste va a pendientes.';

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
  String get fieldPhotosUrl => 'URL del álbum de fotos';

  @override
  String get fieldVideoUrl => 'URL del video de YouTube';

  @override
  String get urlInvalid => 'Ingresá una URL http(s) completa.';

  @override
  String get youtubeUrlInvalid => 'Ingresá una URL de YouTube.';

  @override
  String get gigLinksLabel => 'Enlaces';

  @override
  String get gigPhotosLink => 'Álbum de fotos';

  @override
  String get gigVideoLink => 'Video de YouTube';

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
      'Opcional. Pegá tus propias claves gratuitas para completar datos automáticamente. Memini funciona completo sin ellas.';

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

  @override
  String get storageDegradedWarning =>
      'Este navegador guarda tus datos en un almacenamiento que puede perderse al recargar o al borrar los datos del navegador. Exportá un backup ahora.';

  @override
  String get storageVolatileWarning =>
      'Este navegador no puede guardar tus datos: todo lo que anotes se pierde al cerrar esta pestaña. Exportá un backup antes de irte.';

  @override
  String get storageExportNow => 'Exportar ahora';

  @override
  String get storageWarningDismiss => 'Ocultar';

  @override
  String get recoveryTitle => 'No se pudo abrir la base de datos local';

  @override
  String get recoveryBody =>
      'Los datos guardados en este dispositivo no se pudieron leer, así que la app no puede arrancar normalmente. Podés restaurar un backup o empezar de cero con una base vacía.';

  @override
  String get recoveryImport => 'Importar un backup';

  @override
  String get recoveryReset => 'Restablecer la base de datos local';

  @override
  String get recoveryImportConfirmTitle => '¿Importar un backup?';

  @override
  String get recoveryImportConfirmBody =>
      'La base ilegible de este dispositivo se borra para siempre y queda lo que traiga el archivo de backup. No se puede deshacer.';

  @override
  String get recoveryResetConfirmTitle =>
      '¿Restablecer la base de datos local?';

  @override
  String get recoveryResetConfirmBody =>
      'Todo lo guardado en este dispositivo se borra para siempre y la app arranca vacía. No se puede deshacer.';

  @override
  String get recoveryResetConfirmAction => 'Restablecer';

  @override
  String get backupNoticeTitle => 'Tus datos viven solo en este dispositivo';

  @override
  String get backupNoticeBody =>
      'Memini no se guarda en ningún servidor. Si desinstalás la app, perdés o reseteás el dispositivo o borrás los datos del navegador, todo lo que anotaste se pierde. Exportá un backup seguido desde Ajustes → Tus datos y guardá el archivo en otro lado.';

  @override
  String get backupNoticeCheckbox => 'Entiendo, y voy a exportar backups';

  @override
  String get backupNoticeAccept => 'Entendido, voy a hacer backups';

  @override
  String get backupNoticeSettings =>
      'Tus datos no se guardan en ningún servidor. Exportá seguido y guardá el archivo fuera de este dispositivo.';

  @override
  String get backupReminderNever =>
      'Todavía no hiciste un backup de tus datos.';

  @override
  String backupReminderOverdue(int days) {
    return 'Tu último backup fue hace $days días.';
  }

  @override
  String get backupReminderAction => 'Exportar';

  @override
  String get backupReminderDismiss => 'Ahora no';

  @override
  String get importExportFirst => 'Exportar los datos actuales antes';

  @override
  String get eraseAllData => 'Borrar todos mis datos';

  @override
  String get eraseAllTitle => '¿Borrar todos tus datos?';

  @override
  String get eraseAllBody =>
      'Se borran todas las entradas y franquicias de este dispositivo, junto con tu PIN, tu nombre, tus claves de búsqueda y tus ajustes; solo se conservan el idioma y la apariencia. Después la app vuelve a empezar desde la bienvenida. No se puede deshacer y no existe ninguna copia en otro lado: exportá antes si podrías querer algo de vuelta.';

  @override
  String get eraseAllConfirmWord => 'BORRAR';

  @override
  String eraseAllTypeToConfirm(String word) {
    return 'Escribí $word para confirmar';
  }

  @override
  String get eraseAllExportFirst => 'Exportar antes';

  @override
  String get eraseAllAction => 'Borrar todo';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get termsOfUse => 'Términos de uso';

  @override
  String get developerContact => 'Desarrollador';

  @override
  String get developerContactHint =>
      'Consultas y reportes: el registro de issues del proyecto';

  @override
  String get openSourceLicenses => 'Licencias';

  @override
  String whatsNewTitle(String version) {
    return 'Novedades en $version';
  }

  @override
  String get whatsNewClose => 'Entendido';

  @override
  String get releaseNotesHistory => 'Novedades';

  @override
  String aboutVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get aboutVersionHint => 'Ver qué cambió en cada versión';

  @override
  String get updateAvailableTitle => 'Hay una versión nueva';

  @override
  String updateAvailableBody(String version) {
    return 'La versión $version está disponible.';
  }

  @override
  String get updateAvailableBackupHint =>
      'Esta versión cambia cómo se guardan tus datos. Exporta un respaldo antes de actualizar.';

  @override
  String get updateUnsupportedPath =>
      'Tu versión es muy antigua para actualizar directo. Exporta un respaldo y consulta las instrucciones.';

  @override
  String get updateActionReload => 'Actualizar';

  @override
  String get updateActionDownload => 'Descargar';

  @override
  String get updateActionExport => 'Exportar';

  @override
  String get updateActionDismiss => 'Ahora no';

  @override
  String get saveFailed => 'No se pudo guardar. Intentá de nuevo.';

  @override
  String get deleteFailed => 'No se pudo eliminar. Intentá de nuevo.';

  @override
  String get staleStoreTitle => 'Hay otra pestaña con una versión anterior';

  @override
  String get staleStoreBody =>
      'Memini está abierto en otra pestaña o ventana con una versión anterior, y mientras siga abierta esta no puede guardar nada. Tus datos están intactos. Cerrá todas las demás pestañas de Memini y volvé a cargar esta página.';

  @override
  String get tutorialBack => 'Atrás';

  @override
  String get tutorialDone => 'Empezar';

  @override
  String tutorialPageOf(int page, int total) {
    return '$page de $total';
  }

  @override
  String get homeActivity => 'Actividad';

  @override
  String homeActivityCaption(int weeks) {
    return 'Últimas $weeks semanas';
  }

  @override
  String get homeActivityEmpty =>
      'Todavía no anotaste nada. Cada cosa que registres pinta un cuadradito.';

  @override
  String homeActivityTotal(int count) {
    return '$count registros';
  }

  @override
  String homeActivityDays(int days) {
    return '$days días con algo';
  }

  @override
  String homeActivityRun(int days) {
    return 'Racha más larga: $days días';
  }

  @override
  String get homeActivityLess => 'Menos';

  @override
  String get homeActivityMore => 'Más';

  @override
  String homeActivityCell(String date, int count) {
    return '$date: $count registros';
  }

  @override
  String homeActivityCellEmpty(String date) {
    return '$date: nada anotado';
  }

  @override
  String get homeShortcuts => 'Anotar algo';

  @override
  String get homeNumbers => 'En números';

  @override
  String get homeStatEntries => 'Anotado';

  @override
  String get homeStatRating => 'Puntaje promedio';

  @override
  String get homeStatThisMonth => 'Este mes';

  @override
  String get homeStatNone => '—';

  @override
  String get homeSuggestions => 'Para ver o jugar';

  @override
  String get homeSuggestionsAnother => 'Otra';

  @override
  String get homeSuggestionsNoKey =>
      'Cargá tu clave de TMDB o de RAWG en Ajustes para ver sugerencias.';

  @override
  String get homeSuggestionsUnavailable =>
      'No se pudieron traer sugerencias ahora.';

  @override
  String get homeMoodPrompt => 'Me siento…';

  @override
  String get homeMoodAny => 'Lo que sea';

  @override
  String get moodLaugh => 'Con ganas de reír';

  @override
  String get moodCry => 'Para llorar un rato';

  @override
  String get moodScare => 'Con ganas de pasar miedo';

  @override
  String get moodLove => 'Romántico';

  @override
  String get moodThrill => 'Con ganas de tensión';

  @override
  String get moodElsewhere => 'En otro mundo';

  @override
  String get moodLearn => 'Con ganas de aprender algo';

  @override
  String get moodFamily => 'Para ver en familia';

  @override
  String get photosLabel => 'Fotos';

  @override
  String get photosAdd => 'Agregar foto';

  @override
  String get photosEmpty => 'Todavía no le pusiste ninguna foto.';

  @override
  String get photosRemove => 'Quitar foto';

  @override
  String get photosRemoveConfirm => '¿Quitar esta foto?';

  @override
  String get photosNotInBackup =>
      'Las fotos no viajan en el archivo de backup: se copian aparte en la carpeta que elijas.';

  @override
  String get photoFolderTitle => 'Carpeta de fotos';

  @override
  String get photoFolderChoose => 'Elegir';

  @override
  String get photoFolderChange => 'Cambiar';

  @override
  String get photoFolderStop => 'Dejar de copiar';

  @override
  String get photoFolderCopyAll => 'Copiar todas las fotos ahora';

  @override
  String get photoFolderOff =>
      'Sin elegir. Las fotos viven solamente dentro de la app.';

  @override
  String photoFolderOn(String folder) {
    return 'Copiando cada foto en $folder.';
  }

  @override
  String get photoFolderUnsupported =>
      'Este navegador no puede escribir en una carpeta. Chrome y Edge sí.';

  @override
  String get photoFolderGone => 'Esa carpeta ya no está. Elegila de nuevo.';

  @override
  String get photoFolderNeedsPermission =>
      'El navegador quiere que le vuelvas a dar permiso a esa carpeta.';

  @override
  String get photoFolderFailed => 'No se pudo escribir la última copia.';

  @override
  String get viewGrid => 'Ver en grilla';

  @override
  String get viewList => 'Ver en lista';

  @override
  String get previousPage => 'Página anterior';

  @override
  String get nextPage => 'Página siguiente';

  @override
  String pageOf(int page, int pages) {
    return '$page de $pages';
  }

  @override
  String get navWatchlist => 'Pendientes';

  @override
  String get watchlistTitle => 'Pendientes';

  @override
  String get watchlistSearchHint => 'Buscar en pendientes';

  @override
  String watchlistCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cosas pendientes',
      one: '1 cosa pendiente',
      zero: 'Nada en la lista',
    );
    return '$_temp0';
  }

  @override
  String get watchlistAdd => 'Agregar a pendientes';

  @override
  String get watchlistEmptyTitle => 'Todavía no hay nada esperando';

  @override
  String get watchlistEmptyBody =>
      'La película de la que todos hablan, el juego esperando una oferta, la banda que todavía no anunció gira. Ponelo acá antes de olvidarte.';

  @override
  String get watchlistEmptyFiltered => 'Nada de la lista coincide con eso.';

  @override
  String get watchlistSortNewest => 'Agregado último';

  @override
  String get watchlistSortOldest => 'Agregado primero';

  @override
  String get wishKindScreen => 'Película o serie';

  @override
  String get wishKindGame => 'Juego';

  @override
  String get wishKindMusic => 'Banda';

  @override
  String get wishKindAll => 'Todo';

  @override
  String get wishNote => 'Por qué está acá';

  @override
  String get wishNoteHint =>
      'Quién te lo recomendó, dónde se ve, que estás esperando una oferta.';

  @override
  String wishAdded(String date) {
    return 'Agregado el $date';
  }

  @override
  String get wishSave => 'Guardar en pendientes';

  @override
  String get wishDelete => 'Sacar de pendientes';

  @override
  String wishDeleteConfirm(String title) {
    return '¿Sacar “$title” de pendientes?';
  }

  @override
  String get wishDone => 'Ya la vi';

  @override
  String get wishDoneGame => 'Ya lo jugué';

  @override
  String get wishDoneMusic => 'Ya los vi';

  @override
  String get wishMovedToScreen => 'Pasó a Películas y series.';

  @override
  String get wishMovedToGames => 'Pasó a Juegos.';

  @override
  String get wishMovedToConcerts => 'Pasó a Recitales.';

  @override
  String get wishMovedOpen => 'Abrir';

  @override
  String get wishMovedBody =>
      'Guardado con la fecha de hoy y sin puntuación. Abrilo para decir qué te pareció.';

  @override
  String get fieldMapsUrl => 'Link al lugar en un mapa';

  @override
  String get fieldMapsUrlHint =>
      'Pegá el link de cualquier app de mapas. Si trae coordenadas, acá se dibuja el mapa; un link acortado igual abre, solo que no se puede dibujar.';

  @override
  String get mapLabel => 'Dónde queda';

  @override
  String get mapOpen => 'Abrir en el mapa';

  @override
  String get mapNoCoordinates =>
      'Este link no trae la posición adentro, así que no hay nada que dibujar. Un link copiado del mapa en una computadora suele traerla.';

  @override
  String get domainBooks => 'Libros';

  @override
  String get bookSearchHint => 'Buscar libros, autores, notas';

  @override
  String bookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count libros',
      one: '1 libro',
      zero: 'Sin libros',
    );
    return '$_temp0';
  }

  @override
  String get bookEmptyTitle => 'No hay libros registrados';

  @override
  String get bookEmptyBody => 'Agregá libros después de terminarlos.';

  @override
  String get bookEmptyFiltered => 'Ningún libro coincide con estos filtros';

  @override
  String get addBook => 'Agregar libro';

  @override
  String get newBook => 'Nuevo libro';

  @override
  String get editBook => 'Editar libro';

  @override
  String get deleteBook => 'Eliminar libro';

  @override
  String get fieldAuthor => 'Autor';

  @override
  String get fieldPublicationYear => 'Año de publicación';

  @override
  String get fieldReadOn => 'Leído el';

  @override
  String get serverAccountTitle => 'Cuenta de servidor';

  @override
  String get serverAccountHint =>
      'Opcional: conectá tu propio servidor Memini para backup con cuenta. El modo local sigue disponible sin login.';

  @override
  String get serverUrl => 'URL del servidor';

  @override
  String get serverUsername => 'Usuario';

  @override
  String get serverPassword => 'Contraseña';

  @override
  String get serverConnect => 'Conectar';

  @override
  String get serverReconnect => 'Reconectar';

  @override
  String get serverDisconnect => 'Desconectar';

  @override
  String get serverConnected => 'Conectado al servidor.';

  @override
  String get serverDisconnected =>
      'Desconectado del servidor. Los datos locales quedan en este dispositivo.';

  @override
  String serverConnectedAs(String username, String server) {
    return 'Conectado como $username en $server';
  }

  @override
  String get serverManualSyncHint =>
      'Backup manual al servidor. Subir copia este dispositivo a la cuenta; Descargar reemplaza este dispositivo con el backup de la cuenta.';

  @override
  String get serverUpload => 'Subir a la cuenta';

  @override
  String get serverDownload => 'Descargar de la cuenta';

  @override
  String serverUploaded(int count) {
    return 'Se subieron $count registros a la cuenta';
  }

  @override
  String serverDownloaded(int count) {
    return 'Se descargaron $count registros de la cuenta';
  }

  @override
  String get serverDownloadConfirmBody =>
      'Los datos de este dispositivo se van a borrar y reemplazar por el backup de la cuenta. Subí o exportá primero si no estás seguro.';

  @override
  String get serverFamilyAccounts => 'Cuentas familiares';

  @override
  String get serverFamilyAccountsHint =>
      'Solo admin: creá cuentas para familiares. Van a entrar con su propio usuario y contraseña.';

  @override
  String get serverNewUsername => 'Nuevo usuario';

  @override
  String get serverNewPassword => 'Nueva contraseña';

  @override
  String get serverCreateUser => 'Crear cuenta';

  @override
  String get serverUserCreated =>
      'Cuenta creada. Compartí la URL del servidor, el usuario y la contraseña con esa persona.';

  @override
  String get serverUsernameRequired => 'Ingresá un usuario.';

  @override
  String get serverPasswordTooShort =>
      'Usá al menos 8 caracteres para la contraseña.';

  @override
  String get backupConfirmTitle => '¿Reemplazar este dispositivo?';
}
