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
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                children: <Widget>[
                  _CalendarPanel(
                    month: _month,
                    data: data,
                    selectedDate: selectedDate,
                    onPreviousMonth: () => _changeMonth(-1),
                    onNextMonth: () => _changeMonth(1),
                    onSelected: _selectDate,
                  ),
                  SizedBox(height: tokens.spaceLg),
                  _SelectedDayPanel(
                    selectedDate: selectedDate,
                    selectedDay: selectedDay,
                  ),
                  SizedBox(height: tokens.space2xl),
                ],
              ),
            ),
          ),
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

class _CalendarPanel extends StatelessWidget {
  const _CalendarPanel({
    required this.month,
    required this.data,
    required this.selectedDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelected,
  });

  final DateTime month;
  final SpendingCalendarMonth data;
  final DateTime selectedDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: context.palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          _MonthLedgerHeader(
            month: month,
            totalMinorUnits: data.totalMinorUnits,
            purchaseCount: data.purchaseCount,
            onPreviousMonth: onPreviousMonth,
            onNextMonth: onNextMonth,
          ),
          Divider(color: scheme.outlineVariant, height: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.spaceSm,
              tokens.spaceMd,
              tokens.spaceSm,
              tokens.spaceSm,
            ),
            child: Column(
              children: <Widget>[
                const _WeekdayHeader(),
                SizedBox(height: tokens.spaceSm),
                _CalendarGrid(
                  month: month,
                  data: data,
                  selectedDate: selectedDate,
                  onSelected: onSelected,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthLedgerHeader extends StatelessWidget {
  const _MonthLedgerHeader({
    required this.month,
    required this.totalMinorUnits,
    required this.purchaseCount,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final DateTime month;
  final int totalMinorUnits;
  final int purchaseCount;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.all(tokens.spaceMd),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton.filledTonal(
                tooltip: '上个月',
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      '${month.year}年',
                      style: textTheme.labelMedium?.copyWith(
                        color: context.palette.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${month.month.toString().padLeft(2, '0')}月',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: '下个月',
                onPressed: onNextMonth,
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceMd),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spaceMd,
              vertical: tokens.spaceSm + 2,
            ),
            decoration: BoxDecoration(
              color: context.palette.surfaceMuted.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(tokens.radiusMd),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '本月净消费',
                        style: textTheme.labelMedium?.copyWith(
                          color: context.palette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _signedAmount(totalMinorUnits),
                          style: textTheme.titleLarge?.copyWith(
                            color: _amountColor(context, totalMinorUnits),
                            fontWeight: FontWeight.w800,
                            fontFeatures: const <FontFeature>[
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 38, color: scheme.outlineVariant),
                SizedBox(width: tokens.spaceMd),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '$purchaseCount 笔',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                    Text(
                      '本月记录',
                      style: textTheme.labelSmall?.copyWith(
                        color: context.palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedDayPanel extends StatelessWidget {
  const _SelectedDayPanel({
    required this.selectedDate,
    required this.selectedDay,
  });

  final DateTime selectedDate;
  final SpendingDaySummary? selectedDay;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final day = selectedDay;
    final amount = day?.minorUnits ?? 0;
    return Material(
      color: context.palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(tokens.spaceMd),
            child: Row(
              children: <Widget>[
                _SelectedDateBadge(date: selectedDate),
                SizedBox(width: tokens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '当天明细',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${selectedDate.month}月${selectedDate.day}日 · ${_weekdayLabel(selectedDate)} · ${day?.purchaseCount ?? 0} 笔',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: tokens.spaceSm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '当日净额',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context.palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 104),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          _signedAmount(amount),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: _amountColor(context, amount),
                                fontWeight: FontWeight.w800,
                                fontFeatures: const <FontFeature>[
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: scheme.outlineVariant, height: 1),
          if (day == null)
            Padding(
              padding: EdgeInsets.all(tokens.spaceLg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.receipt_long_outlined,
                    color: context.palette.textSecondary,
                  ),
                  SizedBox(width: tokens.spaceSm),
                  Text(
                    '这一天还没有消费记录',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.palette.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: <Widget>[
                for (var index = 0; index < day.entries.length; index++) ...[
                  _SpendingEntryTile(entry: day.entries[index]),
                  if (index != day.entries.length - 1)
                    Divider(
                      color: scheme.outlineVariant,
                      indent: 72,
                      endIndent: tokens.spaceMd,
                      height: 1,
                    ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _SelectedDateBadge extends StatelessWidget {
  const _SelectedDateBadge({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 54,
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(context.tokens.radiusMd),
      ),
      child: Column(
        children: <Widget>[
          Text(
            '${date.day}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
              height: 1,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _weekdayLabel(date),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: scheme.primary),
          ),
        ],
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    const labels = <String>['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return Row(
      children: <Widget>[
        for (var index = 0; index < labels.length; index++)
          Expanded(
            child: Center(
              child: Text(
                labels[index],
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: index >= 5
                      ? context.palette.accent
                      : context.palette.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
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
    final now = DateTime.now();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 42,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 68,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemBuilder: (context, index) {
        final date = start.add(Duration(days: index));
        final day = data.dayFor(date);
        return _CalendarDayCell(
          date: date,
          inMonth: date.year == month.year && date.month == month.month,
          selected: _sameDay(date, selectedDate),
          today: _sameDay(date, now),
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
    required this.today,
    required this.minorUnits,
    required this.onTap,
  });

  final DateTime date;
  final bool inMonth;
  final bool selected;
  final bool today;
  final int? minorUnits;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.tokens;
    final muted = context.palette.textSecondary;
    final amount = minorUnits;
    final foreground = selected
        ? scheme.onPrimary
        : inMonth
        ? context.palette.textPrimary
        : muted.withValues(alpha: 0.38);
    final fill = selected
        ? scheme.primary
        : inMonth
        ? context.palette.surfaceMuted.withValues(
            alpha: amount == null ? 0.5 : 0.82,
          )
        : Colors.transparent;
    final borderColor = selected
        ? scheme.primary
        : today
        ? scheme.primary
        : scheme.outlineVariant.withValues(alpha: inMonth ? 0.44 : 0.18);
    final amountColor = selected
        ? scheme.onPrimary
        : amount == null
        ? muted
        : _amountColor(context, amount);
    final semanticsAmount = amount == null ? '无消费记录' : _signedAmount(amount);
    return Semantics(
      button: true,
      selected: selected,
      label: '${date.month}月${date.day}日，$semanticsAmount',
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : tokens.motionFast,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: borderColor, width: today ? 1.4 : 1),
          boxShadow: selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: context.palette.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 7),
              child: Column(
                children: <Widget>[
                  Text(
                    '${date.day}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: today && !selected
                          ? context.palette.accent
                          : foreground,
                      fontWeight: selected || today
                          ? FontWeight.w800
                          : FontWeight.w600,
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (amount != null)
                    Text(
                      _compactSignedAmount(amount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: amountColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    )
                  else
                    const SizedBox(height: 12),
                ],
              ),
            ),
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
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _amountColor(
            context,
            entry.minorUnits,
          ).withValues(alpha: 0.11),
          borderRadius: BorderRadius.circular(context.tokens.radiusMd),
        ),
        child: Icon(
          isExpense ? Icons.shopping_bag_outlined : Icons.replay_rounded,
          size: context.tokens.iconSm,
          color: _amountColor(context, entry.minorUnits),
        ),
      ),
      title: Text(
        entry.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Text(
        isExpense ? '支出${entry.cardItemId == null ? '' : ' · 查看卡片'}' : '退款抵扣',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            _signedAmount(entry.minorUnits),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: _amountColor(context, entry.minorUnits),
              fontWeight: FontWeight.w800,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          if (entry.cardItemId != null) ...<Widget>[
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: context.tokens.iconSm,
              color: context.palette.textSecondary,
            ),
          ],
        ],
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.tokens.spaceMd,
        vertical: context.tokens.spaceXs,
      ),
      minVerticalPadding: context.tokens.spaceSm,
      onTap: entry.cardItemId == null
          ? null
          : () => context.push(cardDetailPath(entry.cardItemId!)),
    );
  }
}

Color _amountColor(BuildContext context, int minorUnits) {
  if (minorUnits > 0) return Theme.of(context).colorScheme.error;
  if (minorUnits < 0) return context.palette.success;
  return context.palette.textSecondary;
}

String _weekdayLabel(DateTime date) {
  const labels = <String>['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  return labels[date.weekday - 1];
}

bool _sameDay(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;

String _signedAmount(int minorUnits) {
  final formatted = CurrencyAmount(
    minorUnits: minorUnits.abs(),
    currency: 'CNY',
  ).formatted;
  if (minorUnits > 0) return '-¥$formatted';
  if (minorUnits < 0) return '+¥$formatted';
  return '¥$formatted';
}

String _compactSignedAmount(int minorUnits) {
  final formatted = CurrencyAmount(
    minorUnits: minorUnits.abs(),
    currency: 'CNY',
  ).formatted;
  if (minorUnits > 0) return '-$formatted';
  if (minorUnits < 0) return '+$formatted';
  return formatted;
}
