import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../app/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../cards/data/card_providers.dart';
import '../../data/card_set_providers.dart';
import '../../domain/card_set_models.dart';

class CardSetFormScreen extends ConsumerWidget {
  const CardSetFormScreen({this.setId, super.key});

  final String? setId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = setId;
    if (id == null) {
      return const _CardSetFormBody();
    }
    final detail = ref.watch(cardSetDetailProvider(id));
    return detail.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(semanticsLabel: '正在加载套卡资料'),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('编辑套卡')),
        body: const Center(child: Text('套卡资料暂时无法加载')),
      ),
      data: (set) => set == null
          ? Scaffold(
              appBar: AppBar(title: const Text('编辑套卡')),
              body: const Center(child: Text('这套卡不存在或已被删除')),
            )
          : _CardSetFormBody(initial: set),
    );
  }
}

class _CardSetFormBody extends ConsumerStatefulWidget {
  const _CardSetFormBody({this.initial});

  final CardSetDetail? initial;

  @override
  ConsumerState<_CardSetFormBody> createState() => _CardSetFormBodyState();
}

class _CardSetFormBodyState extends ConsumerState<_CardSetFormBody> {
  late final TextEditingController _name;
  late final TextEditingController _expectedCount;
  late final TextEditingController _issueInfo;
  late final TextEditingController _notes;
  late bool _countKnown;
  bool _saving = false;
  String? _error;

  bool get _editing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _name = TextEditingController(text: initial?.name);
    _expectedCount = TextEditingController(
      text: initial?.expectedCount?.toString() ?? '1',
    );
    _issueInfo = TextEditingController(text: initial?.issueInfo);
    _notes = TextEditingController(text: initial?.notes);
    _countKnown = initial?.countKnown ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _expectedCount.dispose();
    _issueInfo.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repository = ref.read(cardSetRepositoryProvider);
      final expectedCount = _countKnown
          ? int.tryParse(_expectedCount.text.trim())
          : null;
      final initial = widget.initial;
      final String id;
      if (initial == null) {
        id = ref.read(idGeneratorProvider).newId();
        await repository.createSet(
          CreateCardSetRequest(
            id: id,
            name: _name.text,
            countKnown: _countKnown,
            expectedCount: expectedCount,
            issueInfo: _issueInfo.text,
            notes: _notes.text,
          ),
        );
      } else {
        id = initial.id;
        await repository.updateSet(
          UpdateCardSetRequest(
            id: id,
            name: _name.text,
            countKnown: _countKnown,
            expectedCount: expectedCount,
            issueInfo: _issueInfo.text,
            notes: _notes.text,
          ),
        );
      }
      if (mounted) context.go(cardSetDetailPath(id));
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _error = failure.userMessage);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? '编辑套卡' : '新建套卡')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(tokens.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                key: const Key('set-name'),
                controller: _name,
                textInputAction: TextInputAction.next,
                maxLength: CreateCardSetRequest.maxNameLength,
                decoration: const InputDecoration(
                  labelText: '套卡名称 *',
                  hintText: '例如：四季纪念套卡',
                ),
              ),
              SizedBox(height: tokens.spaceMd),
              Card(
                child: SwitchListTile(
                  key: const Key('set-count-known'),
                  title: const Text('成员总数已知'),
                  subtitle: Text(_countKnown ? '显示完成度和集齐状态' : '只显示已拥有款式数'),
                  value: _countKnown,
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _countKnown = value),
                ),
              ),
              if (_countKnown) ...<Widget>[
                SizedBox(height: tokens.spaceMd),
                TextField(
                  key: const Key('set-expected-count'),
                  controller: _expectedCount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '预计成员数 *',
                    hintText: '例如：4',
                  ),
                ),
              ],
              SizedBox(height: tokens.spaceMd),
              TextField(
                controller: _issueInfo,
                maxLength: CreateCardSetRequest.maxLongTextLength,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '发行信息',
                  hintText: '年份、机构或发行背景',
                ),
              ),
              SizedBox(height: tokens.spaceMd),
              TextField(
                controller: _notes,
                maxLength: CreateCardSetRequest.maxLongTextLength,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '备注',
                  hintText: '记录补齐计划或考证信息',
                ),
              ),
              if (_error case final error?) ...<Widget>[
                SizedBox(height: tokens.spaceSm),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    error,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
                  ),
                ),
              ],
              SizedBox(height: tokens.spaceLg),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_editing ? '保存修改' : '创建套卡'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
