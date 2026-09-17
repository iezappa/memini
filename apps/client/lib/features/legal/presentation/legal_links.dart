import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/support_actions.dart';

/// Who publishes the app, as the legal documents name them.
const kDeveloperName = 'Zeke Zappa Developments (iezappa)';

/// The only public contact: the repository's issue tracker. No email.
final kContactUrl = Uri.parse('https://github.com/iezappa/memini/issues');

/// Opens a link outside the app. Overridden in tests.
final urlOpenerProvider = Provider<UrlOpener>(
  (ref) =>
      (url) => launchUrl(url, mode: LaunchMode.externalApplication),
);
