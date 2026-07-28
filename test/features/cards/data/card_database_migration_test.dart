import 'dart:io';

import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('schema v1 image becomes the active cover after migration', () async {
    final directory = await Directory.systemTemp.createTemp(
      'cardfolio-migration-',
    );
    addTearDown(() async {
      if (directory.existsSync()) await directory.delete(recursive: true);
    });
    final file = File(p.join(directory.path, 'cardfolio.sqlite'));

    final sqlite = sqlite3.open(file.path);
    sqlite
      ..execute('''
        CREATE TABLE card_definitions (
          id TEXT NOT NULL PRIMARY KEY,
          name TEXT NOT NULL,
          city TEXT,
          issuer TEXT,
          issued_at TEXT,
          code TEXT,
          notes TEXT,
          version INTEGER NOT NULL DEFAULT 1,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          deleted_at INTEGER
        );
      ''')
      ..execute('''
        CREATE TABLE card_items (
          id TEXT NOT NULL PRIMARY KEY,
          definition_id TEXT NOT NULL REFERENCES card_definitions(id),
          quantity INTEGER NOT NULL DEFAULT 1,
          version INTEGER NOT NULL DEFAULT 1,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          deleted_at INTEGER
        );
      ''')
      ..execute('''
        CREATE TABLE card_images (
          id TEXT NOT NULL PRIMARY KEY,
          card_item_id TEXT NOT NULL REFERENCES card_items(id),
          kind TEXT NOT NULL,
          relative_path TEXT NOT NULL UNIQUE,
          sort_order INTEGER NOT NULL DEFAULT 0,
          checksum TEXT NOT NULL,
          created_at INTEGER NOT NULL
        );
      ''')
      ..execute(
        "INSERT INTO card_definitions "
        "(id, name, created_at, updated_at) "
        "VALUES ('definition-1', '樱花纪念卡', 1, 1);",
      )
      ..execute(
        "INSERT INTO card_items "
        "(id, definition_id, created_at, updated_at) "
        "VALUES ('item-1', 'definition-1', 1, 1);",
      )
      ..execute(
        "INSERT INTO card_images "
        "(id, card_item_id, kind, relative_path, checksum, created_at) "
        "VALUES "
        "('image-1', 'item-1', 'front', 'originals/item-1/image-1.jpg', "
        "'sha256-abc', 1);",
      )
      ..execute('PRAGMA user_version = 1;')
      ..close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final detail = await db.watchCardDetail('item-1').first;
    final version = await db.customSelect('PRAGMA user_version;').getSingle();

    expect(version.data.values.single, 4);
    expect(detail!.images.single.id, 'image-1');
    expect(detail.images.single.isCover, isTrue);
    expect(detail.cover?.id, 'image-1');
    expect(detail.images.single.derivedRelativePath, isNull);
  });
}
