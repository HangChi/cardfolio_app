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

  void retainAvailableFacets(CardFilterFacets facets) {
    final cardType = facets.cardTypes.contains(state.cardType)
        ? state.cardType
        : null;
    final city = state.city == null ? null : cityFilterLevel(state.city!);
    final availableCity = facets.cities.contains(city) ? city : null;
    final year = facets.years.contains(state.year) ? state.year : null;
    final tagIds = state.tagIds
        .where((id) => facets.tags.any((tag) => tag.id == id))
        .toList(growable: false);
    if (cardType == state.cardType &&
        availableCity == state.city &&
        year == state.year &&
        tagIds.length == state.tagIds.length) {
      return;
    }
    state = state
        .copyWith(
          cardType: cardType,
          clearCardType: cardType == null,
          city: availableCity,
          clearCity: availableCity == null,
          year: year,
          clearYear: year == null,
          tagIds: tagIds,
        )
        .normalized();
  }
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
