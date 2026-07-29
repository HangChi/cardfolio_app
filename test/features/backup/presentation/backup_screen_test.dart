import 'package:cardfolio_app/features/backup/data/backup_providers.dart';
import 'package:cardfolio_app/features/backup/domain/backup_models.dart';
import 'package:cardfolio_app/features/backup/presentation/backup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_backup_repository.dart';

void main() {
  late FakeBackupRepository repository;
  late FakeBackupFilePicker picker;

  setUp(() {
    repository = FakeBackupRepository();
    picker = FakeBackupFilePicker();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          backupRepositoryProvider.overrideWithValue(repository),
          backupFilePickerProvider.overrideWithValue(picker),
        ],
        child: const MaterialApp(home: BackupScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('export explains sensitive contents and picker cancel is quiet', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('导入与导出'), findsOneWidget);
    expect(find.textContaining('私人图片、备注和购买信息'), findsOneWidget);

    await tester.tap(find.text('导出完整备份'));
    await tester.pumpAndSettle();

    expect(find.text('备份包含敏感内容'), findsOneWidget);
    await tester.tap(find.text('选择保存位置'));
    await tester.pumpAndSettle();

    expect(picker.exportCalls, 1);
    expect(repository.exportCalls, 0);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('export shows progress, supports cancel and reports success', (
    tester,
  ) async {
    picker.exportPath = 'backup.zip';
    repository.holdExport = true;
    await pumpScreen(tester);

    await tester.tap(find.text('导出完整备份'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('选择保存位置'));
    await tester.pumpAndSettle();

    expect(find.text('正在验证备份 40%'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, '取消'));
    expect(repository.exportToken!.isCancelled, isTrue);
    repository.finishCancelledExport();
    await tester.pumpAndSettle();
    expect(find.text('操作已取消。'), findsOneWidget);

    repository.holdExport = false;
    await tester.tap(find.text('导出完整备份'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('选择保存位置'));
    await tester.pumpAndSettle();
    expect(find.text('已导出 3 项数据和 1 个图片文件'), findsOneWidget);
    expect(picker.publishCalls, 1);
  });

  testWidgets('export picker failures show safe storage messages', (
    tester,
  ) async {
    picker.exportError = const BackupStorageFailure('无法打开系统保存位置，请重试。');
    await pumpScreen(tester);

    await tester.tap(find.text('导出完整备份'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('选择保存位置'));
    await tester.pumpAndSettle();
    expect(find.text('无法打开系统保存位置，请重试。'), findsOneWidget);
  });

  testWidgets('import picker failures show safe storage messages', (
    tester,
  ) async {
    picker.importError = const BackupStorageFailure('无法打开系统文件选择器，请重试。');
    await pumpScreen(tester);

    await tester.tap(find.text('选择备份文件'));
    await tester.pumpAndSettle();
    expect(picker.importCalls, 1);
    expect(find.text('无法打开系统文件选择器，请重试。'), findsOneWidget);
  });

  testWidgets('import previews impact and reports completed restore', (
    tester,
  ) async {
    picker.importPath = 'backup.zip';
    await pumpScreen(tester);

    await tester.tap(find.text('选择备份文件'));
    await tester.pumpAndSettle();

    expect(repository.inspectCalls, 1);
    expect(find.text('可新增 3 项'), findsOneWidget);
    expect(find.text('1 个图片文件'), findsOneWidget);
    expect(find.text('确认导入'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认导入'));
    await tester.pumpAndSettle();

    expect(repository.importCalls, 1);
    expect(find.text('已导入 3 项，跳过 0 项'), findsOneWidget);
  });

  testWidgets('conflicts are visible and block import confirmation', (
    tester,
  ) async {
    picker.importPath = 'backup.zip';
    repository.preview = BackupImportPreview(
      createdAt: DateTime.utc(2026, 7, 29, 8),
      mode: BackupMode.emptyLibrary,
      entityCounts: const <String, int>{'cardDefinitions': 1},
      imageCount: 0,
      addedCount: 0,
      skippedCount: 0,
      conflicts: const <BackupConflict>[
        BackupConflict(entity: 'cardDefinitions', key: 'same-id'),
      ],
    );
    await pumpScreen(tester);

    await tester.tap(find.text('选择备份文件'));
    await tester.pumpAndSettle();

    expect(find.text('发现 1 个冲突，当前模式不能导入'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '确认导入'),
    );
    expect(button.onPressed, isNull);
  });
}
