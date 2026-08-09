import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cards/data/card_providers.dart';
import '../domain/card_set_models.dart';
import '../domain/card_set_repository.dart';
import 'card_set_repository_impl.dart';

final Provider<CardSetRepository> cardSetRepositoryProvider =
    Provider<CardSetRepository>((ref) {
      return CardSetRepositoryImpl(
        database: ref.watch(appDatabaseProvider),
        clock: ref.watch(clockProvider),
      );
    });

final StreamProvider<List<CardSetSummary>> cardSetListProvider =
    StreamProvider<List<CardSetSummary>>(
      (ref) => ref.watch(cardSetRepositoryProvider).watchSets(),
    );

final cardSetMembershipsProvider =
    StreamProvider.family<List<CardSetMembership>, String>(
      (ref, definitionId) =>
          ref.watch(cardSetRepositoryProvider).watchMemberships(definitionId),
    );

final cardSetDetailProvider = StreamProvider.family<CardSetDetail?, String>(
  (ref, setId) => ref.watch(cardSetRepositoryProvider).watchSet(setId),
);

final cardSetCandidatesProvider =
    StreamProvider.family<List<CardSetCandidate>, String>(
      (ref, setId) =>
          ref.watch(cardSetRepositoryProvider).watchCandidates(setId),
    );
