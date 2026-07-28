import 'package:drift/drift.dart';

import '../../../cards/data/local/card_database.dart';
import '../../domain/purchase_models.dart';

extension PurchaseDatabase on AppDatabase {
  Future<void> createPurchase({
    required CreatePurchaseRequest request,
    required DateTime now,
  }) {
    final normalized = request.normalized();
    return transaction(() async {
      final existing = await (select(
        purchases,
      )..where((row) => row.id.equals(normalized.id))).getSingleOrNull();
      if (existing != null) return;

      final targets = <({PurchaseTargetInput input, String name})>[];
      for (final input in normalized.targets) {
        targets.add((
          input: input,
          name: await _activePurchaseTargetName(input),
        ));
      }

      await into(purchases).insert(
        PurchasesCompanion.insert(
          id: normalized.id,
          purchasedAt: normalized.purchasedAt,
          amountMinor: normalized.amountMinor,
          currency: normalized.currency,
          shippingMinor: Value(normalized.shippingMinor),
          feesMinor: Value(normalized.feesMinor),
          channel: Value(normalized.channel),
          seller: Value(normalized.seller),
          notes: Value(normalized.notes),
          createdAt: now,
          updatedAt: now,
        ),
      );
      for (final target in targets) {
        await into(purchaseItems).insert(
          PurchaseItemsCompanion.insert(
            purchaseId: normalized.id,
            targetType: target.input.targetType,
            targetId: target.input.targetId,
            targetName: target.name,
            allocatedMinor: Value(target.input.allocatedMinor),
            createdAt: now,
          ),
        );
      }
    });
  }

  Future<void> createPurchaseAdjustment({
    required CreateAdjustmentRequest request,
    required DateTime now,
  }) {
    final normalized = request.normalized();
    return transaction(() async {
      final existing = await (select(
        purchases,
      )..where((row) => row.id.equals(normalized.id))).getSingleOrNull();
      if (existing != null) return;

      final original =
          await (select(purchases)
                ..where((row) => row.id.equals(normalized.adjustmentOfId))
                ..where((row) => row.adjustmentOfId.isNull()))
              .getSingleOrNull();
      if (original == null) {
        throw StateError('原购买记录不存在或不可调整。');
      }

      await into(purchases).insert(
        PurchasesCompanion.insert(
          id: normalized.id,
          purchasedAt: normalized.adjustedAt,
          amountMinor: -normalized.refundMinor,
          currency: original.currency,
          shippingMinor: const Value(0),
          feesMinor: const Value(0),
          notes: Value(normalized.notes),
          adjustmentOfId: Value(original.id),
          createdAt: now,
          updatedAt: now,
        ),
      );
    });
  }

  Stream<List<PurchaseRecord>> watchPurchaseRecords() {
    final query = select(purchases)
      ..orderBy(<OrderingTerm Function($PurchasesTable)>[
        (row) => OrderingTerm.desc(row.purchasedAt),
        (row) => OrderingTerm.desc(row.createdAt),
        (row) => OrderingTerm.desc(row.id),
      ]);
    return query.watch().asyncMap((purchaseRows) async {
      final itemRows = await select(purchaseItems).get();
      final groupedItems = <String, List<PurchaseItem>>{};
      for (final item in itemRows) {
        groupedItems
            .putIfAbsent(item.purchaseId, () => <PurchaseItem>[])
            .add(item);
      }
      return purchaseRows
          .map((purchase) {
            final sourceId = purchase.adjustmentOfId ?? purchase.id;
            final targets = groupedItems[sourceId] ?? const <PurchaseItem>[];
            return PurchaseRecord(
              id: purchase.id,
              purchasedAt: purchase.purchasedAt.toUtc(),
              amountMinor: purchase.amountMinor,
              currency: purchase.currency,
              shippingMinor: purchase.shippingMinor,
              feesMinor: purchase.feesMinor,
              channel: purchase.channel,
              seller: purchase.seller,
              notes: purchase.notes,
              adjustmentOfId: purchase.adjustmentOfId,
              createdAt: purchase.createdAt.toUtc(),
              targets: List<PurchaseTargetSnapshot>.unmodifiable(
                targets.map(
                  (item) => PurchaseTargetSnapshot(
                    targetType: item.targetType,
                    targetId: item.targetId,
                    targetName: item.targetName,
                    allocatedMinor: item.allocatedMinor,
                  ),
                ),
              ),
            );
          })
          .toList(growable: false);
    });
  }

  Stream<CostSummary> watchPurchaseCostSummary(CostDisplayOptions options) {
    return select(purchases).watch().map((rows) {
      final totals = <String, int>{};
      final counts = <String, int>{};
      for (final row in rows) {
        final total =
            row.amountMinor +
            (options.includeShipping ? row.shippingMinor : 0) +
            (options.includeFees ? row.feesMinor : 0);
        totals.update(
          row.currency,
          (current) => current + total,
          ifAbsent: () => total,
        );
        counts.update(
          row.currency,
          (current) => current + 1,
          ifAbsent: () => 1,
        );
      }
      final currencies = totals.keys.toList()..sort();
      return CostSummary(
        options: options,
        totals: List<CostTotal>.unmodifiable(
          currencies.map(
            (currency) => CostTotal(
              currency: currency,
              minorUnits: totals[currency]!,
              purchaseCount: counts[currency]!,
            ),
          ),
        ),
      );
    });
  }

  Stream<List<PurchaseTargetOption>> watchPurchaseTargetOptions() {
    return customSelect(
      '''
      SELECT 'card' AS target_type,
             ci.id AS target_id,
             cd.name AS target_name,
             0 AS type_order
        FROM card_items ci
        JOIN card_definitions cd ON cd.id = ci.definition_id
       WHERE ci.deleted_at IS NULL
         AND cd.deleted_at IS NULL
      UNION ALL
      SELECT 'cardSet' AS target_type,
             cs.id AS target_id,
             cs.name AS target_name,
             1 AS type_order
        FROM card_sets cs
       WHERE cs.deleted_at IS NULL
       ORDER BY type_order, target_name COLLATE NOCASE, target_id
      ''',
      readsFrom: <ResultSetImplementation<Table, Object?>>{
        cardItems,
        cardDefinitions,
        cardSets,
      },
    ).watch().map(
      (rows) => rows
          .map(
            (row) => PurchaseTargetOption(
              targetType: row.read<String>('target_type') == 'card'
                  ? PurchaseTargetType.card
                  : PurchaseTargetType.cardSet,
              targetId: row.read<String>('target_id'),
              targetName: row.read<String>('target_name'),
            ),
          )
          .toList(growable: false),
    );
  }

  Future<void> savePurchaseExchangeRate(ExchangeRateInput rate) {
    final normalized = rate.normalized();
    return into(exchangeRates).insertOnConflictUpdate(
      ExchangeRatesCompanion.insert(
        baseCurrency: normalized.baseCurrency,
        quoteCurrency: normalized.quoteCurrency,
        rateDate: normalized.rateDate,
        numerator: normalized.numerator,
        denominator: normalized.denominator,
        source: normalized.source,
        capturedAt: normalized.capturedAt,
      ),
    );
  }

  Future<String> _activePurchaseTargetName(PurchaseTargetInput input) async {
    switch (input.targetType) {
      case PurchaseTargetType.card:
        final query =
            select(cardItems).join(<Join<HasResultSet, dynamic>>[
                innerJoin(
                  cardDefinitions,
                  cardDefinitions.id.equalsExp(cardItems.definitionId),
                ),
              ])
              ..where(cardItems.id.equals(input.targetId))
              ..where(cardItems.deletedAt.isNull())
              ..where(cardDefinitions.deletedAt.isNull());
        final row = await query.getSingleOrNull();
        if (row == null) throw StateError('购买关联的卡片不存在。');
        return row.readTable(cardDefinitions).name;
      case PurchaseTargetType.cardSet:
        final row =
            await (select(cardSets)
                  ..where((set) => set.id.equals(input.targetId))
                  ..where((set) => set.deletedAt.isNull()))
                .getSingleOrNull();
        if (row == null) throw StateError('购买关联的套卡不存在。');
        return row.name;
    }
  }
}
