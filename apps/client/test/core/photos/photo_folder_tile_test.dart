import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memini/core/database/app_database.dart';
import 'package:memini/core/photos/domain/photo_folder.dart';
import 'package:memini/core/photos/presentation/photo_folder_providers.dart';
import 'package:memini/core/photos/presentation/photo_folder_tile.dart';

import '../../support/harness.dart';
import 'photo_folder_test.dart' show FakeFolder;

void main() {
  late AppDatabase db;
  late FakeFolder folder;

  setUp(() {
    db = memoryDatabase();
    folder = FakeFolder();
  });
  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      await harness(
        const Scaffold(body: PhotoFolderTile()),
        database: db,
        overrides: [photoFolderProvider.overrideWithValue(folder)],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('says photos stay inside the app until a folder is picked', (
    tester,
  ) async {
    await pump(tester);

    expect(
      find.text('Not chosen. Photos live inside the app only.'),
      findsOneWidget,
    );
    expect(find.text('Choose'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('names the folder once one is chosen', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Choose'));
    await tester.pumpAndSettle();

    expect(find.text('Copying every photo into Pictures.'), findsOneWidget);
    expect(find.text('Change'), findsOneWidget);
    expect(find.text('Stop copying'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a browser with no directory picker says why, and offers '
      'nothing', (tester) async {
    folder.isSupported = false;

    await pump(tester);

    expect(
      find.text(
        'This browser cannot write into a folder. Chrome and Edge can.',
      ),
      findsOneWidget,
    );
    expect(find.text('Choose'), findsNothing);
    await unmount(tester);
  });

  testWidgets('a folder that is gone is reported where it was chosen', (
    tester,
  ) async {
    folder
      ..name = 'Pictures'
      ..problem = PhotoFolderProblem.folderGone;

    await pump(tester);

    expect(
      find.text('That folder is not there any more. Choose it again.'),
      findsOneWidget,
    );
    await unmount(tester);
  });
}
