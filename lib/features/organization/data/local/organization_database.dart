import 'package:drift/drift.dart';

import '../../../cards/data/local/card_database.dart';
import '../../domain/organization_models.dart';

extension OrganizationDatabase on AppDatabase {
  Future<void> createOrganizationTag({
    required CreateTagRequest request,
    required DateTime now,
  }) {
    return into(tags).insert(
      TagsCompanion.insert(
        id: request.id,
        name: request.name,
        normalizedName: request.normalizedName!,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> renameOrganizationTag({
    required RenameTagRequest request,
    required DateTime now,
  }) async {
    final existing = await _activeTag(this, request.id);
    if (existing == null) throw StateError('标签不存在。');
    final changed =
        await (update(tags)..where((tag) => tag.id.equals(request.id))).write(
          TagsCompanion(
            name: Value(request.name),
            normalizedName: Value(request.normalizedName!),
            updatedAt: Value(now),
            version: Value(existing.version + 1),
          ),
        );
    if (changed != 1) throw StateError('标签不存在。');
  }

  Future<ChangeImpact> organizationTagImpact(String tagId) async {
    final tag = await _activeTag(this, tagId);
    if (tag == null) throw StateError('标签不存在。');
    final countQuery = selectOnly(cardTags)
      ..addColumns(<Expression<Object>>[cardTags.definitionId.count()])
      ..where(cardTags.tagId.equals(tagId));
    final count =
        (await countQuery.getSingle()).read(cardTags.definitionId.count()) ?? 0;
    return ChangeImpact(targetId: tagId, associationCount: count);
  }

  Future<void> replaceCardTags({
    required String definitionId,
    required List<String> tagIds,
    required DateTime now,
  }) {
    return transaction(
      () => _replaceCardTags(
        this,
        definitionId: definitionId,
        tagIds: tagIds,
        now: now,
      ),
    );
  }

  Future<void> mergeOrganizationTags({
    required MergeTagsRequest request,
    required DateTime now,
  }) {
    return transaction(() async {
      final source = await _activeTag(this, request.sourceTagId);
      final target = await _activeTag(this, request.targetTagId);
      if (source == null || target == null) throw StateError('标签不存在。');

      final sourceLinks = await (select(
        cardTags,
      )..where((link) => link.tagId.equals(source.id))).get();
      for (final link in sourceLinks) {
        await into(cardTags).insert(
          CardTagsCompanion.insert(
            tagId: target.id,
            definitionId: link.definitionId,
            createdAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }

      final changed =
          await (update(tags)..where((tag) => tag.id.equals(source.id))).write(
            TagsCompanion(
              deletedAt: Value(now),
              updatedAt: Value(now),
              version: Value(source.version + 1),
            ),
          );
      if (changed != 1) throw StateError('标签不存在。');
    });
  }

  Future<void> deleteOrganizationTag({
    required String tagId,
    required DateTime now,
  }) async {
    final tag = await _activeTag(this, tagId);
    if (tag == null) throw StateError('标签不存在。');
    await (update(tags)..where((entry) => entry.id.equals(tagId))).write(
      TagsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        version: Value(tag.version + 1),
      ),
    );
  }

  Future<void> createOrganizationField({
    required CreateCustomFieldRequest request,
    required DateTime now,
  }) {
    return into(organizationFieldDefinitions).insert(
      OrganizationFieldDefinitionsCompanion.insert(
        id: request.id,
        name: request.name,
        normalizedName: request.normalizedName!,
        fieldType: request.fieldType,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> renameOrganizationField({
    required RenameCustomFieldRequest request,
    required DateTime now,
  }) async {
    final existing = await _activeField(this, request.id);
    if (existing == null) throw StateError('自定义字段不存在。');
    await (update(
      organizationFieldDefinitions,
    )..where((field) => field.id.equals(request.id))).write(
      OrganizationFieldDefinitionsCompanion(
        name: Value(request.name),
        normalizedName: Value(request.normalizedName!),
        updatedAt: Value(now),
        version: Value(existing.version + 1),
      ),
    );
  }

  Future<ChangeImpact> organizationFieldDeletionImpact(String fieldId) async {
    final field = await _activeField(this, fieldId);
    if (field == null) throw StateError('自定义字段不存在。');
    final query = selectOnly(organizationFieldValues)
      ..addColumns(<Expression<Object>>[
        organizationFieldValues.definitionId.count(),
      ])
      ..where(organizationFieldValues.fieldId.equals(fieldId));
    final count =
        (await query.getSingle()).read(
          organizationFieldValues.definitionId.count(),
        ) ??
        0;
    return ChangeImpact(
      targetId: fieldId,
      associationCount: count,
      valueCount: count,
    );
  }

  Future<void> deleteOrganizationField({
    required String fieldId,
    required DateTime now,
  }) async {
    final field = await _activeField(this, fieldId);
    if (field == null) throw StateError('自定义字段不存在。');
    await (update(
      organizationFieldDefinitions,
    )..where((entry) => entry.id.equals(fieldId))).write(
      OrganizationFieldDefinitionsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        version: Value(field.version + 1),
      ),
    );
  }

  Future<void> saveOrganizationSeries({
    required SaveSeriesRequest request,
    required DateTime now,
  }) {
    return transaction(() async {
      await _requireActiveDefinitions(this, request.definitionIds);
      await _requireActiveSets(this, request.setIds);

      final existing = await (select(
        seriesRecords,
      )..where((series) => series.id.equals(request.id))).getSingleOrNull();
      if (existing == null) {
        await into(seriesRecords).insert(
          SeriesRecordsCompanion.insert(
            id: request.id,
            name: request.name,
            description: Value(request.description),
            coverRelativePath: Value(request.coverRelativePath),
            createdAt: now,
            updatedAt: now,
          ),
        );
      } else {
        if (existing.deletedAt != null) throw StateError('集卡册不存在。');
        await (update(
          seriesRecords,
        )..where((series) => series.id.equals(request.id))).write(
          SeriesRecordsCompanion(
            name: Value(request.name),
            description: Value(request.description),
            coverRelativePath: Value(request.coverRelativePath),
            updatedAt: Value(now),
            version: Value(existing.version + 1),
          ),
        );
      }

      await (delete(
        seriesCards,
      )..where((link) => link.seriesId.equals(request.id))).go();
      for (final definitionId in request.definitionIds) {
        await into(seriesCards).insert(
          SeriesCardsCompanion.insert(
            seriesId: request.id,
            definitionId: definitionId,
            createdAt: now,
          ),
        );
      }

      await (delete(
        seriesSets,
      )..where((link) => link.seriesId.equals(request.id))).go();
      for (final setId in request.setIds) {
        await into(seriesSets).insert(
          SeriesSetsCompanion.insert(
            seriesId: request.id,
            setId: setId,
            createdAt: now,
          ),
        );
      }
    });
  }

  Future<void> deleteOrganizationSeries({
    required String seriesId,
    required DateTime now,
  }) async {
    final series = await _activeSeries(this, seriesId);
    if (series == null) throw StateError('集卡册不存在。');
    await (update(
      seriesRecords,
    )..where((entry) => entry.id.equals(seriesId))).write(
      SeriesRecordsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        version: Value(series.version + 1),
      ),
    );
  }

  Future<void> saveCardOrganization({
    required SaveCardOrganizationRequest request,
    required DateTime now,
  }) {
    return transaction(() async {
      final item =
          await (select(cardItems)..where(
                (entry) =>
                    entry.id.equals(request.cardItemId) &
                    entry.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (item == null) throw StateError('卡片不存在。');
      final definition =
          await (select(cardDefinitions)..where(
                (entry) =>
                    entry.id.equals(item.definitionId) &
                    entry.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (definition == null) throw StateError('卡片不存在。');

      await _requireActiveTags(this, request.tagIds);
      await _requireActiveSeries(this, request.seriesIds);
      final fields = await _requireActiveFields(
        this,
        request.fieldValues.map((value) => value.fieldId).toList(),
      );
      for (final value in request.fieldValues) {
        if (fields[value.fieldId]!.fieldType != value.fieldType) {
          throw StateError('自定义字段值类型不匹配。');
        }
      }

      await (update(
        cardDefinitions,
      )..where((entry) => entry.id.equals(definition.id))).write(
        CardDefinitionsCompanion(
          cardType: Value(request.cardType),
          needsCompletion: Value(request.needsCompletion),
          updatedAt: Value(now),
          version: Value(definition.version + 1),
        ),
      );
      await (update(
        cardItems,
      )..where((entry) => entry.id.equals(item.id))).write(
        CardItemsCompanion(
          acquiredAt: Value(request.acquiredAt),
          updatedAt: Value(now),
          version: Value(item.version + 1),
        ),
      );

      await _replaceCardTags(
        this,
        definitionId: definition.id,
        tagIds: request.tagIds,
        now: now,
        validate: false,
      );

      await (delete(
        seriesCards,
      )..where((link) => link.definitionId.equals(definition.id))).go();
      for (final seriesId in request.seriesIds) {
        await into(seriesCards).insert(
          SeriesCardsCompanion.insert(
            seriesId: seriesId,
            definitionId: definition.id,
            createdAt: now,
          ),
        );
      }

      await (delete(
        organizationFieldValues,
      )..where((value) => value.definitionId.equals(definition.id))).go();
      for (final value in request.fieldValues) {
        await into(organizationFieldValues).insert(
          OrganizationFieldValuesCompanion.insert(
            fieldId: value.fieldId,
            definitionId: definition.id,
            textValue: Value(value.textValue),
            numberValue: Value(value.numberValue),
            dateValue: Value(value.dateValue),
            updatedAt: now,
          ),
        );
      }
    });
  }
}

Future<void> _replaceCardTags(
  AppDatabase db, {
  required String definitionId,
  required List<String> tagIds,
  required DateTime now,
  bool validate = true,
}) async {
  if (validate) {
    final definition = await (db.select(
      db.cardDefinitions,
    )..where((entry) => entry.id.equals(definitionId))).getSingleOrNull();
    if (definition == null) throw StateError('卡片不存在。');
    await _requireActiveTags(db, tagIds);
  }
  await (db.delete(
    db.cardTags,
  )..where((link) => link.definitionId.equals(definitionId))).go();
  for (final tagId in tagIds) {
    await db
        .into(db.cardTags)
        .insert(
          CardTagsCompanion.insert(
            tagId: tagId,
            definitionId: definitionId,
            createdAt: now,
          ),
        );
  }
}

Future<Tag?> _activeTag(AppDatabase db, String id) {
  final query = db.select(db.tags)
    ..where((tag) => tag.id.equals(id) & tag.deletedAt.isNull());
  return query.getSingleOrNull();
}

Future<SeriesRecord?> _activeSeries(AppDatabase db, String id) {
  final query = db.select(db.seriesRecords)
    ..where((series) => series.id.equals(id) & series.deletedAt.isNull());
  return query.getSingleOrNull();
}

Future<OrganizationFieldDefinition?> _activeField(AppDatabase db, String id) {
  final query = db.select(db.organizationFieldDefinitions)
    ..where((field) => field.id.equals(id) & field.deletedAt.isNull());
  return query.getSingleOrNull();
}

Future<void> _requireActiveTags(AppDatabase db, List<String> ids) async {
  if (ids.isEmpty) return;
  final rows = await (db.select(
    db.tags,
  )..where((tag) => tag.id.isIn(ids) & tag.deletedAt.isNull())).get();
  if (rows.length != ids.length) throw StateError('标签不存在。');
}

Future<void> _requireActiveSeries(AppDatabase db, List<String> ids) async {
  if (ids.isEmpty) return;
  final rows = await (db.select(
    db.seriesRecords,
  )..where((series) => series.id.isIn(ids) & series.deletedAt.isNull())).get();
  if (rows.length != ids.length) throw StateError('集卡册不存在。');
}

Future<Map<String, OrganizationFieldDefinition>> _requireActiveFields(
  AppDatabase db,
  List<String> ids,
) async {
  if (ids.isEmpty) return const <String, OrganizationFieldDefinition>{};
  final rows = await (db.select(
    db.organizationFieldDefinitions,
  )..where((field) => field.id.isIn(ids) & field.deletedAt.isNull())).get();
  if (rows.length != ids.length) throw StateError('自定义字段不存在。');
  return <String, OrganizationFieldDefinition>{
    for (final row in rows) row.id: row,
  };
}

Future<void> _requireActiveDefinitions(AppDatabase db, List<String> ids) async {
  if (ids.isEmpty) return;
  final rows =
      await (db.select(db.cardDefinitions)..where(
            (definition) =>
                definition.id.isIn(ids) & definition.deletedAt.isNull(),
          ))
          .get();
  if (rows.length != ids.length) throw StateError('卡片不存在。');
}

Future<void> _requireActiveSets(AppDatabase db, List<String> ids) async {
  if (ids.isEmpty) return;
  final rows = await (db.select(
    db.cardSets,
  )..where((set) => set.id.isIn(ids) & set.deletedAt.isNull())).get();
  if (rows.length != ids.length) throw StateError('套卡不存在。');
}
