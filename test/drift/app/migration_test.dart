// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test('v2 card data survives the v3 card-set migration', () async {
    final schema = await verifier.schemaAt(2);
    final oldDb = v2.DatabaseAtV2(schema.newConnection());
    final createdAt =
        DateTime.utc(2026, 7, 27).millisecondsSinceEpoch ~/
        Duration.millisecondsPerSecond;
    await oldDb
        .into(oldDb.cardDefinitions)
        .insert(
          v2.CardDefinitionsCompanion.insert(
            id: 'definition-1',
            name: '樱花纪念卡',
            createdAt: createdAt,
            updatedAt: createdAt,
          ),
        );
    await oldDb
        .into(oldDb.cardItems)
        .insert(
          v2.CardItemsCompanion.insert(
            id: 'item-1',
            definitionId: 'definition-1',
            createdAt: createdAt,
            updatedAt: createdAt,
          ),
        );
    await oldDb
        .into(oldDb.cardImages)
        .insert(
          v2.CardImagesCompanion.insert(
            id: 'image-1',
            cardItemId: 'item-1',
            kind: 'front',
            relativePath: 'originals/item-1/image-1.jpg',
            isCover: const Value(1),
            checksum: 'sha256-abc',
            createdAt: createdAt,
          ),
        );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);

    final card = await db.watchCardDetail('item-1').first;
    expect(card?.name, '樱花纪念卡');
    expect(card?.cover?.id, 'image-1');
    expect(await db.select(db.cardSets).get(), isEmpty);
    await db.close();
  });
}
