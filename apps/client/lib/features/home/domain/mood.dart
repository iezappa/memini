/// What the owner is in the mood for, as the shelf asks it.
///
/// A mood rather than a genre list. TMDB has nineteen genres and nobody
/// opens an app thinking "science fiction, 878"; they think "something
/// funny". Each of these maps onto the genre that answers it, and the
/// mapping lives here so the wording can change without touching the
/// request.
enum Mood {
  laugh('35'),
  cry('18'),
  scare('27'),
  love('10749'),
  thrill('53'),
  elsewhere('878'),
  learn('99'),
  family('10751');

  const Mood(this.tmdbGenreId);

  /// The TMDB genre this mood asks for.
  final String tmdbGenreId;
}
