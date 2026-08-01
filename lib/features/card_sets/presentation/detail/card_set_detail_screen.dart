import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../app/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../cards/data/card_providers.dart';
import '../../../cards/presentation/widgets/card_image.dart';
import '../../data/card_set_providers.dart';
import '../../domain/card_set_models.dart';
import '../widgets/card_set_progress_panel.dart';

class CardSetDetailScreen extends ConsumerStatefulWidget {
  const CardSetDetailScreen({required this.setId, super.key});

  final String setId;

  @override
  ConsumerState<CardSetDetailScreen> createState() =>
      _CardSetDetailScreenState();
}

class _CardSetDetailScreenState extends ConsumerState<CardSetDetailScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() operation) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await operation();
    } on AppFailure catch (failure) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.userMessage)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(cardSetDetailProvider(widget.setId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('套卡详情'),
        actions: <Widget>[
          IconButton(
            tooltip: '编辑套卡资料',
            onPressed: _busy
                ? null
                : () => context.push(editCardSetPath(widget.setId)),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: detail.when(
        loading: () => const Center(
          child: CircularProgressIndicator(semanticsLabel: '正在加载套卡'),
        ),
        error: (error, stackTrace) => _DetailError(
          onRetry: () => ref.invalidate(cardSetDetailProvider(widget.setId)),
        ),
        data: (set) => set == null
            ? const _MissingSet()
            : _DetailBody(
                set: set,
                busy: _busy,
                onAdd: () => _showAddOptions(set),
                onSetCover: () => _showCoverPicker(set),
                onMemberAction: (member, action) =>
                    _handleMemberAction(set, member, action),
              ),
      ),
    );
  }

  Future<void> _showAddOptions(CardSetDetail set) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: sheetContext.tokens.spaceMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.collections_bookmark_outlined),
                title: const Text('关联已有卡片'),
                subtitle: const Text('从收藏中选择尚未加入的款式'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showExistingCandidates(set);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_card_outlined),
                title: const Text('定义缺失成员'),
                subtitle: const Text('先记录尚未拥有的预期款式'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showMissingMemberDialog(set);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCoverPicker(CardSetDetail set) async {
    final candidates = set.members
        .where((member) => member.coverImageId != null)
        .toList(growable: false);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: candidates.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Text('成员还没有可用的卡片封面。'),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: candidates.length,
                itemBuilder: (context, index) {
                  final member = candidates[index];
                  return ListTile(
                    leading: SizedBox(
                      width: 64,
                      height: 44,
                      child: member.coverRelativePath == null
                          ? CardImage.placeholder(
                              semanticLabel: '${member.name}封面',
                            )
                          : CardImage.managed(
                              relativePath: member.coverRelativePath!,
                              semanticLabel: '${member.name}封面',
                            ),
                    ),
                    title: Text(member.name),
                    trailing: member.coverImageId == set.coverImageId
                        ? const Icon(Icons.check_circle)
                        : null,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _run(
                        () => ref
                            .read(cardSetRepositoryProvider)
                            .setCover(
                              setId: set.id,
                              imageId: member.coverImageId!,
                            ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  Future<void> _showExistingCandidates(CardSetDetail set) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Consumer(
        builder: (context, ref, child) {
          final candidates = ref.watch(cardSetCandidatesProvider(set.id));
          return SafeArea(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 520),
              child: candidates.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(semanticsLabel: '正在加载候选卡片'),
                ),
                error: (error, stackTrace) =>
                    const Center(child: Text('候选卡片暂时无法加载')),
                data: (items) => items.isEmpty
                    ? const Center(child: Text('没有可关联的卡片款式'))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final candidate = items[index];
                          return ListTile(
                            title: Text(candidate.name),
                            subtitle: Text('已拥有 ${candidate.ownedQuantity} 张'),
                            onTap: () {
                              Navigator.pop(sheetContext);
                              final ids = ref.read(idGeneratorProvider);
                              _run(
                                () => ref
                                    .read(cardSetRepositoryProvider)
                                    .addMember(
                                      AddCardSetMemberRequest.existing(
                                        id: ids.newId(),
                                        setId: set.id,
                                        definitionId: candidate.definitionId,
                                      ),
                                    ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showMissingMemberDialog(CardSetDetail set) async {
    final input = await showDialog<_MissingMemberInput>(
      context: context,
      builder: (dialogContext) => const _MissingMemberDialog(),
    );
    if (input == null) return;
    final ids = ref.read(idGeneratorProvider);
    await _run(
      () => ref
          .read(cardSetRepositoryProvider)
          .addMember(
            AddCardSetMemberRequest.missing(
              id: ids.newId(),
              setId: set.id,
              definitionId: ids.newId(),
              definitionName: input.name,
              memberNo: input.number,
              required: input.required,
            ),
          ),
    );
  }

  Future<void> _handleMemberAction(
    CardSetDetail set,
    CardSetMemberDetail member,
    _MemberAction action,
  ) async {
    switch (action) {
      case _MemberAction.edit:
        await _editMember(set, member);
      case _MemberAction.moveUp:
        await _move(set, member, -1);
      case _MemberAction.moveDown:
        await _move(set, member, 1);
      case _MemberAction.cover:
        final imageId = member.coverImageId;
        if (imageId != null) {
          await _run(
            () => ref
                .read(cardSetRepositoryProvider)
                .setCover(setId: set.id, imageId: imageId),
          );
        }
      case _MemberAction.remove:
        await _removeMember(set, member);
    }
  }

  Future<void> _editMember(
    CardSetDetail set,
    CardSetMemberDetail member,
  ) async {
    final input = await showDialog<_EditMemberInput>(
      context: context,
      builder: (dialogContext) => _EditMemberDialog(
        memberName: member.name,
        memberNo: member.memberNo,
        required: member.required,
      ),
    );
    if (input == null) return;
    await _run(
      () => ref
          .read(cardSetRepositoryProvider)
          .updateMember(
            UpdateCardSetMemberRequest(
              setId: set.id,
              memberId: member.id,
              required: input.required,
              memberNo: input.number,
            ),
          ),
    );
  }

  Future<void> _move(
    CardSetDetail set,
    CardSetMemberDetail member,
    int delta,
  ) async {
    final index = set.members.indexWhere((entry) => entry.id == member.id);
    final target = index + delta;
    if (index < 0 || target < 0 || target >= set.members.length) return;
    final ids = set.members.map((entry) => entry.id).toList(growable: true);
    final moved = ids.removeAt(index);
    ids.insert(target, moved);
    await _run(
      () => ref
          .read(cardSetRepositoryProvider)
          .reorderMembers(setId: set.id, orderedMemberIds: ids),
    );
  }

  Future<void> _removeMember(
    CardSetDetail set,
    CardSetMemberDetail member,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('移除套卡成员？'),
        content: Text('“${member.name}”将从成员清单移除，卡片本身不会删除。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('移除成员'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _run(
        () => ref
            .read(cardSetRepositoryProvider)
            .removeMember(setId: set.id, memberId: member.id),
      );
    }
  }
}

final class _MissingMemberInput {
  const _MissingMemberInput({
    required this.name,
    required this.number,
    required this.required,
  });

  final String name;
  final String number;
  final bool required;
}

class _MissingMemberDialog extends StatefulWidget {
  const _MissingMemberDialog();

  @override
  State<_MissingMemberDialog> createState() => _MissingMemberDialogState();
}

class _MissingMemberDialogState extends State<_MissingMemberDialog> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _number = TextEditingController();
  bool _required = true;

  @override
  void dispose() {
    _name.dispose();
    _number.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('定义缺失成员'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              key: const Key('missing-member-name'),
              controller: _name,
              decoration: const InputDecoration(labelText: '成员名称 *'),
            ),
            SizedBox(height: context.tokens.spaceMd),
            TextField(
              key: const Key('missing-member-number'),
              controller: _number,
              decoration: const InputDecoration(labelText: '成员编号'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('必需成员'),
              value: _required,
              onChanged: (value) => setState(() => _required = value),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
          onPressed: () => Navigator.pop(
            context,
            _MissingMemberInput(
              name: _name.text,
              number: _number.text,
              required: _required,
            ),
          ),
          child: const Text('添加缺失成员'),
        ),
      ],
    );
  }
}

final class _EditMemberInput {
  const _EditMemberInput({required this.number, required this.required});

  final String number;
  final bool required;
}

class _EditMemberDialog extends StatefulWidget {
  const _EditMemberDialog({
    required this.memberName,
    required this.memberNo,
    required this.required,
  });

  final String memberName;
  final String? memberNo;
  final bool required;

  @override
  State<_EditMemberDialog> createState() => _EditMemberDialogState();
}

class _EditMemberDialogState extends State<_EditMemberDialog> {
  late final TextEditingController _number;
  late bool _required;

  @override
  void initState() {
    super.initState();
    _number = TextEditingController(text: widget.memberNo);
    _required = widget.required;
  }

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('编辑 ${widget.memberName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _number,
            decoration: const InputDecoration(labelText: '成员编号'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('必需成员'),
            value: _required,
            onChanged: (value) => setState(() => _required = value),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
          onPressed: () => Navigator.pop(
            context,
            _EditMemberInput(number: _number.text, required: _required),
          ),
          child: const Text('保存'),
        ),
      ],
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.set,
    required this.busy,
    required this.onAdd,
    required this.onSetCover,
    required this.onMemberAction,
  });

  final CardSetDetail set;
  final bool busy;
  final VoidCallback onAdd;
  final VoidCallback onSetCover;
  final void Function(CardSetMemberDetail, _MemberAction) onMemberAction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SafeArea(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              tokens.spaceLg,
              tokens.spaceMd,
              tokens.spaceLg,
              tokens.spaceLg,
            ),
            sliver: SliverList.list(
              children: <Widget>[
                Text(
                  set.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: tokens.spaceMd),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: busy ? null : onSetCover,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(
                          height: 180,
                          child: set.coverRelativePath == null
                              ? CardImage.placeholder(
                                  semanticLabel: '${set.name}套卡封面',
                                )
                              : CardImage.managed(
                                  relativePath: set.coverRelativePath!,
                                  semanticLabel: '${set.name}套卡封面',
                                ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.image_outlined),
                          title: Text(
                            set.coverRelativePath == null ? '设置套卡封面' : '更换套卡封面',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),
                ),
                if (set.issueInfo case final issue?) ...<Widget>[
                  SizedBox(height: tokens.spaceSm),
                  Text(issue),
                ],
                SizedBox(height: tokens.spaceLg),
                CardSetProgressPanel(
                  progress: set.progress,
                  countKnown: set.countKnown,
                ),
                SizedBox(height: tokens.spaceLg),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '成员清单',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      onPressed: busy ? null : onAdd,
                      icon: const Icon(Icons.add),
                      label: const Text('添加成员'),
                    ),
                  ],
                ),
                SizedBox(height: tokens.spaceMd),
                if (set.members.isEmpty)
                  const _EmptyMembers()
                else
                  for (var index = 0; index < set.members.length; index++)
                    _MemberTrackTile(
                      member: set.members[index],
                      isFirst: index == 0,
                      isLast: index == set.members.length - 1,
                      busy: busy,
                      onAction: (action) =>
                          onMemberAction(set.members[index], action),
                    ),
                if (set.notes case final notes?) ...<Widget>[
                  SizedBox(height: tokens.spaceLg),
                  Text('备注', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: tokens.spaceSm),
                  Text(notes),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberTrackTile extends StatelessWidget {
  const _MemberTrackTile({
    required this.member,
    required this.isFirst,
    required this.isLast,
    required this.busy,
    required this.onAction,
  });

  final CardSetMemberDetail member;
  final bool isFirst;
  final bool isLast;
  final bool busy;
  final ValueChanged<_MemberAction> onAction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final status = member.isDuplicate
        ? '已拥有 ${member.ownedQuantity} 张 · 重复 ${member.ownedQuantity - 1} 张'
        : member.isOwned
        ? '已拥有'
        : '缺失';
    final statusColor = member.isOwned ? AppColors.primary : AppColors.warning;
    return Semantics(
      container: true,
      label: '${member.name}，${member.required ? '必需成员' : '非必需成员'}，$status',
      child: Padding(
        padding: EdgeInsets.only(bottom: tokens.spaceMd),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(tokens.spaceMd),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 96,
                  height: 68,
                  child: member.coverRelativePath == null
                      ? CardImage.placeholder(
                          semanticLabel: '${member.name}卡片封面',
                        )
                      : CardImage.managed(
                          relativePath: member.coverRelativePath!,
                          semanticLabel: '${member.name}卡片封面',
                        ),
                ),
                SizedBox(width: tokens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        member.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: tokens.spaceXs),
                      Text(
                        '${member.memberNo ?? '未编号'} · '
                        '${member.required ? '必需' : '非必需'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(height: tokens.spaceXs),
                      Text(status, style: TextStyle(color: statusColor)),
                    ],
                  ),
                ),
                PopupMenuButton<_MemberAction>(
                  enabled: !busy,
                  tooltip: '管理${member.name}',
                  onSelected: onAction,
                  itemBuilder: (context) => <PopupMenuEntry<_MemberAction>>[
                    const PopupMenuItem(
                      value: _MemberAction.edit,
                      child: Text('编辑编号与必需性'),
                    ),
                    PopupMenuItem(
                      value: _MemberAction.moveUp,
                      enabled: !isFirst,
                      child: const Text('前移'),
                    ),
                    PopupMenuItem(
                      value: _MemberAction.moveDown,
                      enabled: !isLast,
                      child: const Text('后移'),
                    ),
                    if (member.coverImageId != null)
                      const PopupMenuItem(
                        value: _MemberAction.cover,
                        child: Text('设为套卡封面'),
                      ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: _MemberAction.remove,
                      child: Text('移除成员'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _MemberAction { edit, moveUp, moveDown, cover, remove }

class _EmptyMembers extends StatelessWidget {
  const _EmptyMembers();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceLg),
        child: const Text(
          '还没有成员。可关联收藏中的卡片，也可先定义尚未拥有的款式。',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('套卡暂时无法加载'),
          SizedBox(height: context.tokens.spaceMd),
          FilledButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}

class _MissingSet extends StatelessWidget {
  const _MissingSet();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('这套卡不存在或已被删除'),
          SizedBox(height: context.tokens.spaceMd),
          FilledButton(
            onPressed: () => context.go(libraryPath),
            child: const Text('返回收藏'),
          ),
        ],
      ),
    );
  }
}
