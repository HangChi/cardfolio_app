import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../app/app_theme.dart';
import '../../../card_sets/presentation/library/card_set_collection_view.dart';
import '../../../organization/data/organization_providers.dart';
import '../../../organization/domain/organization_models.dart';
import '../../../organization/presentation/series/series_collection_view.dart';
import '../../../purchases/domain/purchase_models.dart';
import '../create/create_card_controller.dart';
import '../widgets/card_image.dart';

/// 卡片、套卡与系列的统一收藏入口。
class CardLibraryScreen extends ConsumerStatefulWidget {
  const CardLibraryScreen({super.key});

  @override
  ConsumerState<CardLibraryScreen> createState() => _CardLibraryScreenState();
}

class _CardLibraryScreenState extends ConsumerState<CardLibraryScreen> {
  late final TextEditingController _searchController;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(cardLibraryQueryProvider).searchText,
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _startImport() async {
    final picked = await ref
        .read(createCardControllerProvider.notifier)
        .pickImage();
    if (!mounted) return;

    if (picked) {
      context.push(createCardPath);
      return;
    }

    final failure = ref.read(createCardControllerProvider).failure;
    if (failure != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
  }

  void _search(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      ref.read(cardLibraryQueryProvider.notifier).setSearchText(value);
    });
  }

  Future<void> _openFilters(CardFilterFacets facets) async {
    final result = await showModalBottomSheet<CardLibraryQuery>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _FilterSheet(
        initialQuery: ref.read(cardLibraryQueryProvider),
        facets: facets,
      ),
    );
    if (result != null) {
      ref.read(cardLibraryQueryProvider.notifier).replace(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(createCardControllerProvider);
    final cards = ref.watch(organizedCardListProvider);
    final facets = ref.watch(cardFilterFacetsProvider);
    final query = ref.watch(cardLibraryQueryProvider);
    final tokens = context.tokens;

    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.spaceLg,
                tokens.spaceLg,
                tokens.spaceLg,
                tokens.spaceSm,
              ),
              child: Text(
                '我的收藏',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      key: const Key('library-search-input'),
                      controller: _searchController,
                      onChanged: _search,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: '搜索名称、编号、城市、发行方、备注或标签',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: '清除搜索',
                                onPressed: () {
                                  _searchDebounce?.cancel();
                                  _searchController.clear();
                                  ref
                                      .read(cardLibraryQueryProvider.notifier)
                                      .setSearchText(null);
                                  setState(() {});
                                },
                                icon: const Icon(Icons.close),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(width: tokens.spaceSm),
                  IconButton.filledTonal(
                    key: const Key('open-library-filters'),
                    tooltip: '筛选',
                    onPressed: facets.value == null
                        ? null
                        : () => _openFilters(facets.value!),
                    icon: Badge(
                      isLabelVisible: _filterCount(query) > 0,
                      label: Text('${_filterCount(query)}'),
                      child: const Icon(Icons.tune),
                    ),
                  ),
                  PopupMenuButton<_SortOption>(
                    key: const Key('library-sort-menu'),
                    tooltip: '排序',
                    icon: const Icon(Icons.sort),
                    onSelected: (option) {
                      ref
                          .read(cardLibraryQueryProvider.notifier)
                          .replace(
                            query.copyWith(
                              sortField: option.field,
                              sortDirection: option.direction,
                            ),
                          );
                    },
                    itemBuilder: (context) => <PopupMenuEntry<_SortOption>>[
                      for (final option in _SortOption.values)
                        PopupMenuItem<_SortOption>(
                          value: option,
                          child: Text(option.label),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (_activeFilterLabels(query).isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.fromLTRB(
                  tokens.spaceLg,
                  tokens.spaceSm,
                  tokens.spaceLg,
                  0,
                ),
                child: Row(
                  children: <Widget>[
                    for (final label in _activeFilterLabels(query))
                      Padding(
                        padding: EdgeInsets.only(right: tokens.spaceXs),
                        child: Chip(label: Text(label)),
                      ),
                    TextButton(
                      onPressed: () => ref
                          .read(cardLibraryQueryProvider.notifier)
                          .clearFilters(),
                      child: const Text('清除筛选'),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
              child: const TabBar(
                tabs: <Widget>[
                  Tab(text: '卡片'),
                  Tab(text: '套卡'),
                  Tab(text: '系列'),
                ],
              ),
            ),
            SizedBox(height: tokens.spaceSm),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  cards.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: '正在加载收藏',
                      ),
                    ),
                    error: (error, stackTrace) => _LibraryError(
                      onRetry: () => ref.invalidate(organizedCardListProvider),
                    ),
                    data: (items) => items.isEmpty && query.isFiltering
                        ? _NoFilterResults(
                            onReset: () {
                              _searchDebounce?.cancel();
                              _searchController.clear();
                              ref
                                  .read(cardLibraryQueryProvider.notifier)
                                  .clearAll();
                              setState(() {});
                            },
                          )
                        : items.isEmpty
                        ? _EmptyLibrary(onImport: _startImport)
                        : _CardList(items: items),
                  ),
                  const CardSetCollectionView(),
                  const SeriesCollectionView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initialQuery, required this.facets});

  final CardLibraryQuery initialQuery;
  final CardFilterFacets facets;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _cardType = widget.initialQuery.cardType;
  late String? _city = widget.initialQuery.city;
  late int? _year = widget.initialQuery.year;
  late final Set<String> _tagIds = widget.initialQuery.tagIds.toSet();
  late TagMatchMode _tagMode = widget.initialQuery.tagMatchMode;
  late SetMembershipFilter _membership = widget.initialQuery.setMembership;
  late bool? _duplicate = widget.initialQuery.duplicate;
  late bool? _needsCompletion = widget.initialQuery.needsCompletion;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      maxChildSize: 0.96,
      builder: (context, scrollController) => Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.spaceLg,
              tokens.spaceMd,
              tokens.spaceSm,
              tokens.spaceSm,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '筛选卡片',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(onPressed: _reset, child: const Text('重置')),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
              children: <Widget>[
                _DropdownFilter<String>(
                  label: '卡片类型',
                  value: _cardType,
                  values: widget.facets.cardTypes,
                  onChanged: (value) => setState(() => _cardType = value),
                ),
                _DropdownFilter<String>(
                  label: '城市',
                  value: _city,
                  values: widget.facets.cities,
                  onChanged: (value) => setState(() => _city = value),
                ),
                _DropdownFilter<int>(
                  label: '发行年份',
                  value: _year,
                  values: widget.facets.years,
                  onChanged: (value) => setState(() => _year = value),
                ),
                const _FilterHeading('标签'),
                Wrap(
                  spacing: tokens.spaceSm,
                  runSpacing: tokens.spaceXs,
                  children: <Widget>[
                    for (final tag in widget.facets.tags)
                      FilterChip(
                        key: Key('filter-tag-${tag.id}'),
                        label: Text('${tag.name} ${tag.cardCount}'),
                        selected: _tagIds.contains(tag.id),
                        onSelected: (selected) => setState(() {
                          if (selected) {
                            _tagIds.add(tag.id);
                          } else {
                            _tagIds.remove(tag.id);
                          }
                        }),
                      ),
                  ],
                ),
                if (_tagIds.length > 1)
                  SegmentedButton<TagMatchMode>(
                    segments: const <ButtonSegment<TagMatchMode>>[
                      ButtonSegment(value: TagMatchMode.any, label: Text('任一')),
                      ButtonSegment(value: TagMatchMode.all, label: Text('全部')),
                    ],
                    selected: <TagMatchMode>{_tagMode},
                    onSelectionChanged: (value) =>
                        setState(() => _tagMode = value.single),
                  ),
                const _FilterHeading('套卡状态'),
                Wrap(
                  spacing: tokens.spaceSm,
                  children: <Widget>[
                    for (final value in SetMembershipFilter.values)
                      ChoiceChip(
                        key: Key('filter-set-${value.name}'),
                        label: Text(_membershipLabel(value)),
                        selected: _membership == value,
                        onSelected: (_) => setState(() => _membership = value),
                      ),
                  ],
                ),
                const _FilterHeading('重复卡'),
                _NullableBoolChoices(
                  value: _duplicate,
                  trueLabel: '仅重复卡',
                  falseLabel: '排除重复卡',
                  onChanged: (value) => setState(() => _duplicate = value),
                ),
                const _FilterHeading('待完善'),
                _NullableBoolChoices(
                  value: _needsCompletion,
                  trueLabel: '仅待完善',
                  falseLabel: '仅已完善',
                  onChanged: (value) =>
                      setState(() => _needsCompletion = value),
                ),
                SizedBox(height: tokens.spaceXl),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.spaceLg,
              tokens.spaceSm,
              tokens.spaceLg,
              tokens.spaceLg,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('apply-library-filters'),
                onPressed: _apply,
                child: const Text('应用筛选'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _reset() {
    setState(() {
      _cardType = null;
      _city = null;
      _year = null;
      _tagIds.clear();
      _tagMode = TagMatchMode.any;
      _membership = SetMembershipFilter.any;
      _duplicate = null;
      _needsCompletion = null;
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      widget.initialQuery.copyWith(
        cardType: _cardType,
        clearCardType: _cardType == null,
        city: _city,
        clearCity: _city == null,
        year: _year,
        clearYear: _year == null,
        tagIds: _tagIds.toList(growable: false),
        tagMatchMode: _tagMode,
        setMembership: _membership,
        duplicate: _duplicate,
        clearDuplicate: _duplicate == null,
        needsCompletion: _needsCompletion,
        clearNeedsCompletion: _needsCompletion == null,
      ),
    );
  }
}

class _DropdownFilter<T extends Object> extends StatelessWidget {
  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> values;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.tokens.spaceMd),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: <DropdownMenuItem<T>>[
          DropdownMenuItem<T>(value: null, child: const Text('不限')),
          for (final item in values)
            DropdownMenuItem<T>(value: item, child: Text('$item')),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _NullableBoolChoices extends StatelessWidget {
  const _NullableBoolChoices({
    required this.value,
    required this.trueLabel,
    required this.falseLabel,
    required this.onChanged,
  });

  final bool? value;
  final String trueLabel;
  final String falseLabel;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.tokens.spaceSm,
      children: <Widget>[
        ChoiceChip(
          label: const Text('不限'),
          selected: value == null,
          onSelected: (_) => onChanged(null),
        ),
        ChoiceChip(
          label: Text(trueLabel),
          selected: value == true,
          onSelected: (_) => onChanged(true),
        ),
        ChoiceChip(
          label: Text(falseLabel),
          selected: value == false,
          onSelected: (_) => onChanged(false),
        ),
      ],
    );
  }
}

class _FilterHeading extends StatelessWidget {
  const _FilterHeading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: context.tokens.spaceMd,
        bottom: context.tokens.spaceSm,
      ),
      child: Text(label, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.onImport});

  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 144,
              height: 104,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(tokens.radiusLg),
              ),
              child: const CardImage.placeholder(semanticLabel: '空收藏示意图'),
            ),
            SizedBox(height: tokens.spaceLg),
            Text(
              '让每一张交通卡，都有迹可循',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: tokens.spaceSm),
            Text(
              '选择一张卡片图片，补充名称后即可保存在本地。',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: tokens.spaceLg),
            FilledButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.file_upload_outlined),
              label: const Text('从相册导入'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoFilterResults extends StatelessWidget {
  const _NoFilterResults({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.search_off, size: 48),
          SizedBox(height: context.tokens.spaceMd),
          Text('没有符合条件的卡片', style: Theme.of(context).textTheme.titleMedium),
          TextButton(onPressed: onReset, child: const Text('清除全部条件')),
        ],
      ),
    );
  }
}

class _LibraryError extends StatelessWidget {
  const _LibraryError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, color: AppColors.error, size: 40),
            SizedBox(height: context.tokens.spaceMd),
            const Text('收藏暂时无法加载'),
            SizedBox(height: context.tokens.spaceMd),
            FilledButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}

class _CardList extends StatelessWidget {
  const _CardList({required this.items});

  final List<OrganizedCardSummary> items;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        tokens.spaceLg,
        0,
        tokens.spaceLg,
        tokens.spaceLg,
      ),
      itemCount: items.length,
      separatorBuilder: (context, index) => SizedBox(height: tokens.spaceMd),
      itemBuilder: (context, index) => _CardTile(card: items[index]),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.card});

  final OrganizedCardSummary card;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final coverPath = card.coverRelativePath;
    final metadata = <String>[
      ?card.cardType,
      ?card.city,
      ?card.issuedAt?.toIsoString(),
      '${card.quantity} 张',
      if (card.acquisitionCostCurrency != null &&
          card.acquisitionCostMinor != null)
        '成本 ${card.acquisitionCostCurrency} '
            '${CurrencyAmount(minorUnits: card.acquisitionCostMinor!, currency: card.acquisitionCostCurrency!).formatted}',
    ].join(' · ');

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
      ),
      child: InkWell(
        onTap: () => context.push(cardDetailPath(card.cardItemId)),
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        child: Padding(
          padding: EdgeInsets.all(tokens.spaceMd),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 104,
                height: 72,
                child: coverPath != null
                    ? CardImage.managed(
                        relativePath: coverPath,
                        semanticLabel: '${card.name}封面',
                      )
                    : CardImage.placeholder(semanticLabel: '${card.name}封面'),
              ),
              SizedBox(width: tokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            card.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (card.needsCompletion)
                          const Tooltip(
                            message: '待完善',
                            child: Icon(
                              Icons.pending_outlined,
                              size: 18,
                              color: AppColors.warning,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: tokens.spaceXs),
                    Text(
                      metadata,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (card.tags.isNotEmpty) ...<Widget>[
                      SizedBox(height: tokens.spaceXs),
                      Wrap(
                        spacing: tokens.spaceXs,
                        children: <Widget>[
                          for (final tag in card.tags.take(3))
                            Text(
                              '#${tag.name}',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppColors.primary),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

enum _SortOption {
  newest('最近添加', CardSortField.createdAt, SortDirection.descending),
  oldest('最早添加', CardSortField.createdAt, SortDirection.ascending),
  issuedNewest('发行日期：新到旧', CardSortField.issuedAt, SortDirection.descending),
  acquiredNewest(
    '入手日期：新到旧',
    CardSortField.acquiredAt,
    SortDirection.descending,
  ),
  nameAscending('名称 A–Z', CardSortField.name, SortDirection.ascending),
  nameDescending('名称 Z–A', CardSortField.name, SortDirection.descending),
  costDescending(
    '入手成本：按币种高到低',
    CardSortField.acquisitionCost,
    SortDirection.descending,
  ),
  costAscending(
    '入手成本：按币种低到高',
    CardSortField.acquisitionCost,
    SortDirection.ascending,
  );

  const _SortOption(this.label, this.field, this.direction);

  final String label;
  final CardSortField field;
  final SortDirection direction;
}

int _filterCount(CardLibraryQuery query) {
  var count = 0;
  if (query.cardType != null) count++;
  if (query.city != null) count++;
  if (query.year != null) count++;
  if (query.tagIds.isNotEmpty) count++;
  if (query.setMembership != SetMembershipFilter.any) count++;
  if (query.duplicate != null) count++;
  if (query.needsCompletion != null) count++;
  return count;
}

List<String> _activeFilterLabels(CardLibraryQuery query) {
  return <String>[
    if (query.cardType != null) '类型：${query.cardType}',
    if (query.city != null) '城市：${query.city}',
    if (query.year != null) '年份：${query.year}',
    if (query.tagIds.isNotEmpty)
      '标签：${query.tagMatchMode == TagMatchMode.any ? '任一' : '全部'} '
          '${query.tagIds.length}',
    if (query.setMembership != SetMembershipFilter.any)
      _membershipLabel(query.setMembership),
    if (query.duplicate != null) query.duplicate! ? '重复卡' : '非重复卡',
    if (query.needsCompletion != null) query.needsCompletion! ? '待完善' : '已完善',
  ];
}

String _membershipLabel(SetMembershipFilter value) => switch (value) {
  SetMembershipFilter.any => '不限',
  SetMembershipFilter.inSet => '已加入套卡',
  SetMembershipFilter.notInSet => '未加入套卡',
};
