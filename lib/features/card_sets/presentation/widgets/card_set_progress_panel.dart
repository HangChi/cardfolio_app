import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../domain/card_set_models.dart';

class CardSetProgressPanel extends StatelessWidget {
  const CardSetProgressPanel({
    required this.progress,
    required this.countKnown,
    super.key,
  });

  final CardSetProgress progress;
  final bool countKnown;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final fraction = progress.fraction;
    return Semantics(
      container: true,
      label: countKnown
          ? '套卡完成度 ${progress.ownedRequiredCount} / '
                '${progress.requiredMemberCount}'
          : '套卡总数未知，已拥有 ${progress.ownedMemberCount} 款',
      child: Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: EdgeInsets.all(tokens.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (countKnown && fraction != null) ...<Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${progress.ownedRequiredCount} / '
                        '${progress.requiredMemberCount}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    Text(
                      '${(fraction * 100).round()}%',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: tokens.spaceMd),
                LinearProgressIndicator(
                  value: fraction,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(tokens.radiusPill),
                  semanticsLabel: '套卡完成进度',
                  semanticsValue: '${(fraction * 100).round()}%',
                ),
                SizedBox(height: tokens.spaceMd),
                Wrap(
                  spacing: tokens.spaceSm,
                  runSpacing: tokens.spaceSm,
                  children: <Widget>[
                    _StatusPill(
                      icon: Icons.check_circle_outline,
                      label: '已拥有 ${progress.ownedRequiredCount}',
                    ),
                    _StatusPill(
                      icon: Icons.radio_button_unchecked,
                      label: '缺失 ${progress.missingRequiredCount}',
                    ),
                    _StatusPill(
                      icon: Icons.content_copy_outlined,
                      label: '重复卡片 ${progress.duplicateMemberCount} 张',
                    ),
                  ],
                ),
              ] else ...<Widget>[
                Text('总数未知', style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: tokens.spaceSm),
                Text('已拥有 ${progress.ownedMemberCount} 款'),
                SizedBox(height: tokens.spaceSm),
                Text(
                  '补充成员总数后可计算百分比和集齐状态。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.tokens.spaceSm,
        vertical: context.tokens.spaceXs,
      ),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(context.tokens.radiusPill),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: context.tokens.spaceXs),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
