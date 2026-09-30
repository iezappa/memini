import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

class LanSyncSession {
  LanSyncSession._({
    required this.url,
    required this.received,
    required this._closeServer,
  });

  final Uri url;
  final Stream<String> received;
  final Future<void> Function() _closeServer;
  var _closed = false;

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _closeServer();
  }
}

class LanSyncService {
  const LanSyncService();

  bool get isSupported => true;

  Future<LanSyncSession> startReceiving() async {
    final token = _token();
    final controller = StreamController<String>.broadcast();
    final server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    final address = await _localAddress();
    final url = Uri.parse('http://$address:${server.port}/$token');

    unawaited(
      server.forEach((request) async {
        try {
          await _handle(request, token, controller);
        } on Object {
          request.response.statusCode = HttpStatus.internalServerError;
          await request.response.close();
        }
      }),
    );

    return LanSyncSession._(
      url: url,
      received: controller.stream,
      closeServer: () async {
        await server.close(force: true);
        await controller.close();
      },
    );
  }

  Future<void> send({required Uri url, required String contents}) async {
    final endpoint = url.pathSegments.isEmpty
        ? url.replace(path: '/sync')
        : url.replace(path: '${url.path}/sync');
    final client = HttpClient();
    try {
      final request = await client.postUrl(endpoint);
      request.headers.contentType = ContentType.json;
      request.write(contents);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const HttpException('LAN sync receiver rejected the package.');
      }
    } finally {
      client.close(force: true);
    }
  }

  static Future<void> _handle(
    HttpRequest request,
    String token,
    StreamController<String> controller,
  ) async {
    _cors(request.response);
    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      return;
    }

    final segments = request.uri.pathSegments;
    if (segments.isEmpty || segments.first != token) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    if (request.method == 'GET') {
      request.response.headers.contentType = ContentType.html;
      request.response.write(_uploadPage(token));
      await request.response.close();
      return;
    }

    if (request.method == 'POST' &&
        segments.length == 2 &&
        segments[1] == 'sync') {
      final body = await utf8.decoder.bind(request).join();
      controller.add(body);
      request.response.headers.contentType = ContentType.text;
      request.response.write('ok');
      await request.response.close();
      return;
    }

    request.response.statusCode = HttpStatus.notFound;
    await request.response.close();
  }

  static void _cors(HttpResponse response) {
    response.headers
      ..set('Access-Control-Allow-Origin', '*')
      ..set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
      ..set('Access-Control-Allow-Headers', 'content-type')
      ..set('Access-Control-Allow-Private-Network', 'true');
  }

  static Future<String> _localAddress() async {
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.IPv4,
    );
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        if (!address.isLoopback) return address.address;
      }
    }
    return InternetAddress.loopbackIPv4.address;
  }

  static String _token() {
    final random = Random.secure();
    final bytes = List<int>.generate(12, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static String _uploadPage(String token) =>
      '''
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Memini Syncer</title>
  <style>
    body { font-family: system-ui, sans-serif; margin: 2rem; max-width: 38rem; }
    button, input { font: inherit; margin-top: 1rem; }
    .ok { color: #236b3a; }
    .error { color: #9b1c1c; }
  </style>
</head>
<body>
  <h1>Memini Syncer</h1>
  <p>Choose a Memini sync package from this device and send it over this WiFi network.</p>
  <input id="file" type="file" accept=".json,application/json">
  <br>
  <button id="send">Send to receiver</button>
  <p id="status"></p>
  <script>
    const status = document.getElementById('status');
    document.getElementById('send').onclick = async () => {
      const file = document.getElementById('file').files[0];
      if (!file) {
        status.textContent = 'Choose a sync package first.';
        status.className = 'error';
        return;
      }
      try {
        const body = await file.text();
        const response = await fetch('/$token/sync', {
          method: 'POST',
          headers: {'content-type': 'application/json'},
          body,
        });
        if (!response.ok) throw new Error('HTTP ' + response.status);
        status.textContent = 'Sent. Check the receiving device.';
        status.className = 'ok';
      } catch (error) {
        status.textContent = 'Could not send: ' + error;
        status.className = 'error';
      }
    };
  </script>
</body>
</html>
''';
}
