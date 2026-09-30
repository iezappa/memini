class LanSyncSession {
  const LanSyncSession({required this.url, required this.received});

  final Uri url;
  final Stream<String> received;

  Future<void> close() async {}
}

class LanSyncService {
  const LanSyncService();

  bool get isSupported => false;

  Future<LanSyncSession> startReceiving() async {
    throw UnsupportedError(
      'LAN sync receiving is not supported on this platform.',
    );
  }

  Future<void> send({required Uri url, required String contents}) async {
    throw UnsupportedError(
      'LAN sync sending is not supported on this platform.',
    );
  }
}
