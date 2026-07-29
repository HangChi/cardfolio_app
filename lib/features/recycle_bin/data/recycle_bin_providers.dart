import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cards/data/card_providers.dart';
import '../domain/recycle_bin_models.dart';
import '../domain/recycle_bin_repository.dart';
import 'recycle_bin_repository_impl.dart';

final Provider<RecycleBinRepository> recycleBinRepositoryProvider =
    Provider<RecycleBinRepository>((ref) {
      return RecycleBinRepositoryImpl(
        database: ref.watch(appDatabaseProvider),
        imageStore: ref.watch(managedImageStoreProvider),
        clock: ref.watch(clockProvider),
      );
    });

final StreamProvider<List<RecycleBinEntry>> recycleBinEntriesProvider =
    StreamProvider<List<RecycleBinEntry>>(
      (ref) => ref.watch(recycleBinRepositoryProvider).watchEntries(),
    );

final StreamProvider<RecycleBinSettings> recycleBinSettingsProvider =
    StreamProvider<RecycleBinSettings>(
      (ref) => ref.watch(recycleBinRepositoryProvider).watchSettings(),
    );
