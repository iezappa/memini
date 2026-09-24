/// What the owner is in the mood for, as the shelf asks it.
///
/// A mood rather than a genre list. TMDB has nineteen genres and RAWG has
/// nineteen of its own, and nobody opens an app thinking "science fiction,
/// 878"; they think "something funny". Each mood carries the answer both
/// services understand, and the mapping lives here so the wording can
/// change without touching either request.
///
/// The two catalogues do not line up, and pretending otherwise is how a
/// shelf ends up answering "something to make me cry" with a racing game.
/// Where RAWG has no genre for a mood, the nearest **tag** is used instead:
/// tags are how RAWG describes horror, which its genre list has no word
/// for. A tag that turns out not to match returns nothing, and a mood with
/// no game behind it simply shows the film — which is the honest outcome.
enum Mood {
  laugh(tmdbGenreId: '35', rawgTag: 'funny'),
  cry(tmdbGenreId: '18', rawgTag: 'story-rich'),
  scare(tmdbGenreId: '27', rawgTag: 'horror'),
  love(tmdbGenreId: '10749', rawgTag: 'romance'),
  thrill(tmdbGenreId: '53', rawgGenre: 'shooter'),
  elsewhere(tmdbGenreId: '878', rawgGenre: 'role-playing-games-rpg'),
  learn(tmdbGenreId: '99', rawgGenre: 'educational'),
  family(tmdbGenreId: '10751', rawgGenre: 'family');

  const Mood({required this.tmdbGenreId, this.rawgGenre, this.rawgTag});

  /// The TMDB genre this mood asks for.
  final String tmdbGenreId;

  /// The RAWG genre slug, where one says the same thing.
  final String? rawgGenre;

  /// The RAWG tag slug, for the moods its genres have no word for.
  final String? rawgTag;
}
