import 'package:cardfolio_app/core/id/id_generator.dart';
import 'package:cardfolio_app/core/time/clock.dart';
import 'package:cardfolio_app/features/cards/data/card_providers.dart';
import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/cards/presentation/widgets/card_entry_metadata_fields.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('creating an inline tag does not break dialog teardown', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          clockProvider.overrideWithValue(
            FixedClock(DateTime.utc(2026, 7, 30)),
          ),
          idGeneratorProvider.overrideWithValue(const _FixedIdGenerator()),
        ],
        child: const MaterialApp(home: _TagTestScreen()),
      ),
    );

    await tester.tap(find.text('新建标签'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '纪念');
    await tester.tap(find.widgetWithText(FilledButton, '创建'));
    await tester.pumpAndSettle();

    expect(find.text('已创建 tag-1'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(await database.select(database.tags).get(), hasLength(1));
  });
}

class _TagTestScreen extends ConsumerStatefulWidget {
  const _TagTestScreen();

  @override
  ConsumerState<_TagTestScreen> createState() => _TagTestScreenState();
}

class _TagTestScreenState extends ConsumerState<_TagTestScreen> {
  String? _createdId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          FilledButton(
            onPressed: () async {
              final id = await createTagInline(context, ref);
              if (id != null && mounted) setState(() => _createdId = id);
            },
            child: const Text('新建标签'),
          ),
          if (_createdId != null) Text('已创建 $_createdId'),
        ],
      ),
    );
  }
}

class _FixedIdGenerator implements IdGenerator {
  const _FixedIdGenerator();

  @override
  String newId() => 'tag-1';
}
