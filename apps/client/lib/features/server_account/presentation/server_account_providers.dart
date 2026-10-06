import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../backup/domain/backup_document.dart';
import '../data/memini_server_client.dart';
import '../domain/server_account.dart';

final serverBaseUrlProvider = NotifierProvider<ServerBaseUrlController, String>(
  ServerBaseUrlController.new,
);
final serverUsernameProvider =
    NotifierProvider<ServerUsernameController, String>(
      ServerUsernameController.new,
    );
final serverTokenProvider = NotifierProvider<ServerTokenController, String>(
  ServerTokenController.new,
);
final serverIsAdminProvider = NotifierProvider<ServerIsAdminController, bool>(
  ServerIsAdminController.new,
);

class ServerBaseUrlController extends _StringPreferenceController {
  @override
  String get key => 'serverAccount.baseUrl';
}

class ServerUsernameController extends _StringPreferenceController {
  @override
  String get key => 'serverAccount.username';
}

class ServerTokenController extends _StringPreferenceController {
  @override
  String get key => 'serverAccount.token';
}

abstract class _StringPreferenceController extends Notifier<String> {
  String get key;

  @override
  String build() => ref.watch(sharedPreferencesProvider).getString(key) ?? '';

  void set(String value) {
    state = value;
    ref.read(sharedPreferencesProvider).setString(key, value);
  }
}

class ServerIsAdminController extends Notifier<bool> {
  @override
  bool build() =>
      ref.watch(sharedPreferencesProvider).getBool('serverAccount.isAdmin') ??
      false;

  void set(bool value) {
    state = value;
    ref.read(sharedPreferencesProvider).setBool('serverAccount.isAdmin', value);
  }
}

final serverAccountProvider = Provider<ServerAccount>(
  (ref) => ServerAccount(
    baseUrl: ref.watch(serverBaseUrlProvider),
    username: ref.watch(serverUsernameProvider),
    token: ref.watch(serverTokenProvider),
    isAdmin: ref.watch(serverIsAdminProvider),
  ),
);

final serverAccountActionsProvider = Provider<ServerAccountActions>(
  ServerAccountActions.new,
);

sealed class ServerBackupOutcome {
  const ServerBackupOutcome();
}

class ServerBackupSucceeded extends ServerBackupOutcome {
  const ServerBackupSucceeded(this.rows);

  final int rows;
}

class ServerBackupFailed extends ServerBackupOutcome {
  const ServerBackupFailed(this.error);

  final Object error;
}

class ServerAccountActions {
  ServerAccountActions(this._ref);

  final Ref _ref;

  Future<void> connect({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    final client = MeminiServerClient(baseUrl: baseUrl);
    await client.healthCheck();
    final login = await client.login(username: username, password: password);
    _ref.read(serverBaseUrlProvider.notifier).set(baseUrl.trim());
    _ref.read(serverUsernameProvider.notifier).set(login.user.username.trim());
    _ref.read(serverTokenProvider.notifier).set(login.token);
    _ref.read(serverIsAdminProvider.notifier).set(login.user.isAdmin);
  }

  Future<void> disconnect() async {
    final account = _ref.read(serverAccountProvider);
    if (account.isConnected) {
      try {
        await MeminiServerClient(baseUrl: account.baseUrl)
            .logout(account.token);
      } on Object {
        // Local disconnect must always remove the token from this device.
      }
    }
    _ref.read(serverTokenProvider.notifier).set('');
    _ref.read(serverUsernameProvider.notifier).set('');
    _ref.read(serverIsAdminProvider.notifier).set(false);
  }

  Future<void> createUser({
    required String username,
    required String password,
  }) async {
    final account = _ref.read(serverAccountProvider);
    if (!account.isConnected || !account.isAdmin) {
      throw const ServerAccountException('Admin account required');
    }
    await MeminiServerClient(
      baseUrl: account.baseUrl,
    ).createUser(token: account.token, username: username, password: password);
  }

  Future<ServerBackupOutcome> uploadLocalBackup() async {
    final account = _ref.read(serverAccountProvider);
    if (!account.isConnected) {
      return const ServerBackupFailed(ServerAccountException('Not connected'));
    }
    try {
      final document = await _ref.read(backupServiceProvider).read();
      final result = await MeminiServerClient(baseUrl: account.baseUrl)
          .uploadBackup(token: account.token, document: document);
      return ServerBackupSucceeded(result.rowCount);
    } on Object catch (error) {
      return ServerBackupFailed(error);
    }
  }

  Future<ServerBackupOutcome> downloadServerBackup() async {
    final account = _ref.read(serverAccountProvider);
    if (!account.isConnected) {
      return const ServerBackupFailed(ServerAccountException('Not connected'));
    }
    try {
      final BackupDocument document = await MeminiServerClient(
        baseUrl: account.baseUrl,
      ).downloadBackup(token: account.token);
      await _ref.read(backupServiceProvider).restore(document);
      _ref.invalidate(databaseProvider);
      return ServerBackupSucceeded(document.entryCount);
    } on Object catch (error) {
      return ServerBackupFailed(error);
    }
  }
}
