import 'package:drift/drift.dart';

import '../../../cards/data/local/card_database.dart';
import '../../../organization/domain/organization_models.dart';
import '../../../purchases/domain/purchase_models.dart';
import '../../domain/dashboard_models.dart';

extension DashboardDatabase on AppDatabase {
  Stream<HomeDashboard> watchHomeDashboard({
    required DateTime nowUtc,
    required CostDisplayOptions options,
  }) {
    return _dashboardSignal(this).asyncMap(
      (_) => _loadHomeDashboard(this, nowUtc: nowUtc, options: options),
    );
  }

  Stream<StatisticsSnapshot> watchStatisticsSnapshot(
    CostDisplayOptions options,
  ) {
    return _dashboardSignal(
      this,
    ).asyncMap((_) => _loadStatistics(this, options));
  }
}

Stream<List<QueryRow>> _dashboardSignal(AppDatabase db) {
  return db
      .customSelect(
        'SELECT 1 AS dashboard_signal',
        readsFrom: <ResultSetImplementation<Table, Object?>>{
          db.cardDefinitions,
          db.cardItems,
          db.cardImages,
          db.cardSets,
          db.cardSetMembers,
          db.seriesRecords,
          db.tags,
          db.cardTags,
          db.purchases,
          db.purchaseItems,
        },
      )
      .watch();
}

Future<HomeDashboard> _loadHomeDashboard(
  AppDatabase db, {
  required DateTime nowUtc,
  required CostDisplayOptions options,
}) async {
  final localNow = nowUtc.toLocal();
  final monthStartUtc = DateTime(localNow.year, localNow.month).toUtc();
  final nextMonthStartUtc = DateTime(localNow.year, localNow.month + 1).toUtc();
  final counts = await db
      .customSelect(
        '''
SELECT
  COALESCE(SUM(ci.quantity), 0) AS entity_count,
  COUNT(DISTINCT ci.definition_id) AS definition_count,
  COALESCE(SUM(
    CASE WHEN ci.created_at >= ? AND ci.created_at < ?
      THEN ci.quantity ELSE 0 END
  ), 0) AS month_added_count
FROM card_items ci
JOIN card_definitions cd ON cd.id = ci.definition_id
WHERE ci.deleted_at IS NULL
  AND cd.deleted_at IS NULL
''',
        variables: <Variable<Object>>[
          Variable<DateTime>(monthStartUtc),
          Variable<DateTime>(nextMonthStartUtc),
        ],
      )
      .getSingle();
  final cards = await _loadDashboardCards(db);
  final sets = await _loadDashboardSets(db);
  final seriesCount = await db
      .customSelect(
        'SELECT COUNT(*) AS series_count FROM series_records '
        'WHERE deleted_at IS NULL',
      )
      .getSingle()
      .then((row) => row.read<int>('series_count'));
  final costTotals = await _loadCostTotals(db, options);
  final recentCards = cards.take(10).toList(growable: false);
  final pendingCards = cards
      .where((card) => card.needsCompletion)
      .take(5)
      .toList(growable: false);
  final nearlyComplete =
      sets
          .where((set) => set.status == DashboardSetStatus.nearlyComplete)
          .toList(growable: false)
        ..sort((left, right) {
          final owned = right.ownedRequiredCount.compareTo(
            left.ownedRequiredCount,
          );
          if (owned != 0) return owned;
          final updated = right.updatedAt.compareTo(left.updatedAt);
          return updated != 0 ? updated : left.id.compareTo(right.id);
        });

  return HomeDashboard(
    entityCount: counts.read<int>('entity_count'),
    definitionCount: counts.read<int>('definition_count'),
    setCount: sets.length,
    seriesCount: seriesCount,
    completedSetCount: sets
        .where((set) => set.status == DashboardSetStatus.complete)
        .length,
    monthAddedCount: counts.read<int>('month_added_count'),
    costTotals: List<CostTotal>.unmodifiable(costTotals),
    recentCards: List<DashboardCard>.unmodifiable(recentCards),
    nearlyCompleteSets: List<DashboardSet>.unmodifiable(nearlyComplete.take(5)),
    needsCompletionCards: List<DashboardCard>.unmodifiable(pendingCards),
  );
}

Future<StatisticsSnapshot> _loadStatistics(
  AppDatabase db,
  CostDisplayOptions options,
) async {
  final distributions = <StatisticDimension, List<StatisticBucket>>{};
  for (final (dimension, expression) in <(StatisticDimension, String)>[
    (StatisticDimension.issuedYear, "SUBSTR(cd.issued_at, 1, 4)"),
    (StatisticDimension.issuer, 'cd.issuer'),
    (StatisticDimension.cardType, 'cd.card_type'),
  ]) {
    final rows = await db.customSelect('''
SELECT $expression AS bucket_key, SUM(ci.quantity) AS bucket_count
FROM card_items ci
JOIN card_definitions cd ON cd.id = ci.definition_id
WHERE ci.deleted_at IS NULL
  AND cd.deleted_at IS NULL
  AND $expression IS NOT NULL
  AND TRIM($expression) != ''
GROUP BY $expression
ORDER BY bucket_count DESC, bucket_key COLLATE NOCASE ASC
''').get();
    distributions[dimension] = List<StatisticBucket>.unmodifiable(
      rows.map(
        (row) => StatisticBucket.card(
          dimension: dimension,
          key: row.read<String>('bucket_key'),
          label: row.read<String>('bucket_key'),
          count: row.read<int>('bucket_count'),
        ),
      ),
    );
  }

  final cityRows = await db.customSelect('''
SELECT cd.city AS city, SUM(ci.quantity) AS bucket_count
FROM card_items ci
JOIN card_definitions cd ON cd.id = ci.definition_id
WHERE ci.deleted_at IS NULL
  AND cd.deleted_at IS NULL
  AND cd.city IS NOT NULL
  AND TRIM(cd.city) != ''
GROUP BY cd.city
''').get();
  final cityCounts = <String, int>{};
  for (final row in cityRows) {
    final city = cityFilterLevel(row.read<String>('city'));
    cityCounts.update(
      city,
      (count) => count + row.read<int>('bucket_count'),
      ifAbsent: () => row.read<int>('bucket_count'),
    );
  }
  final cityEntries = cityCounts.entries.toList()
    ..sort((left, right) {
      final count = right.value.compareTo(left.value);
      return count != 0 ? count : left.key.compareTo(right.key);
    });
  distributions[StatisticDimension.city] = List<StatisticBucket>.unmodifiable(
    cityEntries.map(
      (entry) => StatisticBucket.card(
        dimension: StatisticDimension.city,
        key: entry.key,
        label: entry.key,
        count: entry.value,
      ),
    ),
  );

  final tagRows = await db.customSelect('''
SELECT t.id AS bucket_key, t.name AS bucket_label,
       SUM(ci.quantity) AS bucket_count
FROM tags t
JOIN card_tags ct ON ct.tag_id = t.id
JOIN card_definitions cd ON cd.id = ct.definition_id
JOIN card_items ci ON ci.definition_id = cd.id
WHERE t.deleted_at IS NULL
  AND cd.deleted_at IS NULL
  AND ci.deleted_at IS NULL
GROUP BY t.id, t.name
ORDER BY bucket_count DESC, bucket_label COLLATE NOCASE ASC, bucket_key ASC
''').get();
  distributions[StatisticDimension.tag] = List<StatisticBucket>.unmodifiable(
    tagRows.map(
      (row) => StatisticBucket.card(
        dimension: StatisticDimension.tag,
        key: row.read<String>('bucket_key'),
        label: row.read<String>('bucket_label'),
        count: row.read<int>('bucket_count'),
      ),
    ),
  );

  final sets = await _loadDashboardSets(db);
  distributions[StatisticDimension.setStatus] =
      List<StatisticBucket>.unmodifiable([
        for (final status in DashboardSetStatus.values)
          if (sets.where((set) => set.status == status).isNotEmpty)
            StatisticBucket.setStatus(
              status: status,
              count: sets.where((set) => set.status == status).length,
            ),
      ]);

  return StatisticsSnapshot(
    distributions: Map<StatisticDimension, List<StatisticBucket>>.unmodifiable(
      distributions,
    ),
    costTrend: List<CostTrendPoint>.unmodifiable(
      await _loadCostTrend(db, options),
    ),
  );
}

Future<List<DashboardCard>> _loadDashboardCards(AppDatabase db) async {
  final rows = await db.customSelect('''
SELECT
  ci.id AS card_item_id,
  cd.id AS definition_id,
  cd.name AS name,
  ci.quantity AS quantity,
  ci.created_at AS created_at,
  cd.needs_completion AS needs_completion,
  (
    SELECT COALESCE(image.derived_relative_path, image.relative_path)
    FROM card_images image
    WHERE image.card_item_id = ci.id
      AND image.deleted_at IS NULL
    ORDER BY image.is_cover DESC, image.sort_order ASC, image.id ASC
    LIMIT 1
  ) AS cover_path
FROM card_items ci
JOIN card_definitions cd ON cd.id = ci.definition_id
WHERE ci.deleted_at IS NULL
  AND cd.deleted_at IS NULL
ORDER BY ci.created_at DESC, ci.id ASC
''').get();
  return rows
      .map(
        (row) => DashboardCard(
          cardItemId: row.read<String>('card_item_id'),
          definitionId: row.read<String>('definition_id'),
          name: row.read<String>('name'),
          quantity: row.read<int>('quantity'),
          createdAt: _timestamp(row.read<int>('created_at')),
          needsCompletion: row.read<int>('needs_completion') == 1,
          coverRelativePath: row.readNullable<String>('cover_path'),
        ),
      )
      .toList(growable: false);
}

Future<List<DashboardSet>> _loadDashboardSets(AppDatabase db) async {
  final rows = await db.customSelect('''
SELECT
  cs.id AS set_id,
  cs.name AS set_name,
  cs.count_known AS count_known,
  cs.expected_count AS expected_count,
  cs.updated_at AS updated_at,
  COUNT(CASE WHEN csm.required = 1 THEN 1 END) AS required_count,
  COALESCE(SUM(
    CASE WHEN csm.required = 1 AND EXISTS (
      SELECT 1
      FROM card_items owned_item
      JOIN card_definitions owned_definition
        ON owned_definition.id = owned_item.definition_id
      WHERE owned_item.definition_id = csm.definition_id
        AND owned_item.deleted_at IS NULL
        AND owned_definition.deleted_at IS NULL
    ) THEN 1 ELSE 0 END
  ), 0) AS owned_required_count,
  (
    SELECT COALESCE(image.derived_relative_path, image.relative_path)
    FROM card_images image
    WHERE image.id = cs.cover_image_id
      AND image.deleted_at IS NULL
    LIMIT 1
  ) AS cover_path
FROM card_sets cs
LEFT JOIN card_set_members csm
  ON csm.set_id = cs.id
  AND csm.deleted_at IS NULL
WHERE cs.deleted_at IS NULL
GROUP BY cs.id
ORDER BY cs.updated_at DESC, cs.id ASC
''').get();
  return rows
      .map((row) {
        final countKnown = row.read<int>('count_known') == 1;
        final requiredCount = countKnown
            ? row.readNullable<int>('expected_count') ?? 0
            : row.read<int>('required_count');
        final ownedCount = row.read<int>('owned_required_count');
        final status = !countKnown
            ? DashboardSetStatus.unknown
            : requiredCount > 0 && ownedCount == requiredCount
            ? DashboardSetStatus.complete
            : requiredCount > 0 && requiredCount - ownedCount == 1
            ? DashboardSetStatus.nearlyComplete
            : DashboardSetStatus.incomplete;
        return DashboardSet(
          id: row.read<String>('set_id'),
          name: row.read<String>('set_name'),
          status: status,
          ownedRequiredCount: ownedCount,
          requiredMemberCount: requiredCount,
          updatedAt: _timestamp(row.read<int>('updated_at')),
          coverRelativePath: row.readNullable<String>('cover_path'),
        );
      })
      .toList(growable: false);
}

Future<List<CostTotal>> _loadCostTotals(
  AppDatabase db,
  CostDisplayOptions options,
) async {
  final shipping = options.includeShipping ? 'p.shipping_minor' : '0';
  final fees = options.includeFees ? 'p.fees_minor' : '0';
  final rows = await db.customSelect('''
SELECT p.currency,
       COALESCE(SUM(p.amount_minor + $shipping + $fees), 0) AS total_minor,
       COUNT(*) AS purchase_count
FROM purchases p
WHERE $_activePurchasePredicate
GROUP BY p.currency
ORDER BY p.currency ASC
''').get();
  return rows
      .map(
        (row) => CostTotal(
          currency: row.read<String>('currency'),
          minorUnits: row.read<int>('total_minor'),
          purchaseCount: row.read<int>('purchase_count'),
        ),
      )
      .toList(growable: false);
}

Future<List<CostTrendPoint>> _loadCostTrend(
  AppDatabase db,
  CostDisplayOptions options,
) async {
  final rows = await db.customSelect('''
SELECT p.purchased_at,
       p.currency,
       p.amount_minor,
       p.shipping_minor,
       p.fees_minor
FROM purchases p
WHERE $_activePurchasePredicate
ORDER BY p.purchased_at ASC, p.currency ASC, p.id ASC
''').get();
  final totals = <(int, int, String), int>{};
  final counts = <(int, int, String), int>{};
  for (final row in rows) {
    final local = _timestamp(row.read<int>('purchased_at')).toLocal();
    final currency = row.read<String>('currency');
    final key = (local.year, local.month, currency);
    final amount =
        row.read<int>('amount_minor') +
        (options.includeShipping ? row.read<int>('shipping_minor') : 0) +
        (options.includeFees ? row.read<int>('fees_minor') : 0);
    totals.update(key, (current) => current + amount, ifAbsent: () => amount);
    counts.update(key, (current) => current + 1, ifAbsent: () => 1);
  }
  final keys = totals.keys.toList()
    ..sort((left, right) {
      final year = left.$1.compareTo(right.$1);
      if (year != 0) return year;
      final month = left.$2.compareTo(right.$2);
      return month != 0 ? month : left.$3.compareTo(right.$3);
    });
  return keys
      .map(
        (key) => CostTrendPoint(
          month: DateTime.utc(key.$1, key.$2),
          currency: key.$3,
          minorUnits: totals[key]!,
          purchaseCount: counts[key]!,
        ),
      )
      .toList(growable: false);
}

DateTime _timestamp(int seconds) =>
    DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);

const String _activePurchasePredicate = '''
EXISTS (
  SELECT 1
  FROM purchase_items pi
  WHERE pi.purchase_id = COALESCE(p.adjustment_of_id, p.id)
    AND (
      (
        pi.target_type = 'card'
        AND EXISTS (
          SELECT 1
          FROM card_items ci
          JOIN card_definitions cd ON cd.id = ci.definition_id
          WHERE ci.id = pi.target_id
            AND ci.deleted_at IS NULL
            AND cd.deleted_at IS NULL
        )
      )
      OR
      (
        pi.target_type = 'cardSet'
        AND EXISTS (
          SELECT 1
          FROM card_sets cs
          WHERE cs.id = pi.target_id
            AND cs.deleted_at IS NULL
        )
      )
    )
)
''';
