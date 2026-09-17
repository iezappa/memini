import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/enrichment/data/enrichment_providers.dart';

void main() {
  test('MusicBrainz is told the real repository, as its rules ask', () {
    expect(
      kMusicBrainzUserAgent,
      contains('https://github.com/iezappa/memini'),
    );
  });
}
