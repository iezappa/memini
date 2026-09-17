import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../app/providers.dart';
import '../../../core/time/clock.dart';
import '../../../core/versioning/app_version.dart';
import '../../release_notes/presentation/release_notes_providers.dart';
import '../data/github_update_service.dart';
import '../data/service_worker_bridge.dart';
import '../data/web_update_service.dart';
import '../domain/update_service.dart';

/// The version running, from the bundled release notes a test pins to
/// pubspec.yaml — no platform plugin needed to know it.
final runningVersionProvider = FutureProvider<AppVersion>(
  (ref) async => (await ref.watch(releaseNotesProvider('en').future)).current,
);

final serviceWorkerBridgeProvider = Provider<ServiceWorkerBridge>(
  (ref) => const ServiceWorkerBridge(),
);

final updateServiceProvider = Provider<UpdateService>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  final settings = ref.watch(settingsRepositoryProvider);
  Future<AppVersion> current() => ref.read(runningVersionProvider.future);

  if (kIsWeb) {
    final bridge = ref.watch(serviceWorkerBridgeProvider);
    return WebUpdateService(
      client: client,
      base: bridge.base,
      current: current,
      hasWaitingWorker: bridge.hasUpdate,
      now: ref.watch(clockProvider),
    );
  }
  return GitHubUpdateService(
    client: client,
    current: current,
    now: ref.watch(clockProvider),
    lastCheckedAt: () => settings.lastUpdateCheckAt,
    recordCheck: settings.recordUpdateCheck,
    isAndroid: defaultTargetPlatform == TargetPlatform.android,
  );
});

/// The update to announce, or null. Re-run on resume by invalidating it.
final availableUpdateProvider = FutureProvider<UpdateInfo?>((ref) async {
  final info = await ref.watch(updateServiceProvider).check();
  if (info == null) return null;
  final dismissed = ref
      .watch(settingsRepositoryProvider)
      .dismissedUpdateVersion;
  return dismissed == '${info.latest}' ? null : info;
});
