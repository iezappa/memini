/// A place on the earth, in the only two numbers a map needs.
class MapPoint {
  const MapPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  /// Whether the pair could be a real place. Anything else came out of a
  /// pattern that matched something that was not a coordinate.
  bool get isOnEarth =>
      latitude.abs() <= 90 &&
      longitude.abs() <= 180 &&
      !(latitude == 0 && longitude == 0);

  @override
  bool operator ==(Object other) =>
      other is MapPoint &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'MapPoint($latitude, $longitude)';
}

/// The coordinates inside a link to a map, or null when there are none.
///
/// Everything here is read out of the text on the device: no request is made
/// and no service is asked what the link means. That is the whole design —
/// a map link is a string the owner pasted, and reading it should not tell
/// anybody that they pasted it.
///
/// It therefore cannot open a shortened link (`maps.app.goo.gl/…`), which
/// carries no coordinates at all: the place lives behind a redirect, and
/// following it would mean asking the shortener. Those links still save and
/// still open — there is simply no preview to draw.
MapPoint? parseMapLink(String? link) {
  final text = link?.trim();
  if (text == null || text.isEmpty) return null;

  for (final pattern in _patterns) {
    final match = pattern.firstMatch(text);
    if (match == null) continue;

    final point = MapPoint(
      double.parse(match.group(1)!),
      double.parse(match.group(2)!),
    );
    if (point.isOnEarth) return point;
  }

  return null;
}

/// Ordered: the most specific way each service names a place comes first,
/// because the same link often carries both the pin and the corner of the
/// map that happened to be on screen when it was copied.
final _patterns = <RegExp>[
  // Google's own data block, which is where the place itself is.
  RegExp(r'!3d(-?\d+\.\d+)!4d(-?\d+\.\d+)'),
  // OpenStreetMap's marker.
  RegExp(r'mlat=(-?\d+\.?\d*)&(?:amp;)?mlon=(-?\d+\.?\d*)'),
  // Google's viewport: /@lat,lng,17z
  RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)'),
  // ?q=lat,lng — Google, and what a "copy coordinates" gives you.
  RegExp(r'[?&](?:q|query|ll|center|daddr)=(-?\d+\.\d+)(?:,|%2C)\s*(-?\d+\.\d+)'),
  // geo: URIs, which is what a phone hands over when you share a pin.
  RegExp(r'^geo:(-?\d+\.\d+),(-?\d+\.\d+)'),
  // OpenStreetMap's own address bar: #map=19/lat/lon
  RegExp(r'#map=\d+\.?\d*/(-?\d+\.\d+)/(-?\d+\.\d+)'),
  // Two numbers and nothing else: pasted straight out of a map's "copy
  // coordinates", which is the shortest way to say where something is.
  RegExp(r'^(-?\d+\.\d+)\s*,\s*(-?\d+\.\d+)$'),
];
