import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../app/app_theme.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/app_layout.dart';
import '../../../core/widgets/app_surface.dart';
import '../../purchases/domain/purchase_models.dart';
import '../data/dashboard_providers.dart';
import '../domain/dashboard_models.dart';

class SpendingCalendarScreen extends ConsumerStatefulWidget {
  const SpendingCalendarScreen({required this.initialMonth, super.key});

  final DateTime initialMonth;

  @override
  ConsumerState<SpendingCalendarScreen> createState() =>
      _SpendingCalendarScreenState();
}

class _SpendingCalendarScreenState
    extends ConsumerState<SpendingCalendarScreen> {
  late DateTime _month;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _month = DateTime(widget.initialMonth.year, widget.initialMonth.month);
  }

  @override
  Widget build(BuildContext context) {
    final monthData = ref.watch(spendingCalendarProvider(_month));
    return Scaffold(
      appBar: AppBar(title: const Text('消费日历')),
      body: monthData.when(
        loading: () => const Center(
          child: CircularProgressIndicator(semanticsLabel: '正在加载消费日历'),
        ),
        error: (error, stackTrace) => AppErrorState(
          icon: Icons.calendar_month_outlined,
          title: '消费日历暂时无法加载',
          description: error is AppFailure
              ? error.userMessage
              : '本地消费记录没有发生变化，请稍后重试。',
          actionLabel: '重试',
          onAction: () => ref.invalidate(spendingCalendarProvider(_month)),
        ),
        data: _buildContent,
      ),
    );
  }

  Widget _buildContent(SpendingCalendarMonth data) {
    final selectedDate = _resolvedSelectedDate(data);
    final selectedDay = data.dayFor(selectedDate);
    final tokens = context.tokens;
    return AppContentView(
      child: ListView(
        children: <Widget>[
          AppSurfaceCard(
            child: Row(
              children: <Widget>[
                IconButton.filled(
                  tooltip: '上个月',
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Expanded(
                  child: Text(
                    '${_month.year}年${_month.month.toString().padLeft(2, '0')}月',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton.filled(
                  tooltip: '下个月',
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.spaceSm),
          Row(
            children: <Widget>[
              Expanded(
                child: AppMetricCard(
                  label: '本月净消费',
                  value: _summaryAmount(data.totalMinorUnits),
                  icon: Icons.account_balance_wallet_outlined,
                  supportingText: '已计入退款抵扣',
                ),
              ),
              SizedBox(width: tokens.spaceSm),
              Expanded(
                child: AppMetricCard(
                  label: '消费记录',
                  value: '${data.purchaseCount}',
                  icon: Icons.receipt_long_outlined,
                  supportingText: '按有效消费日期统计',
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceLg),
          AppSurfaceCard(
            padding: EdgeInsets.all(tokens.spaceSm),
            child: Column(
              children: <Widget>[
                const _WeekdayHeader(),
                SizedBox(height: tokens.spaceXs),
                _CalendarGrid(
                  month: _month,
                  data: data,
                  selectedDate: selectedDate,
                  onSelected: _selectDate,
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.spaceLg),
          AppSectionHeader(
            title:
                '${selectedDate.month}月${selectedDate.day}日 · ${selectedDay?.purchaseCount ?? 0} 笔',
            icon: Icons.list_alt_outlined,
            subtitle: '当天的卡片消费与退款记录。',
          ),
          if (selectedDay == null)
            AppSurfaceCard(
              color: context.palette.surfaceMuted,
              child: const Row(
                children: <Widget>[
                  Icon(Icons.receipt_long_outlined),
                  SizedBox(width: 12),
                  Expanded(child: Text('这一天没有消费记录。')),
                ],
              ),
            )
          else
            AppSurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  for (
                    var index = 0;
                    index < selectedDay.entries.length;
                    index++
                  ) ...[
                    _SpendingEntryTile(entry: selectedDay.entries[index]),
                    if (index != selectedDay.entries.length - 1)
                      const Divider(indent: 16, endIndent: 16),
                  ],
                ],
              ),
            ),
          SizedBox(height: tokens.space2xl),
        ],
      ),
    );
  }

  DateTime _resolvedSelectedDate(SpendingCalendarMonth data) {
    final selected = _selectedDate;
    if (selected != null &&
        selected.year == _month.year &&
        selected.month == _month.month) {
      return selected;
    }
    final now = DateTime.now();
    if (now.year == _month.year && now.month == _month.month) {
      return DateTime(now.year, now.month, now.day);
    }
    if (data.days.isNotEmpty) return data.days.last.date;
    return DateTime(_month.year, _month.month, 1);
  }

  void _changeMonth(int offset) {
    setState(() {
      _month = DateTime(_month.year, _month.month + offset);
      _selectedDate = null;
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _month = DateTime(date.year, date.month);
      _selectedDate = DateTime(date.year, date.month, date.day);
    });
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (final label in <String>['周一', '周二', '周三', '周四', '周五', '周六', '周日'])
          Expanded(child: Center(child: Text(label))),
      ],
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.data,
    required this.selectedDate,
    required this.onSelected,
  });

  final DateTime month;
  final SpendingCalendarMonth data;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final start = first.subtract(Duration(days: first.weekday - 1));
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 42,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 78,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        final date = start.add(Duration(days: index));
        final day = data.dayFor(date);
        return _CalendarDayCell(
          date: date,
          inMonth: date.year == month.year && date.month == month.month,
          selected: _sameDay(date, selectedDate),
          minorUnits: day?.minorUnits,
          onTap: () => onSelected(date),
        );
      },
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.date,
    required this.inMonth,
    required this.selected,
    required this.minorUnits,
    required this.onTap,
  });

  final DateTime date;
  final bool inMonth;
  final bool selected;
  final int? minorUnits;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = context.palette.textSecondary;
    final amount = minorUnits;
    return Material(
      color: selected
          ? scheme.primaryContainer
          : inMonth
          ? context.palette.surfaceMuted
          : context.palette.surfaceMuted.withValues(alpha: 0.42),
      borderRadius: BorderRadius.circular(context.tokens.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 7),
          child: Column(
            children: <Widget>[
              Text(
                '${date.day}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: inMonth ? null : muted.withValues(alpha: 0.5),
                ),
              ),
              const Spacer(),
              if (amount != null)
                Text(
                  _compactSignedAmount(amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: amount >= 0 ? scheme.error : context.palette.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpendingEntryTile extends StatelessWidget {
  const _SpendingEntryTile({required this.entry});

  final SpendingCalendarEntry entry;

  @override
  Widget build(BuildContext context) {
    final isExpense = entry.minorUnits >= 0;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            (isExpense
                    ? Theme.of(context).colorScheme.error
                    : context.palette.success)
                .withValues(alpha: 0.12),
        child: Icon(
          isExpense ? Icons.shopping_bag_outlined : Icons.replay_rounded,
          color: isExpense
              ? Theme.of(context).colorScheme.error
              : context.palette.success,
        ),
      ),
      title: Text(entry.label),
      subtitle: Text(isExpense ? '消费' : '退款抵扣'),
      trailing: Text(
        _signedAmount(entry.minorUnits),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: isExpense
              ? Theme.of(context).colorScheme.error
              : context.palette.success,
          fontWeight: FontWeight.w700,
        ),
      ),
      onTap: entry.cardItemId == null
          ? null
          : () => context.push(cardDetailPath(entry.cardItemId!)),
    );
  }
}

bool _sameDay(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;

String _summaryAmount(int minorUnits) {
  final formatted = CurrencyAmount(
    minorUnits: minorUnits.abs(),
    currency: 'CNY',
  ).formatted;
  return minorUnits < 0 ? '-¥$formatted' : '¥$formatted';
}

String _signedAmount(int minorUnits) {
  final formatted = CurrencyAmount(
    minorUnits: minorUnits.abs(),
    currency: 'CNY',
  ).formatted;
  return minorUnits >= 0 ? '-¥$formatted' : '+¥$formatted';
}

String _compactSignedAmount(int minorUnits) {
  final formatted = CurrencyAmount(
    minorUnits: minorUnits.abs(),
    currency: 'CNY',
  ).formatted;
  return minorUnits >= 0 ? '-$formatted' : '+$formatted';
}
