import 'package:cardfolio_app/app/app_router.dart';
import 'package:cardfolio_app/app/cardfolio_app.dart';
import 'package:cardfolio_app/features/backup/data/backup_providers.dart';
import 'package:cardfolio_app/features/cards/data/card_providers.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:cardfolio_app/features/cards/domain/card_repository.dart';
import 'package:cardfolio_app/features/dashboard/data/dashboard_providers.dart';
import 'package:cardfolio_app/features/dashboard/domain/dashboard_models.dart';
import 'package:cardfolio_app/features/recycle_bin/data/recycle_bin_providers.dart';
import 'package:cardfolio_app/features/sync/data/sync_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/recycle_bin/support/fake_recycle_bin_repository.dart';
import '../features/backup/support/fake_backup_repository.dart';
import '../features/sync/support/fakes.dart';

class _EmptyCardRepository implements CardRepository {
  @override
  Future<void> addImages(AddCardImagesRequest request) async {}

  @override
  Future<String> createCard(CreateCardRequest request) async =>
      request.ids.cardItemId;

  @override
  Future<void> updateCard(UpdateCardRequest request) async {}

  @override
  Future<void> deleteImage({
    required String cardItemId,
    required String imageId,
    required bool keepOriginal,
  }) async {}

  @override
  Future<ImageDeletionImpact> getImageDeletionImpact({
    required String cardItemId,
    required String imageId,
  }) async => const ImageDeletionImpact(
    imageId: 'image-1',
    byteSize: 0,
    isCover: true,
    remainingImageCount: 1,
  );

  @override
  Future<Set<String>> referencedImagePaths() async => const <String>{};

  @override
  Future<void> reorderImages({
    required String cardItemId,
    required List<String> orderedImageIds,
  }) async {}

  @override
  Future<void> setCover({
    required String cardItemId,
    required String imageId,
  }) async {}

  @override
  Future<void> updateImageKind({
    required String cardItemId,
    required String imageId,
    required CardImageKind kind,
  }) async {}

  @override
  Future<void> updateImageEdit({
    required String cardItemId,
    required String imageId,
    required String derivedSourcePath,
  }) async {}

  @override
  Stream<List<CardSummary>> watchCards() =>
      Stream<List<CardSummary>>.value(const <CardSummary>[]);

  @override
  Stream<CardDetail?> watchCard(String cardItemId) =>
      Stream<CardDetail?>.value(null);
}

void main() {
  Future<void> pumpShell(WidgetTester tester, {String? initialLocation}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cardRepositoryProvider.overrideWithValue(_EmptyCardRepository()),
          homeDashboardProvider.overrideWith(
            (ref) => Stream<HomeDashboard>.value(const HomeDashboard.empty()),
          ),
          statisticsProvider.overrideWith(
            (ref) => Stream<StatisticsSnapshot>.value(
              const StatisticsSnapshot.empty(),
            ),
          ),
          recycleBinRepositoryProvider.overrideWithValue(
            FakeRecycleBinRepository(),
          ),
          backupRepositoryProvider.overrideWithValue(FakeBackupRepository()),
          backupFilePickerProvider.overrideWithValue(FakeBackupFilePicker()),
          accountSyncRepositoryProvider.overrideWithValue(
            FakeAccountSyncRepository(),
          ),
        ],
        child: CardfolioApp(
          router: createAppRouter(
            initialLocation: initialLocation ?? libraryPath,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  NavigationBar shellBar(WidgetTester tester) =>
      tester.widget<NavigationBar>(find.byType(NavigationBar));

  testWidgets('renders the five Cardfolio destinations in order', (
    tester,
  ) async {
    await pumpShell(tester);

    final labels = shellBar(tester).destinations
        .cast<NavigationDestination>()
        .map((destination) => destination.label)
        .toList();

    expect(labels, <String>['首页', '收藏', '拍摄', '统计', '我的']);
  });

  testWidgets('starts on the collection destination', (tester) async {
    await pumpShell(tester);

    expect(shellBar(tester).selectedIndex, 1);
  });

  testWidgets('is branded as 卡迹', (tester) async {
    await pumpShell(tester);

    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).title, '卡迹');
  });

  testWidgets('selecting a destination navigates to its branch', (
    tester,
  ) async {
    await pumpShell(tester);

    await tester.tap(find.text('统计'));
    await tester.pumpAndSettle();

    expect(shellBar(tester).selectedIndex, 3);
  });

  testWidgets('statistics destination renders the implemented page', (
    tester,
  ) async {
    await pumpShell(tester, initialLocation: statsPath);

    expect(find.text('数量分布'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('暂无统计数据'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('暂无统计数据'), findsOneWidget);
  });

  testWidgets('recycle-bin route renders the implemented page', (tester) async {
    await pumpShell(tester, initialLocation: recycleBinPath);

    expect(find.text('回收站'), findsOneWidget);
    expect(find.text('回收站是空的'), findsOneWidget);
  });

  testWidgets('profile exposes the recycle-bin entry', (tester) async {
    await pumpShell(tester, initialLocation: profilePath);

    await tester.scrollUntilVisible(
      find.text('回收站'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('回收站'), findsOneWidget);
    expect(find.text('恢复已删除卡片，或将其永久删除。'), findsOneWidget);
  });

  testWidgets('backup route renders the implemented page', (tester) async {
    await pumpShell(tester, initialLocation: backupPath);

    expect(find.text('导入与导出'), findsOneWidget);
    expect(find.text('导出完整备份'), findsOneWidget);
  });

  testWidgets('profile exposes the backup entry', (tester) async {
    await pumpShell(tester, initialLocation: profilePath);

    await tester.scrollUntilVisible(
      find.text('导入与导出'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('导入与导出'), findsOneWidget);
    expect(find.text('备份、恢复或合并你的全部收藏数据。'), findsOneWidget);
  });

  testWidgets(
    'deduplicates back events and resets confirmation on navigation',
    (tester) async {
      var exitCalls = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'SystemNavigator.pop') exitCalls++;
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
      await pumpShell(tester);

      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.text('再按一次返回键退出应用'), findsOneWidget);
      expect(exitCalls, 0);

      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(exitCalls, 0);

      await tester.tap(find.text('首页').last);
      await tester.pumpAndSettle();
      expect(find.text('再按一次返回键退出应用'), findsNothing);

      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.text('再按一次返回键退出应用'), findsOneWidget);
      expect(exitCalls, 0);
    },
  );
}
