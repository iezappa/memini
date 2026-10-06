import 'dart:io';

import 'package:args/args.dart';
import 'package:memini_server/src/database.dart';
import 'package:memini_server/src/server.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('host', defaultsTo: Platform.environment['HOST'] ?? '0.0.0.0')
    ..addOption('port', defaultsTo: Platform.environment['PORT'] ?? '8080')
    ..addOption(
      'data-dir',
      defaultsTo: Platform.environment['DATA_DIR'] ?? '/app/data',
    )
    ..addOption(
      'public-dir',
      defaultsTo: Platform.environment['PUBLIC_DIR'] ?? '/app/public',
    );
  final options = parser.parse(arguments);

  final dataDir = Directory(options['data-dir'] as String)
    ..createSync(recursive: true);
  final db = ServerDatabase(dataDir.path);

  final adminUser = Platform.environment['MEMINI_ADMIN_USER'];
  final adminPassword = Platform.environment['MEMINI_ADMIN_PASSWORD'];
  if (adminUser != null && adminPassword != null) {
    db.ensureBootstrapUser(username: adminUser, password: adminPassword);
  } else if (!db.hasUsers) {
    stderr.writeln(
      'No users exist. Set MEMINI_ADMIN_USER and MEMINI_ADMIN_PASSWORD on first start.',
    );
  }

  final server = await shelf_io.serve(
    MeminiServer(db, publicDir: options['public-dir'] as String).handler,
    options['host'] as String,
    int.parse(options['port'] as String),
  );
  print(
    'Memini server listening on http://${server.address.host}:${server.port}',
  );
}
