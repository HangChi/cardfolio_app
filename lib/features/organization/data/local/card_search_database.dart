import 'package:drift/drift.dart';

import '../../../cards/data/local/card_database.dart';
import '../../../cards/domain/card_models.dart';
import '../../domain/organization_models.dart';

extension CardSearchDatabase on AppDatabase {
  Stream<List<OrganizedCardSummary>> watchOrganizedCards(
    CardLibraryQuery query,
  ) {
    final normalized = query.normalized();
    final where = <String>['ci.deleted_at IS NULL', 'cd.deleted_at IS NULL'];
    final variables = <Variable<Object>>[];

    final searchText = normalized.searchText;
    if (searchText != null) {
      final pattern = '%${_escapeLike(searchText.toLowerCase())}%';
      where.add(
        '('
        "LOWER(cd.name) LIKE ? ESCAPE '\\' OR "
        "LOWER(COALESCE(cd.code, '')) LIKE ? ESCAPE '\\' OR "
        "LOWER(COALESCE(cd.city, '')) LIKE ? ESCAPE '\\' OR "
        "LOWER(COALESCE(cd.issuer, '')) LIKE ? ESCAPE '\\' OR "
        "LOWER(COALESCE(cd.notes, '')) LIKE ? ESCAPE '\\' OR "
        'EXISTS ('
        'SELECT 1 FROM card_tags search_ct '
        'JOIN tags search_t ON search_t.id = search_ct.tag_id '
        'WHERE search_ct.definition_id = cd.id '
        'AND search_t.deleted_at IS NULL '
        "AND LOWER(search_t.name) LIKE ? ESCAPE '\\'"
        '))',
      );
      for (var index = 0; index < 6; index++) {
        variables.add(Variable<String>(pattern));
      }
    }

    final cardType = normalized.cardType;
    if (cardType != null) {
      where.add('LOWER(cd.card_type) = LOWER(?)');
      variables.add(Variable<String>(cardType));
    }
    final city = normalized.city;
    if (city != null) {
      where.add('LOWER(cd.city) = LOWER(?)');
      variables.add(Variable<String>(city));
    }
    final year = normalized.year;
    if (year != null) {
      where.add('SUBSTR(cd.issued_at, 1, 4) = ?');
      variables.add(Variable<String>(year.toString()));
    }

    final tagIds = normalized.tagIds;
    if (tagIds.isNotEmpty) {
      final placeholders = List<String>.filled(tagIds.length, '?').join(', ');
      if (normalized.tagMatchMode == TagMatchMode.any) {
        where.add(
          'EXISTS ('
          'SELECT 1 FROM card_tags filter_ct '
          'JOIN tags filter_t ON filter_t.id = filter_ct.tag_id '
          'WHERE filter_ct.definition_id = cd.id '
          'AND filter_t.deleted_at IS NULL '
          'AND filter_ct.tag_id IN ($placeholders)'
          ')',
        );
      } else {
        where.add(
          '('
          'SELECT COUNT(DISTINCT filter_ct.tag_id) '
          'FROM card_tags filter_ct '
          'JOIN tags filter_t ON filter_t.id = filter_ct.tag_id '
          'WHERE filter_ct.definition_id = cd.id '
          'AND filter_t.deleted_at IS NULL '
          'AND filter_ct.tag_id IN ($placeholders)'
          ') = ${tagIds.length}',
        );
      }
      variables.addAll(tagIds.map(Variable<String>.new));
    }

    switch (normalized.setMembership) {
      case SetMembershipFilter.any:
        break;
      case SetMembershipFilter.inSet:
        where.add(_setMembershipSql);
      case SetMembershipFilter.notInSet:
        where.add('NOT $_setMembershipSql');
    }

    final duplicate = normalized.duplicate;
    if (duplicate != null) {
      final comparison = duplicate ? '>' : '<=';
      where.add(
        'COALESCE(('
        'SELECT SUM(duplicate_ci.quantity) FROM card_items duplicate_ci '
        'WHERE duplicate_ci.definition_id = cd.id '
        'AND duplicate_ci.deleted_at IS NULL'
        '), 0) $comparison 1',
      );
    }

    final needsCompletion = normalized.needsCompletion;
    if (needsCompletion != null) {
      where.add('cd.needs_completion = ?');
      variables.add(Variable<int>(needsCompletion ? 1 : 0));
    }

    final sql =
        '''
SELECT
  ci.id AS card_item_id,
  cd.id AS definition_id,
  cd.name AS name,
  ci.quantity AS quantity,
  ci.created_at AS created_at,
  cd.needs_completion AS needs_completion,
  cd.city AS city,
  cd.issued_at AS issued_at,
  ci.acquired_at AS acquired_at,
  cd.card_type AS card_type,
  (
    SELECT COALESCE(cover.derived_relative_path, cover.relative_path)
    FROM card_images cover
    WHERE cover.card_item_id = ci.id
      AND cover.deleted_at IS NULL
    ORDER BY cover.is_cover DESC, cover.sort_order ASC, cover.id ASC
    LIMIT 1
  ) AS cover_path,
  (
    SELECT GROUP_CONCAT(tag_rows.id, CHAR(31))
    FROM (
      SELECT active_t.id AS id
      FROM card_tags active_ct
      JOIN tags active_t ON active_t.id = active_ct.tag_id
      WHERE active_ct.definition_id = cd.id
        AND active_t.deleted_at IS NULL
      ORDER BY active_t.updated_at DESC, active_t.id ASC
    ) tag_rows
  ) AS tag_ids,
  (
    SELECT GROUP_CONCAT(tag_rows.name, CHAR(31))
    FROM (
      SELECT active_t.name AS name
      FROM card_tags active_ct
      JOIN tags active_t ON active_t.id = active_ct.tag_id
      WHERE active_ct.definition_id = cd.id
        AND active_t.deleted_at IS NULL
      ORDER BY active_t.updated_at DESC, active_t.id ASC
    ) tag_rows
  ) AS tag_names
FROM card_items ci
JOIN card_definitions cd ON cd.id = ci.definition_id
WHERE ${where.join('\n  AND ')}
ORDER BY ${_orderSql(normalized)}
''';

    return customSelect(
      sql,
      variables: variables,
      readsFrom: <ResultSetImplementation<Table, Object?>>{
        cardItems,
        cardDefinitions,
        cardImages,
        tags,
        cardTags,
        cardSets,
        cardSetMembers,
      },
    ).watch().map(
      (rows) => rows.map(_mapOrganizedCard).toList(growable: false),
    );
  }
}

const String _setMembershipSql =
    'EXISTS ('
    'SELECT 1 FROM card_set_members membership '
    'JOIN card_sets membership_set ON membership_set.id = membership.set_id '
    'WHERE membership.definition_id = cd.id '
    'AND membership.deleted_at IS NULL '
    'AND membership_set.deleted_at IS NULL'
    ')';

String _orderSql(CardLibraryQuery query) {
  final direction = query.sortDirection == SortDirection.ascending
      ? 'ASC'
      : 'DESC';
  final primary = switch (query.sortField) {
    CardSortField.createdAt => 'ci.created_at $direction',
    CardSortField.issuedAt =>
      "CASE WHEN cd.issued_at IS NULL OR cd.issued_at = '' THEN 1 ELSE 0 END "
          'ASC, cd.issued_at $direction',
    CardSortField.acquiredAt =>
      'CASE WHEN ci.acquired_at IS NULL THEN 1 ELSE 0 END ASC, '
          'ci.acquired_at $direction',
    CardSortField.name => 'cd.name COLLATE NOCASE $direction',
  };
  return '$primary, ci.id ASC';
}

OrganizedCardSummary _mapOrganizedCard(QueryRow row) {
  final tagIds = _splitTags(row.readNullable<String>('tag_ids'));
  final tagNames = _splitTags(row.readNullable<String>('tag_names'));
  final tags = <OrganizationLabel>[
    for (var index = 0; index < tagIds.length; index++)
      OrganizationLabel(
        id: tagIds[index],
        name: index < tagNames.length ? tagNames[index] : tagIds[index],
      ),
  ];
  return OrganizedCardSummary(
    cardItemId: row.read<String>('card_item_id'),
    definitionId: row.read<String>('definition_id'),
    name: row.read<String>('name'),
    quantity: row.read<int>('quantity'),
    createdAt: _timestamp(row.read<int>('created_at')),
    needsCompletion: row.read<int>('needs_completion') == 1,
    tags: List<OrganizationLabel>.unmodifiable(tags),
    coverRelativePath: row.readNullable<String>('cover_path'),
    city: row.readNullable<String>('city'),
    issuedAt: PartialDate.tryParse(row.readNullable<String>('issued_at')),
    acquiredAt: _nullableTimestamp(row.readNullable<int>('acquired_at')),
    cardType: row.readNullable<String>('card_type'),
  );
}

DateTime _timestamp(int seconds) =>
    DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);

DateTime? _nullableTimestamp(int? seconds) =>
    seconds == null ? null : _timestamp(seconds);

List<String> _splitTags(String? value) {
  if (value == null || value.isEmpty) return const <String>[];
  return value.split(String.fromCharCode(31));
}

String _escapeLike(String value) =>
    value.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');
