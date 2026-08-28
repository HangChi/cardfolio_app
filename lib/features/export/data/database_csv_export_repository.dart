import 'package:drift/drift.dart';

import '../../cards/data/local/card_database.dart';
import '../../cards/domain/reserved_card_metadata.dart';
import '../../purchases/domain/purchase_models.dart';
import '../domain/csv_export.dart';
import '../domain/csv_export_repository.dart';

final class DatabaseCsvExportRepository implements CsvExportRepository {
  const DatabaseCsvExportRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<CardCsvRow>> loadRows() => _database.transaction(_loadRows);

  Future<List<CardCsvRow>> _loadRows() async {
    final cards = await _loadCards();
    final tags = await _loadTags();
    final series = await _loadSeries();
    final sets = await _loadSets();
    final metadata = await _loadReservedMetadata();
    final costs = await _loadCosts();

    return cards
        .map((row) {
          final item = row.readTable(_database.cardItems);
          final definition = row.readTable(_database.cardDefinitions);
          final reserved = metadata[definition.id];
          final cost = costs[item.id];
          return CardCsvRow(
            name: definition.name,
            city: definition.city,
            issuer: definition.issuer,
            issuedAt: definition.issuedAt,
            code: definition.code,
            quantity: item.quantity,
            condition: reserved?.condition,
            itemNotes: reserved?.itemNotes,
            issueQuantity: reserved?.issueQuantity,
            issuePrice: reserved?.issuePrice?.toStringAsFixed(2),
            cardType: definition.cardType,
            acquiredAt: item.acquiredAt == null
                ? null
                : _date(item.acquiredAt!),
            tags: tags[definition.id] ?? const <String>[],
            albums: series[definition.id] ?? const <String>[],
            cardSets: sets[definition.id] ?? const <String>[],
            amount: _money(cost?.amountMinor ?? 0),
            shipping: _money(cost?.shippingMinor ?? 0),
            notes: definition.notes,
          );
        })
        .toList(growable: false);
  }

  Future<List<TypedResult>> _loadCards() {
    final query =
        _database.select(_database.cardItems).join(<Join>[
            innerJoin(
              _database.cardDefinitions,
              _database.cardDefinitions.id.equalsExp(
                _database.cardItems.definitionId,
              ),
            ),
          ])
          ..where(
            _database.cardItems.deletedAt.isNull() &
                _database.cardDefinitions.deletedAt.isNull(),
          )
          ..orderBy(<OrderingTerm>[
            OrderingTerm.desc(_database.cardItems.createdAt),
            OrderingTerm.asc(_database.cardItems.id),
          ]);
    return query.get();
  }

  Future<Map<String, List<String>>> _loadTags() async {
    final query =
        _database.select(_database.cardTags).join(<Join>[
            innerJoin(
              _database.tags,
              _database.tags.id.equalsExp(_database.cardTags.tagId),
            ),
          ])
          ..where(_database.tags.deletedAt.isNull())
          ..orderBy(<OrderingTerm>[
            OrderingTerm.desc(_database.tags.updatedAt),
            OrderingTerm.asc(_database.tags.id),
          ]);
    final rows = await query.get();
    return _groupNames(
      rows,
      key: (row) => row.readTable(_database.cardTags).definitionId,
      name: (row) => row.readTable(_database.tags).name,
    );
  }

  Future<Map<String, List<String>>> _loadSeries() async {
    final query =
        _database.select(_database.seriesCards).join(<Join>[
            innerJoin(
              _database.seriesRecords,
              _database.seriesRecords.id.equalsExp(
                _database.seriesCards.seriesId,
              ),
            ),
          ])
          ..where(_database.seriesRecords.deletedAt.isNull())
          ..orderBy(<OrderingTerm>[
            OrderingTerm.desc(_database.seriesRecords.updatedAt),
            OrderingTerm.asc(_database.seriesRecords.id),
          ]);
    final rows = await query.get();
    return _groupNames(
      rows,
      key: (row) => row.readTable(_database.seriesCards).definitionId,
      name: (row) => row.readTable(_database.seriesRecords).name,
    );
  }

  Future<Map<String, List<String>>> _loadSets() async {
    final query =
        _database.select(_database.cardSetMembers).join(<Join>[
            innerJoin(
              _database.cardSets,
              _database.cardSets.id.equalsExp(_database.cardSetMembers.setId),
            ),
          ])
          ..where(
            _database.cardSetMembers.deletedAt.isNull() &
                _database.cardSets.deletedAt.isNull(),
          )
          ..orderBy(<OrderingTerm>[
            OrderingTerm.asc(_database.cardSets.name),
            OrderingTerm.asc(_database.cardSets.id),
          ]);
    final rows = await query.get();
    return _groupNames(
      rows,
      key: (row) => row.readTable(_database.cardSetMembers).definitionId,
      name: (row) => row.readTable(_database.cardSets).name,
    );
  }

  Future<Map<String, _ReservedMetadata>> _loadReservedMetadata() async {
    final query =
        _database.select(_database.organizationFieldValues).join(<Join>[
          innerJoin(
            _database.organizationFieldDefinitions,
            _database.organizationFieldDefinitions.id.equalsExp(
                  _database.organizationFieldValues.fieldId,
                ) &
                _database.organizationFieldDefinitions.deletedAt.isNull(),
          ),
        ])..where(
          _database.organizationFieldDefinitions.name.isIn(<String>[
            conditionFieldName,
            itemNotesFieldName,
            issueQuantityFieldName,
            issuePriceFieldName,
          ]),
        );
    final rows = await query.get();
    final result = <String, _ReservedMetadata>{};
    for (final row in rows) {
      final value = row.readTable(_database.organizationFieldValues);
      final field = row.readTable(_database.organizationFieldDefinitions);
      final metadata = result.putIfAbsent(
        value.definitionId,
        _ReservedMetadata.new,
      );
      switch (field.name) {
        case conditionFieldName:
          metadata.condition = value.textValue;
        case itemNotesFieldName:
          metadata.itemNotes = value.textValue;
        case issueQuantityFieldName:
          metadata.issueQuantity = value.numberValue?.round();
        case issuePriceFieldName:
          metadata.issuePrice = value.numberValue;
      }
    }
    return result;
  }

  Future<Map<String, _Cost>> _loadCosts() async {
    final query =
        _database.select(_database.purchaseItems).join(<Join>[
          innerJoin(
            _database.purchases,
            _database.purchases.id.equalsExp(
              _database.purchaseItems.purchaseId,
            ),
          ),
        ])..where(
          _database.purchaseItems.targetType.equalsValue(
                PurchaseTargetType.card,
              ) &
              _database.purchases.id.like('card-entry-cost:%'),
        );
    final rows = await query.get();
    return <String, _Cost>{
      for (final row in rows)
        row.readTable(_database.purchaseItems).targetId: _Cost(
          amountMinor: row.readTable(_database.purchases).amountMinor,
          shippingMinor: row.readTable(_database.purchases).shippingMinor,
        ),
    };
  }
}

Map<String, List<String>> _groupNames(
  Iterable<TypedResult> rows, {
  required String Function(TypedResult row) key,
  required String Function(TypedResult row) name,
}) {
  final result = <String, List<String>>{};
  for (final row in rows) {
    result.putIfAbsent(key(row), () => <String>[]).add(name(row));
  }
  return result;
}

String? _money(int minor) => minor == 0
    ? null
    : CurrencyAmount(minorUnits: minor, currency: 'CNY').formatted;

String _date(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

final class _ReservedMetadata {
  String? condition;
  String? itemNotes;
  int? issueQuantity;
  double? issuePrice;
}

final class _Cost {
  const _Cost({required this.amountMinor, required this.shippingMinor});

  final int amountMinor;
  final int shippingMinor;
}
