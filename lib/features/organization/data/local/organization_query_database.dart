import 'package:drift/drift.dart';

import '../../../cards/data/local/card_database.dart';
import '../../domain/organization_models.dart';

extension OrganizationQueryDatabase on AppDatabase {
  Stream<List<TagSummary>> watchOrganizationTags() {
    return customSelect(
      '''
SELECT
  t.id,
  t.name,
  t.created_at,
  t.updated_at,
  (
    SELECT COUNT(*)
    FROM card_tags ct
    JOIN card_definitions cd ON cd.id = ct.definition_id
    WHERE ct.tag_id = t.id
      AND cd.deleted_at IS NULL
      AND EXISTS (
        SELECT 1 FROM card_items active_ci
        WHERE active_ci.definition_id = cd.id
          AND active_ci.deleted_at IS NULL
      )
  ) AS card_count
FROM tags t
WHERE t.deleted_at IS NULL
ORDER BY t.updated_at DESC, t.id ASC
''',
      readsFrom: <ResultSetImplementation<Table, Object?>>{
        tags,
        cardTags,
        cardDefinitions,
        cardItems,
      },
    ).watch().map(
      (rows) => rows
          .map(
            (row) => TagSummary(
              id: row.read<String>('id'),
              name: row.read<String>('name'),
              cardCount: row.read<int>('card_count'),
              createdAt: _timestamp(row.read<int>('created_at')),
              updatedAt: _timestamp(row.read<int>('updated_at')),
            ),
          )
          .toList(growable: false),
    );
  }

  Stream<List<SeriesSummary>> watchOrganizationSeries() {
    return customSelect(
      '''
SELECT
  s.id,
  s.name,
  s.description,
  s.cover_relative_path,
  s.created_at,
  s.updated_at,
  (
    SELECT COUNT(*)
    FROM series_cards sc
    JOIN card_definitions cd ON cd.id = sc.definition_id
    WHERE sc.series_id = s.id
      AND cd.deleted_at IS NULL
      AND EXISTS (
        SELECT 1 FROM card_items active_ci
        WHERE active_ci.definition_id = cd.id
          AND active_ci.deleted_at IS NULL
      )
  ) AS card_count,
  (
    SELECT COUNT(*)
    FROM series_sets ss
    JOIN card_sets cs ON cs.id = ss.set_id
    WHERE ss.series_id = s.id AND cs.deleted_at IS NULL
  ) AS set_count
FROM series_records s
WHERE s.deleted_at IS NULL
ORDER BY s.updated_at DESC, s.id ASC
''',
      readsFrom: <ResultSetImplementation<Table, Object?>>{
        seriesRecords,
        seriesCards,
        seriesSets,
        cardDefinitions,
        cardItems,
        cardSets,
      },
    ).watch().map(
      (rows) => rows
          .map(
            (row) => SeriesSummary(
              id: row.read<String>('id'),
              name: row.read<String>('name'),
              description: row.readNullable<String>('description'),
              coverRelativePath: row.readNullable<String>(
                'cover_relative_path',
              ),
              cardCount: row.read<int>('card_count'),
              setCount: row.read<int>('set_count'),
              createdAt: _timestamp(row.read<int>('created_at')),
              updatedAt: _timestamp(row.read<int>('updated_at')),
            ),
          )
          .toList(growable: false),
    );
  }

  Stream<SeriesDetail?> watchOrganizationSeriesDetail(String seriesId) {
    return customSelect(
      'SELECT id FROM series_records '
      'WHERE id = ? AND deleted_at IS NULL',
      variables: <Variable<Object>>[Variable<String>(seriesId)],
      readsFrom: <ResultSetImplementation<Table, Object?>>{
        seriesRecords,
        seriesCards,
        seriesSets,
        cardDefinitions,
        cardItems,
        cardImages,
        cardSets,
      },
    ).watchSingleOrNull().asyncMap((row) async {
      if (row == null) return null;
      final series = await (select(
        seriesRecords,
      )..where((entry) => entry.id.equals(seriesId))).getSingle();
      final cards = await _seriesCards(this, seriesId);
      final sets = await _seriesSets(this, seriesId);
      final setGroups = <SeriesSetGroup>[];
      for (final set in sets) {
        setGroups.add(
          SeriesSetGroup(set: set, cards: await _seriesSetCards(this, set.id)),
        );
      }
      return SeriesDetail(
        id: series.id,
        name: series.name,
        description: series.description,
        coverRelativePath: series.coverRelativePath,
        createdAt: series.createdAt.toUtc(),
        updatedAt: series.updatedAt.toUtc(),
        cards: cards,
        sets: sets,
        setGroups: List<SeriesSetGroup>.unmodifiable(setGroups),
      );
    });
  }

  Stream<List<CustomFieldDefinition>> watchOrganizationFields() {
    return customSelect(
      '''
SELECT
  f.id,
  f.name,
  f.field_type,
  f.created_at,
  f.updated_at,
  (
    SELECT COUNT(*)
    FROM custom_field_values fv
    JOIN card_definitions cd ON cd.id = fv.definition_id
    WHERE fv.field_id = f.id
      AND cd.deleted_at IS NULL
      AND EXISTS (
        SELECT 1 FROM card_items active_ci
        WHERE active_ci.definition_id = cd.id
          AND active_ci.deleted_at IS NULL
      )
  ) AS value_count
FROM custom_field_definitions f
WHERE f.deleted_at IS NULL
ORDER BY f.updated_at DESC, f.id ASC
''',
      readsFrom: <ResultSetImplementation<Table, Object?>>{
        organizationFieldDefinitions,
        organizationFieldValues,
        cardDefinitions,
        cardItems,
      },
    ).watch().map(
      (rows) => rows
          .map(
            (row) => CustomFieldDefinition(
              id: row.read<String>('id'),
              name: row.read<String>('name'),
              fieldType: CustomFieldType.values.byName(
                row.read<String>('field_type'),
              ),
              valueCount: row.read<int>('value_count'),
              createdAt: _timestamp(row.read<int>('created_at')),
              updatedAt: _timestamp(row.read<int>('updated_at')),
            ),
          )
          .toList(growable: false),
    );
  }

  Stream<CardOrganizationDetail?> watchCardOrganizationDetail(
    String cardItemId,
  ) {
    return customSelect(
      '''
SELECT
  ci.id AS card_item_id,
  cd.id AS definition_id,
  cd.name AS name,
  cd.card_type AS card_type,
  cd.needs_completion AS needs_completion,
  ci.acquired_at AS acquired_at
FROM card_items ci
JOIN card_definitions cd ON cd.id = ci.definition_id
WHERE ci.id = ?
  AND ci.deleted_at IS NULL
  AND cd.deleted_at IS NULL
''',
      variables: <Variable<Object>>[Variable<String>(cardItemId)],
      readsFrom: <ResultSetImplementation<Table, Object?>>{
        cardItems,
        cardDefinitions,
        tags,
        cardTags,
        seriesRecords,
        seriesCards,
        organizationFieldDefinitions,
        organizationFieldValues,
      },
    ).watchSingleOrNull().asyncMap((row) async {
      if (row == null) return null;
      final definitionId = row.read<String>('definition_id');
      final tagsResult = await _cardTags(this, definitionId);
      final seriesResult = await _cardSeries(this, definitionId);
      final values = await _cardFieldValues(this, definitionId);
      return CardOrganizationDetail(
        cardItemId: row.read<String>('card_item_id'),
        definitionId: definitionId,
        name: row.read<String>('name'),
        cardType: row.readNullable<String>('card_type'),
        needsCompletion: row.read<int>('needs_completion') == 1,
        acquiredAt: _nullableTimestamp(row.readNullable<int>('acquired_at')),
        tags: tagsResult,
        series: seriesResult,
        fieldValues: values,
      );
    });
  }

  Stream<CardFilterFacets> watchOrganizationFacets() {
    return customSelect(
      '''
SELECT
  'card_type' AS kind,
  card_type AS value,
  NULL AS id,
  0 AS card_count,
  0 AS created_at,
  0 AS updated_at
FROM card_definitions
WHERE deleted_at IS NULL
  AND card_type IS NOT NULL
  AND card_type <> ''
  AND EXISTS (
    SELECT 1 FROM card_items ci
    WHERE ci.definition_id = card_definitions.id
      AND ci.deleted_at IS NULL
  )
GROUP BY card_type
UNION ALL
SELECT 'city', city, NULL, 0, 0, 0
FROM card_definitions
WHERE deleted_at IS NULL
  AND city IS NOT NULL
  AND city <> ''
  AND EXISTS (
    SELECT 1 FROM card_items ci
    WHERE ci.definition_id = card_definitions.id
      AND ci.deleted_at IS NULL
  )
GROUP BY city
UNION ALL
SELECT 'year', substr(issued_at, 1, 4), NULL, 0, 0, 0
FROM card_definitions
WHERE deleted_at IS NULL
  AND issued_at IS NOT NULL
  AND length(issued_at) >= 4
  AND EXISTS (
    SELECT 1 FROM card_items ci
    WHERE ci.definition_id = card_definitions.id
      AND ci.deleted_at IS NULL
  )
GROUP BY substr(issued_at, 1, 4)
UNION ALL
SELECT
  'tag',
  t.name,
  t.id,
  COUNT(DISTINCT cd.id),
  t.created_at,
  t.updated_at
FROM tags t
JOIN card_tags ct ON ct.tag_id = t.id
JOIN card_definitions cd
  ON cd.id = ct.definition_id AND cd.deleted_at IS NULL
WHERE t.deleted_at IS NULL
  AND EXISTS (
    SELECT 1 FROM card_items ci
    WHERE ci.definition_id = cd.id
      AND ci.deleted_at IS NULL
  )
GROUP BY t.id
''',
      readsFrom: <ResultSetImplementation<Table, Object?>>{
        cardDefinitions,
        cardItems,
        tags,
        cardTags,
      },
    ).watch().map((rows) {
      final cardTypes = <String>{};
      final cities = <String>{};
      final years = <int>{};
      final tagRows = <TagSummary>[];
      for (final row in rows) {
        final kind = row.read<String>('kind');
        final value = row.read<String>('value');
        switch (kind) {
          case 'card_type':
            cardTypes.add(value);
          case 'city':
            cities.add(cityFilterLevel(value));
          case 'year':
            final year = int.tryParse(value);
            if (year != null) years.add(year);
          case 'tag':
            tagRows.add(
              TagSummary(
                id: row.read<String>('id'),
                name: value,
                cardCount: row.read<int>('card_count'),
                createdAt: _timestamp(row.read<int>('created_at')),
                updatedAt: _timestamp(row.read<int>('updated_at')),
              ),
            );
        }
      }
      tagRows.sort((left, right) {
        final updated = right.updatedAt.compareTo(left.updatedAt);
        return updated != 0 ? updated : left.id.compareTo(right.id);
      });
      return CardFilterFacets(
        cardTypes: cardTypes.toList()..sort(),
        cities: cities.toList()..sort(),
        years: years.toList()..sort((left, right) => right.compareTo(left)),
        tags: tagRows,
      );
    });
  }
}

Future<List<SeriesMemberSummary>> _seriesCards(
  AppDatabase db,
  String seriesId,
) async {
  final rows = await db
      .customSelect(
        '''
SELECT
  cd.id,
  cd.name,
  (
    SELECT ci.id
    FROM card_items ci
    WHERE ci.definition_id = cd.id
      AND ci.deleted_at IS NULL
    ORDER BY ci.created_at ASC, ci.id ASC
    LIMIT 1
  ) AS card_item_id,
  (
    SELECT COALESCE(ci_cover.derived_relative_path, ci_cover.relative_path)
    FROM card_items ci
    JOIN card_images ci_cover ON ci_cover.card_item_id = ci.id
    WHERE ci.definition_id = cd.id
      AND ci.deleted_at IS NULL
      AND ci_cover.deleted_at IS NULL
    ORDER BY ci_cover.is_cover DESC, ci_cover.sort_order ASC, ci_cover.id ASC
    LIMIT 1
  ) AS cover_path
FROM series_cards sc
JOIN card_definitions cd ON cd.id = sc.definition_id
WHERE sc.series_id = ?
  AND cd.deleted_at IS NULL
  AND EXISTS (
    SELECT 1 FROM card_items active_ci
    WHERE active_ci.definition_id = cd.id
      AND active_ci.deleted_at IS NULL
  )
ORDER BY cd.name COLLATE NOCASE ASC, cd.id ASC
''',
        variables: <Variable<Object>>[Variable<String>(seriesId)],
      )
      .get();
  return rows
      .map(
        (row) => SeriesMemberSummary(
          id: row.read<String>('id'),
          name: row.read<String>('name'),
          cardItemId: row.readNullable<String>('card_item_id'),
          coverRelativePath: row.readNullable<String>('cover_path'),
        ),
      )
      .toList(growable: false);
}

Future<List<SeriesMemberSummary>> _seriesSets(
  AppDatabase db,
  String seriesId,
) async {
  final rows = await db
      .customSelect(
        '''
SELECT
  cs.id,
  cs.name,
  COALESCE(
    cs.cover_relative_path,
    cover.derived_relative_path,
    cover.relative_path
  ) AS cover_path
FROM series_sets ss
JOIN card_sets cs ON cs.id = ss.set_id
LEFT JOIN card_images cover
  ON cover.id = cs.cover_image_id AND cover.deleted_at IS NULL
WHERE ss.series_id = ? AND cs.deleted_at IS NULL
ORDER BY cs.name COLLATE NOCASE ASC, cs.id ASC
''',
        variables: <Variable<Object>>[Variable<String>(seriesId)],
      )
      .get();
  return rows
      .map(
        (row) => SeriesMemberSummary(
          id: row.read<String>('id'),
          name: row.read<String>('name'),
          coverRelativePath: row.readNullable<String>('cover_path'),
        ),
      )
      .toList(growable: false);
}

Future<List<SeriesMemberSummary>> _seriesSetCards(
  AppDatabase db,
  String setId,
) async {
  final rows = await db
      .customSelect(
        '''
SELECT
  cd.id,
  cd.name,
  (
    SELECT ci.id
    FROM card_items ci
    WHERE ci.definition_id = cd.id
      AND ci.deleted_at IS NULL
    ORDER BY ci.created_at ASC, ci.id ASC
    LIMIT 1
  ) AS card_item_id,
  (
    SELECT COALESCE(image.derived_relative_path, image.relative_path)
    FROM card_items ci
    JOIN card_images image ON image.card_item_id = ci.id
    WHERE ci.definition_id = cd.id
      AND ci.deleted_at IS NULL
      AND image.deleted_at IS NULL
    ORDER BY image.is_cover DESC, image.sort_order ASC, image.id ASC
    LIMIT 1
  ) AS cover_path
FROM card_set_members csm
JOIN card_definitions cd ON cd.id = csm.definition_id
WHERE csm.set_id = ?
  AND csm.deleted_at IS NULL
  AND cd.deleted_at IS NULL
  AND EXISTS (
    SELECT 1 FROM card_items active_ci
    WHERE active_ci.definition_id = cd.id
      AND active_ci.deleted_at IS NULL
  )
ORDER BY csm.sort_order ASC, csm.id ASC
''',
        variables: <Variable<Object>>[Variable<String>(setId)],
      )
      .get();
  return rows
      .map(
        (row) => SeriesMemberSummary(
          id: row.read<String>('id'),
          name: row.read<String>('name'),
          cardItemId: row.readNullable<String>('card_item_id'),
          coverRelativePath: row.readNullable<String>('cover_path'),
        ),
      )
      .toList(growable: false);
}

Future<List<TagSummary>> _cardTags(AppDatabase db, String definitionId) async {
  final rows = await db
      .customSelect(
        '''
SELECT t.id, t.name, t.created_at, t.updated_at
FROM card_tags ct
JOIN tags t ON t.id = ct.tag_id
WHERE ct.definition_id = ? AND t.deleted_at IS NULL
ORDER BY t.updated_at DESC, t.id ASC
''',
        variables: <Variable<Object>>[Variable<String>(definitionId)],
      )
      .get();
  return rows
      .map(
        (row) => TagSummary(
          id: row.read<String>('id'),
          name: row.read<String>('name'),
          cardCount: 0,
          createdAt: _timestamp(row.read<int>('created_at')),
          updatedAt: _timestamp(row.read<int>('updated_at')),
        ),
      )
      .toList(growable: false);
}

Future<List<SeriesSummary>> _cardSeries(
  AppDatabase db,
  String definitionId,
) async {
  final rows = await db
      .customSelect(
        '''
SELECT s.id, s.name, s.description, s.cover_relative_path,
       s.created_at, s.updated_at
FROM series_cards sc
JOIN series_records s ON s.id = sc.series_id
WHERE sc.definition_id = ? AND s.deleted_at IS NULL
ORDER BY s.updated_at DESC, s.id ASC
''',
        variables: <Variable<Object>>[Variable<String>(definitionId)],
      )
      .get();
  return rows
      .map(
        (row) => SeriesSummary(
          id: row.read<String>('id'),
          name: row.read<String>('name'),
          description: row.readNullable<String>('description'),
          coverRelativePath: row.readNullable<String>('cover_relative_path'),
          cardCount: 0,
          setCount: 0,
          createdAt: _timestamp(row.read<int>('created_at')),
          updatedAt: _timestamp(row.read<int>('updated_at')),
        ),
      )
      .toList(growable: false);
}

Future<List<CustomFieldValueDetail>> _cardFieldValues(
  AppDatabase db,
  String definitionId,
) async {
  final query =
      db.select(db.organizationFieldValues).join(<Join<HasResultSet, dynamic>>[
        innerJoin(
          db.organizationFieldDefinitions,
          db.organizationFieldDefinitions.id.equalsExp(
                db.organizationFieldValues.fieldId,
              ) &
              db.organizationFieldDefinitions.deletedAt.isNull(),
        ),
      ])..where(db.organizationFieldValues.definitionId.equals(definitionId));
  final rows = await query.get();
  return rows
      .map((row) {
        final definition = row.readTable(db.organizationFieldDefinitions);
        final value = row.readTable(db.organizationFieldValues);
        final input = switch (definition.fieldType) {
          CustomFieldType.text => CustomFieldValueInput.text(
            fieldId: definition.id,
            value: value.textValue!,
            isNormalized: true,
          ),
          CustomFieldType.number => CustomFieldValueInput.number(
            fieldId: definition.id,
            value: value.numberValue!,
            isNormalized: true,
          ),
          CustomFieldType.date => CustomFieldValueInput.date(
            fieldId: definition.id,
            value: value.dateValue!.toUtc(),
            isNormalized: true,
          ),
        };
        return CustomFieldValueDetail(
          fieldId: definition.id,
          fieldName: definition.name,
          value: input,
        );
      })
      .toList(growable: false);
}

DateTime _timestamp(int seconds) =>
    DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);

DateTime? _nullableTimestamp(int? seconds) =>
    seconds == null ? null : _timestamp(seconds);
