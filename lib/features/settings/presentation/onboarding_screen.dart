import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../app/app_theme.dart';
import '../../../core/preferences/local_app_state_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  bool _saving = false;

  static const _pages = <_OnboardingPageData>[
    _OnboardingPageData(
      icon: Icons.style_outlined,
      title: '把每一张卡，整理成收藏',
      body: '正反面、发行资料、品相、套卡与入手成本都放在同一处，随时继续补全。',
    ),
    _OnboardingPageData(
      icon: Icons.photo_camera_outlined,
      title: '照片与资料由你掌控',
      body: '拍摄和相册权限仅在添加图片时使用；卡片资料默认保存在本机。',
    ),
    _OnboardingPageData(
      icon: Icons.shield_outlined,
      title: '先本地使用，也能随时备份',
      body: '支持批量录入、CSV 导出和完整备份。权限、存储与诊断开关可在设置中心查看。',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_page < _pages.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
      return;
    }
    setState(() => _saving = true);
    await ref.read(localAppStateProvider.notifier).completeOnboarding();
    if (mounted) context.go(libraryPath);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _saving
                    ? null
                    : () {
                        _pageController.animateToPage(
                          _pages.length - 1,
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOut,
                        );
                      },
                child: const Text('跳过'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (value) => setState(() => _page = value),
                itemBuilder: (context, index) =>
                    _OnboardingPage(data: _pages[index]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (var index = 0; index < _pages.length; index++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: EdgeInsets.all(tokens.spaceXs),
                    width: index == _page ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _page
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(tokens.spaceLg),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _continue,
                  child: Text(
                    _saving
                        ? '正在进入…'
                        : _page == _pages.length - 1
                        ? '开始使用'
                        : '继续',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.spaceXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            data.icon,
            size: 88,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: tokens.spaceXl),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: tokens.spaceMd),
          Text(
            data.body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

final class _OnboardingPageData {
  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
