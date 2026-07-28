import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cards/data/card_providers.dart';
import '../domain/organization_models.dart';
import '../domain/organization_repository.dart';
import 'organization_repository_impl.dart';

final Provider<OrganizationRepository> organizationRepositoryProvider =
    Provider<OrganizationRepository>((ref) {
      return OrganizationRepositoryImpl(
        database: ref.watch(appDatabaseProvider),
        clock: ref.watch(clockProvider),
      );
    });

final NotifierProvider<CardLibraryQueryController, CardLibraryQuery>
cardLibraryQueryProvider =
    NotifierProvider<CardLibraryQueryController, CardLibraryQuery>(
      CardLibraryQueryController.new,
    );

final class CardLibraryQueryController extends Notifier<CardLibraryQuery> {
  @override
  CardLibraryQuery build() => const CardLibraryQuery();

  void replace(CardLibraryQuery query) => state = query.normalized();

  void setSearchText(String? value) {
    state = state
        .copyWith(
          searchText: value,
          clearSearchText: value == null || value.trim().isEmpty,
        )
        .normalized();
  }

  void clearFilters() {
    state = CardLibraryQuery(
      searchText: state.searchText,
      sortField: state.sortField,
      sortDirection: state.sortDirection,
    ).normalized();
  }

  void clearAll() => state = const CardLibraryQuery();
}

final StreamProvider<List<OrganizedCardSummary>> organizedCardListProvider =
    StreamProvider<List<OrganizedCardSummary>>((ref) {
      final query = ref.watch(cardLibraryQueryProvider);
      return ref.watch(organizationRepositoryProvider).watchCards(query);
    });

final StreamProvider<CardFilterFacets> cardFilterFacetsProvider =
    StreamProvider<CardFilterFacets>((ref) {
      return ref.watch(organizationRepositoryProvider).watchFacets();
    });

final StreamProvider<List<TagSummary>> organizationTagsProvider =
    StreamProvider<List<TagSummary>>((ref) {
      return ref.watch(organizationRepositoryProvider).watchTags();
    });

final StreamProvider<List<SeriesSummary>> organizationSeriesProvider =
    StreamProvider<List<SeriesSummary>>((ref) {
      return ref.watch(organizationRepositoryProvider).watchSeries();
    });

final seriesDetailProvider = StreamProvider.family<SeriesDetail?, String>(
  (ref, seriesId) =>
      ref.watch(organizationRepositoryProvider).watchSeriesDetail(seriesId),
);

final StreamProvider<List<CustomFieldDefinition>>
organizationFieldDefinitionsProvider =
    StreamProvider<List<CustomFieldDefinition>>((ref) {
      return ref.watch(organizationRepositoryProvider).watchFieldDefinitions();
    });

final cardOrganizationProvider =
    StreamProvider.family<CardOrganizationDetail?, String>(
      (ref, cardItemId) => ref
          .watch(organizationRepositoryProvider)
          .watchCardOrganization(cardItemId),
    );
