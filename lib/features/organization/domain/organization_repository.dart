import 'organization_models.dart';

abstract interface class OrganizationRepository {
  Stream<List<OrganizedCardSummary>> watchCards(CardLibraryQuery query);

  Stream<CardFilterFacets> watchFacets();

  Stream<CardOrganizationDetail?> watchCardOrganization(String cardItemId);

  Future<void> saveCardOrganization(SaveCardOrganizationRequest request);

  Stream<List<TagSummary>> watchTags();

  Future<String> createTag(CreateTagRequest request);

  Future<void> renameTag(RenameTagRequest request);

  Future<ChangeImpact> previewTagChange(String tagId);

  Future<void> mergeTags(MergeTagsRequest request);

  Future<void> deleteTag(String tagId);

  Stream<List<SeriesSummary>> watchSeries();

  Stream<SeriesDetail?> watchSeriesDetail(String seriesId);

  Future<String> saveSeries(SaveSeriesRequest request);

  Future<void> deleteSeries(String seriesId);

  Stream<List<CustomFieldDefinition>> watchFieldDefinitions();

  Future<String> createField(CreateCustomFieldRequest request);

  Future<void> renameField(RenameCustomFieldRequest request);

  Future<ChangeImpact> previewFieldDeletion(String fieldId);

  Future<void> deleteField(String fieldId);
}
