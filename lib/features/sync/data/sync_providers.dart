import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/account_sync_repository.dart';
import '../domain/sync_models.dart';

final Provider<AccountSyncRepository> accountSyncRepositoryProvider =
    Provider<AccountSyncRepository>((ref) {
      throw StateError('accountSyncRepositoryProvider 必须由启动流程覆盖');
    });

final StreamProvider<SyncOverview> syncOverviewProvider =
    StreamProvider<SyncOverview>(
      (ref) => ref.watch(accountSyncRepositoryProvider).watchOverview(),
    );

final StreamProvider<List<SyncConflict>> syncConflictsProvider =
    StreamProvider<List<SyncConflict>>(
      (ref) => ref.watch(accountSyncRepositoryProvider).watchConflicts(),
    );
