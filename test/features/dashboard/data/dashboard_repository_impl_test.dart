import 'dart:io';

import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/core/time/clock.dart';
import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/dashboard/data/dashboard_repository_impl.dart';
import 'package:cardfolio_app/features/purchases/domain/purchase_models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns a real empty dashboard from the database boundary', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = DashboardRepositoryImpl(
      database: db,
      clock: FixedClock(DateTime.utc(2026, 7, 28)),
    );

    final home = await repository.watchHome(const CostDisplayOptions()).first;
    final stats = await repository
        .watchStatistics(const CostDisplayOptions())
        .first;

    expect(home.entityCount, 0);
    expect(stats.costTrend, isEmpty);
  });

  test('maps database errors to a safe dashboard failure', () async {
    final root = await Directory.systemTemp.createTemp(
      'cardfolio-dashboard-failure-',
    );
    addTearDown(() => root.delete(recursive: true));
    final db = AppDatabase(NativeDatabase(File(root.path)));
    addTearDown(() async {
      try {
        await db.close();
      } catch (_) {
        // The executor cannot open a directory as a database file.
      }
    });
    final repository = DashboardRepositoryImpl(
      database: db,
      clock: FixedClock(DateTime.utc(2026, 7, 28)),
    );

    await expectLater(
      repository.watchHome(const CostDisplayOptions()).first,
      throwsA(
        isA<DatabaseUnavailableFailure>()
            .having(
              (failure) => failure.userMessage,
              'userMessage',
              '首页与统计暂时无法读取，请重试。',
            )
            .having((failure) => failure.cause, 'cause', isNotNull),
      ),
    );
  });
}
