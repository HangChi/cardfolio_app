import '../../../core/errors/app_failure.dart';
import '../../../core/time/clock.dart';
import '../../cards/data/local/card_database.dart';
import '../domain/organization_models.dart';
import '../domain/organization_repository.dart';
import 'local/card_search_database.dart';
import 'local/organization_database.dart';
import 'local/organization_query_database.dart';

final class OrganizationRepositoryImpl implements OrganizationRepository {
  const OrganizationRepositoryImpl({
    required AppDatabase database,
    required this.clock,
  }) : _db = database;

  final AppDatabase _db;
  final Clock clock;

  @override
  Stream<List<OrganizedCardSummary>> watchCards(CardLibraryQuery query) =>
      _read(_db.watchOrganizedCards(query.normalized()));

  @override
  Stream<CardFilterFacets> watchFacets() =>
      _read(_db.watchOrganizationFacets());

  @override
  Stream<CardOrganizationDetail?> watchCardOrganization(String cardItemId) =>
      _read(
        _db.watchCardOrganizationDetail(
          _requiredId(cardItemId, OrganizationField.target),
        ),
      );

  @override
  Stream<List<TagSummary>> watchTags() => _read(_db.watchOrganizationTags());

  @override
  Stream<List<SeriesSummary>> watchSeries() =>
      _read(_db.watchOrganizationSeries());

  @override
  Stream<SeriesDetail?> watchSeriesDetail(String seriesId) => _read(
    _db.watchOrganizationSeriesDetail(
      _requiredId(seriesId, OrganizationField.series),
    ),
  );

  @override
  Stream<List<CustomFieldDefinition>> watchFieldDefinitions() =>
      _read(_db.watchOrganizationFields());

  @override
  Future<String> createTag(CreateTagRequest request) async {
    final normalized = request.normalized();
    final existing = await (_db.select(
      _db.tags,
    )..where((tag) => tag.id.equals(normalized.id))).getSingleOrNull();
    if (existing != null) return normalized.id;
    await _ensureUniqueTagName(
      normalized.normalizedName!,
      excludingId: normalized.id,
    );
    await _write(
      action: () =>
          _db.createOrganizationTag(request: normalized, now: clock.nowUtc()),
      field: OrganizationField.name,
      failureMessage: '创建标签失败，请重试。',
    );
    return normalized.id;
  }

  @override
  Future<void> renameTag(RenameTagRequest request) {
    final normalized = request.normalized();
    return _renameTag(normalized);
  }

  Future<void> _renameTag(RenameTagRequest normalized) async {
    await _ensureUniqueTagName(
      normalized.normalizedName!,
      excludingId: normalized.id,
    );
    await _write(
      action: () =>
          _db.renameOrganizationTag(request: normalized, now: clock.nowUtc()),
      field: OrganizationField.name,
      failureMessage: '重命名标签失败，请重试。',
    );
  }

  @override
  Future<ChangeImpact> previewTagChange(String tagId) async {
    try {
      return await _db.organizationTagImpact(
        _requiredId(tagId, OrganizationField.tag),
      );
    } on AppFailure {
      rethrow;
    } on StateError catch (error) {
      throw OrganizationValidationFailure(OrganizationField.tag, error.message);
    } catch (error) {
      throw DatabaseUnavailableFailure('无法读取标签影响，请重试。', error);
    }
  }

  @override
  Future<void> mergeTags(MergeTagsRequest request) {
    final normalized = request.normalized();
    return _write(
      action: () =>
          _db.mergeOrganizationTags(request: normalized, now: clock.nowUtc()),
      field: OrganizationField.tag,
      failureMessage: '合并标签失败，原有关联未改变。',
    );
  }

  @override
  Future<void> deleteTag(String tagId) {
    return _write(
      action: () => _db.deleteOrganizationTag(
        tagId: _requiredId(tagId, OrganizationField.tag),
        now: clock.nowUtc(),
      ),
      field: OrganizationField.tag,
      failureMessage: '删除标签失败，请重试。',
    );
  }

  @override
  Future<String> saveSeries(SaveSeriesRequest request) async {
    final normalized = request.normalized();
    await _write(
      action: () =>
          _db.saveOrganizationSeries(request: normalized, now: clock.nowUtc()),
      field: OrganizationField.series,
      failureMessage: '保存集卡册失败，请重试。',
    );
    return normalized.id;
  }

  @override
  Future<void> deleteSeries(String seriesId) {
    return _write(
      action: () => _db.deleteOrganizationSeries(
        seriesId: _requiredId(seriesId, OrganizationField.series),
        now: clock.nowUtc(),
      ),
      field: OrganizationField.series,
      failureMessage: '删除集卡册失败，请重试。',
    );
  }

  @override
  Future<String> createField(CreateCustomFieldRequest request) async {
    final normalized = request.normalized();
    final existing = await (_db.select(
      _db.organizationFieldDefinitions,
    )..where((field) => field.id.equals(normalized.id))).getSingleOrNull();
    if (existing != null) return normalized.id;
    await _ensureUniqueFieldName(
      normalized.normalizedName!,
      excludingId: normalized.id,
    );
    await _write(
      action: () =>
          _db.createOrganizationField(request: normalized, now: clock.nowUtc()),
      field: OrganizationField.name,
      failureMessage: '创建自定义字段失败，请重试。',
    );
    return normalized.id;
  }

  @override
  Future<void> renameField(RenameCustomFieldRequest request) {
    final normalized = request.normalized();
    return _renameField(normalized);
  }

  Future<void> _renameField(RenameCustomFieldRequest normalized) async {
    await _ensureUniqueFieldName(
      normalized.normalizedName!,
      excludingId: normalized.id,
    );
    await _write(
      action: () =>
          _db.renameOrganizationField(request: normalized, now: clock.nowUtc()),
      field: OrganizationField.name,
      failureMessage: '重命名字段失败，请重试。',
    );
  }

  @override
  Future<ChangeImpact> previewFieldDeletion(String fieldId) async {
    try {
      return await _db.organizationFieldDeletionImpact(
        _requiredId(fieldId, OrganizationField.customField),
      );
    } on AppFailure {
      rethrow;
    } on StateError catch (error) {
      throw OrganizationValidationFailure(
        OrganizationField.customField,
        error.message,
      );
    } catch (error) {
      throw DatabaseUnavailableFailure('无法读取字段影响，请重试。', error);
    }
  }

  @override
  Future<void> deleteField(String fieldId) {
    return _write(
      action: () => _db.deleteOrganizationField(
        fieldId: _requiredId(fieldId, OrganizationField.customField),
        now: clock.nowUtc(),
      ),
      field: OrganizationField.customField,
      failureMessage: '删除字段失败，请重试。',
    );
  }

  @override
  Future<void> saveCardOrganization(SaveCardOrganizationRequest request) {
    final normalized = request.normalized();
    return _write(
      action: () =>
          _db.saveCardOrganization(request: normalized, now: clock.nowUtc()),
      field: OrganizationField.value,
      failureMessage: '保存整理信息失败，请重试。',
    );
  }

  Stream<T> _read<T>(Stream<T> stream) {
    return stream.handleError((Object error) {
      if (error is AppFailure) throw error;
      throw DatabaseUnavailableFailure('整理信息暂时无法读取，请重试。', error);
    });
  }

  Future<void> _write({
    required Future<void> Function() action,
    required OrganizationField field,
    required String failureMessage,
  }) async {
    try {
      await action();
    } on AppFailure {
      rethrow;
    } on StateError catch (error) {
      throw OrganizationValidationFailure(field, error.message);
    } catch (error) {
      throw PersistenceFailure(failureMessage, error);
    }
  }

  Future<void> _ensureUniqueTagName(
    String normalizedName, {
    required String excludingId,
  }) async {
    final query = _db.select(_db.tags)
      ..where((tag) => tag.normalizedName.equals(normalizedName))
      ..where((tag) => tag.id.isNotValue(excludingId))
      ..where((tag) => tag.deletedAt.isNull());
    final duplicate = await query.getSingleOrNull();
    if (duplicate != null) {
      throw const OrganizationValidationFailure(
        OrganizationField.name,
        '已经存在同名标签。',
      );
    }
  }

  Future<void> _ensureUniqueFieldName(
    String normalizedName, {
    required String excludingId,
  }) async {
    final query = _db.select(_db.organizationFieldDefinitions)
      ..where((field) => field.normalizedName.equals(normalizedName))
      ..where((field) => field.id.isNotValue(excludingId))
      ..where((field) => field.deletedAt.isNull());
    final duplicate = await query.getSingleOrNull();
    if (duplicate != null) {
      throw const OrganizationValidationFailure(
        OrganizationField.name,
        '已经存在同名自定义字段。',
      );
    }
  }
}

String _requiredId(String value, OrganizationField field) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw OrganizationValidationFailure(field, '目标不存在，请刷新后重试。');
  }
  return normalized;
}
