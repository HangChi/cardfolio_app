import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

/// 为手机和宽屏提供一致的内容宽度与页面边距。
class AppContentView extends StatelessWidget {
  const AppContentView({
    required this.child,
    this.padding,
    this.safeTop = false,
    this.safeBottom = true,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool safeTop;
  final bool safeBottom;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SafeArea(
      top: safeTop,
      bottom: safeBottom,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontal = constraints.maxWidth >= 720
              ? tokens.spaceXl
              : tokens.spaceMd;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: tokens.contentMaxWidth),
              child: Padding(
                padding:
                    padding ??
                    EdgeInsets.fromLTRB(
                      horizontal,
                      tokens.spaceMd,
                      horizontal,
                      tokens.spaceXl,
                    ),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.action,
    super.key,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spaceLg),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: tokens.spaceMd,
        runSpacing: tokens.spaceMd,
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (eyebrow != null) ...<Widget>[
                  Text(
                    eyebrow!,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  SizedBox(height: tokens.spaceXs),
                ],
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                if (subtitle != null) ...<Widget>[
                  SizedBox(height: tokens.spaceSm),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.palette.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    required this.title,
    this.icon,
    this.subtitle,
    this.action,
    super.key,
  });

  final String title;
  final IconData? icon;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.only(top: tokens.spaceSm, bottom: tokens.spaceSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
              ),
              child: Icon(
                icon,
                size: tokens.iconSm,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: tokens.spaceSm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                if (subtitle != null) ...<Widget>[
                  SizedBox(height: tokens.spaceXs),
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (action != null) ...<Widget>[
            SizedBox(width: tokens.spaceSm),
            action!,
          ],
        ],
      ),
    );
  }
}
