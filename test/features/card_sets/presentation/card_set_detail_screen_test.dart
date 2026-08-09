import 'package:cardfolio_app/app/app_theme.dart';
import 'package:cardfolio_app/core/id/id_generator.dart';
import 'package:cardfolio_app/features/card_sets/data/card_set_providers.dart';
import 'package:cardfolio_app/features/card_sets/domain/card_set_models.dart';
import 'package:cardfolio_app/features/card_sets/presentation/detail/card_set_detail_screen.dart';
import 'package:cardfolio_app/features/cards/data/card_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_card_set_repository.dart';

final class _SequenceIds implements IdGenerator {
  int _value = 0;

  @override
  String newId() => 'new-${_value++}';
}

void main() {
  final now = DateTime.utc(2026, 7, 28);
  final members = <CardSetMemberDetail>[
    const CardSetMemberDetail(
      id: 'member-1',
      definitionId: 'definition-1',
      name: '春',
      memberNo: '01',
      required: true,
      sortOrder: 0,
      ownedQuantity: 1,
      cardItemId: 'item-1',
      coverImageId: 'image-1',
    ),
    const CardSetMemberDetail(
      id: 'member-2',
      definitionId: 'definition-2',
      name: '夏',
      memberNo: '02',
      required: true,
      sortOrder: 1,
      ownedQuantity: 2,
      cardItemId: 'item-2',
      coverImageId: 'image-2',
    ),
    const CardSetMemberDetail(
      id: 'member-3',
      definitionId: 'definition-3',
      name: '秋',
      memberNo: '03',
      required: true,
      sortOrder: 2,
      ownedQuantity: 1,
    ),
    const CardSetMemberDetail(
      id: 'member-4',
      definitionId: 'definition-4',
      name: '冬',
      memberNo: '04',
      required: true,
      sortOrder: 3,
      ownedQuantity: 0,
    ),
  ];

  CardSetDetail detail({bool countKnown = true, String? coverRelativePath}) {
    return CardSetDetail(
      id: 'set-1',
      name: '四季套卡',
      countKnown: countKnown,
      expectedCount: countKnown ? 4 : null,
      createdAt: now,
      updatedAt: now,
      coverRelativePath: coverRelativePath,
      members: members,
      progress: CardSetProgress.calculate(
        countKnown: countKnown,
        members: members,
      ),
    );
  }

  Widget subject(
    FakeCardSetRepository repository, {
    TextScaler textScaler = TextScaler.noScaling,
  }) {
    return ProviderScope(
      overrides: [
        cardSetRepositoryProvider.overrideWithValue(repository),
        idGeneratorProvider.overrideWithValue(_SequenceIds()),
      ],
      child: MaterialApp(
        theme: buildCardfolioTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        home: const CardSetDetailScreen(setId: 'set-1'),
      ),
    );
  }

  testWidgets('shows 3 of 4 with explicit missing and duplicate states', (
    tester,
  ) async {
    final repository = FakeCardSetRepository(
      details: <String, CardSetDetail?>{'set-1': detail()},
    );

    await tester.pumpWidget(subject(repository));
    await tester.pumpAndSettle();

    expect(find.text('3 / 4'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('缺失'), findsOneWidget);
    expect(find.text('重复'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('已拥有 2 张 · 重复 1 张'), findsOneWidget);
    expect(find.text('冬'), findsOneWidget);
    expect(find.text('缺失'), findsWidgets);
  });

  testWidgets('unknown total hides percentage and completion', (tester) async {
    final repository = FakeCardSetRepository(
      details: <String, CardSetDetail?>{'set-1': detail(countKnown: false)},
    );

    await tester.pumpWidget(subject(repository));
    await tester.pumpAndSettle();

    expect(find.text('总数未知'), findsOneWidget);
    expect(find.text('75%'), findsNothing);
    expect(find.textContaining('已集齐'), findsNothing);
  });

  testWidgets('defines a missing required member', (tester) async {
    final repository = FakeCardSetRepository(
      details: <String, CardSetDetail?>{'set-1': detail(countKnown: false)},
    );
    await tester.pumpWidget(subject(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('添加成员'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('定义缺失成员'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('missing-member-name')), '特别款');
    await tester.enterText(
      find.byKey(const Key('missing-member-number')),
      'SP',
    );
    await tester.tap(find.text('添加缺失成员'));
    await tester.pumpAndSettle();

    expect(repository.added, hasLength(1));
    expect(repository.added.single.createsDefinition, isTrue);
    expect(repository.added.single.definitionName, '特别款');
    expect(repository.added.single.memberNo, 'SP');
  });

  testWidgets('remains usable at 200 percent text on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = FakeCardSetRepository(
      details: <String, CardSetDetail?>{'set-1': detail()},
    );

    await tester.pumpWidget(
      subject(repository, textScaler: const TextScaler.linear(2)),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byTooltip('添加成员'), findsOneWidget);
  });

  testWidgets('clears a standalone cover from the cover source sheet', (
    tester,
  ) async {
    final repository = FakeCardSetRepository(
      details: <String, CardSetDetail?>{
        'set-1': detail(coverRelativePath: 'covers/set-1.jpg'),
      },
    );

    await tester.pumpWidget(subject(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('card-set-cover')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('清除封面'));
    await tester.pumpAndSettle();

    expect(
      repository.standaloneCovers,
      <({String setId, String? relativePath})>[
        (setId: 'set-1', relativePath: null),
      ],
    );
  });
}
