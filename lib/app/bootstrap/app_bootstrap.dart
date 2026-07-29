import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/errors/app_failure.dart';
import '../../core/id/id_generator.dart';
import '../../core/preferences/json_local_app_state_store.dart';
import '../../core/preferences/local_app_state.dart';
import '../../core/preferences/local_app_state_providers.dart';
import '../../core/time/clock.dart';
import '../../features/backup/data/backup_providers.dart';
import '../../features/backup/data/backup_repository_impl.dart';
import '../../features/backup/domain/backup_repository.dart';
import '../../features/cards/data/card_providers.dart';
import '../../features/cards/data/card_repository_impl.dart';
import '../../features/cards/data/files/managed_image_store.dart';
import '../../features/cards/data/image_processing/local_image_processor.dart';
import '../../features/cards/data/local/card_database.dart';
import '../../features/cards/domain/card_repository.dart';
import '../../features/cards/domain/image_processing.dart';
import '../../features/recycle_bin/data/recycle_bin_providers.dart';
import '../../features/recycle_bin/data/recycle_bin_repository_impl.dart';
import '../../features/recycle_bin/domain/recycle_bin_repository.dart';
import '../../features/sync/data/account_sync_remote.dart';
import '../../features/sync/data/account_sync_repository_impl.dart';
import '../../features/sync/data/local/sync_local_store.dart';
import '../../features/sync/data/rest_account_sync_remote.dart';
import '../../features/sync/data/secure_session_store.dart';
import '../../features/sync/data/sync_providers.dart';
import '../../features/sync/domain/account_sync_repository.dart';
import '../../features/sync/domain/sync_models.dart';
import '../app_router.dart';
import '../app_theme.dart';
import '../cardfolio_app.dart';

typedef AppBootstrapInitializer = Future<CardfolioDependencies> Function();

/// 一次成功启动后共享给整个应用的数据依赖。
@immutable
final class CardfolioDependencies {
  const CardfolioDependencies._({
    required this.database,
    required this.imageStore,
    required this.repository,
    required this.imageProcessor,
    required this.recycleBinRepository,
    required this.backupRepository,
    required this.accountSyncRepository,
    required this.httpClient,
    required this.localAppStateStore,
    required this.initialAppState,
  });

  static const String _dataDirectoryName = 'cardfolio';
  static const String _databaseFileName = 'cardfolio.sqlite';
  static const String _imageDirectoryName = 'images';
  static const String _backupWorkDirectoryName = 'backup-work';
  static const String _imageProcessingWorkDirectoryName =
      'image-processing-work';

  final AppDatabase database;
  final ManagedImageStore imageStore;
  final CardRepository repository;
  final ImageProcessor imageProcessor;
  final RecycleBinRepository recycleBinRepository;
  final BackupRepository backupRepository;
  final AccountSyncRepository accountSyncRepository;
  final http.Client httpClient;
  final LocalAppStateStore localAppStateStore;
  final LocalAppState initialAppState;

  /// 打开持久化依赖并完成启动恢复。
  ///
  /// [supportDirectory] 只用于测试注入；生产环境使用平台提供的应用支持目录。
  static Future<CardfolioDependencies> initialize({
    Directory? supportDirectory,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    AppDatabase? database;
    http.Client? httpClient;
    try {
      final platformSupport =
          supportDirectory ?? await getApplicationSupportDirectory();
      final dataRoot = Directory(
        p.join(platformSupport.path, _dataDirectoryName),
      );
      final imageRoot = Directory(p.join(dataRoot.path, _imageDirectoryName));
      final backupWork = Directory(
        p.join(dataRoot.path, _backupWorkDirectoryName),
      );
      final imageProcessingWork = Directory(
        p.join(dataRoot.path, _imageProcessingWorkDirectoryName),
      );
      final localAppStateStore = JsonLocalAppStateStore(
        File(p.join(dataRoot.path, 'app-state.json')),
      );
      final initialAppState = await localAppStateStore.read();
      await imageRoot.create(recursive: true);
      await _resetBackupWorkDirectory(backupWork);
      await _resetImageProcessingWorkDirectory(imageProcessingWork);

      database = AppDatabase(
        NativeDatabase.createInBackground(
          File(p.join(dataRoot.path, _databaseFileName)),
        ),
      );
      final imageStore = ManagedImageStore(imageRoot);
      final repository = CardRepositoryImpl(
        database: database,
        imageStore: imageStore,
        clock: const SystemClock(),
      );
      final imageProcessor = LocalImageProcessor(imageProcessingWork);
      final recycleBinRepository = RecycleBinRepositoryImpl(
        database: database,
        imageStore: imageStore,
        clock: const SystemClock(),
      );
      final backupRepository = BackupRepositoryImpl(
        database: database,
        imageStore: imageStore,
        workingDirectory: backupWork,
        clock: const SystemClock(),
      );
      httpClient = http.Client();
      const apiBaseUrl = String.fromEnvironment('CARD_FOLIO_API_BASE_URL');
      final AccountSyncRemote syncRemote = apiBaseUrl.isEmpty
          ? const UnavailableAccountSyncRemote()
          : RestAccountSyncRemote(
              baseUri: Uri.parse(apiBaseUrl),
              client: httpClient,
            );
      final secureSessions = SecureSessionStoreImpl(
        const FlutterSecureKeyValueStore(),
      );
      final syncLocal = SyncLocalStore(
        database: database,
        idGenerator: const UuidGenerator(),
        clock: const SystemClock(),
      );
      final accountSyncRepository = AccountSyncRepositoryImpl(
        remote: syncRemote,
        sessions: secureSessions,
        local: syncLocal,
        images: imageStore,
        clock: const SystemClock(),
      );

      // 安全存储暂时不可用不能阻断本地收藏库启动。
      try {
        final session = await secureSessions.read();
        final syncSettings = await syncLocal.settings();
        if (session == null && syncSettings.account != null) {
          await syncLocal.clearSyncIdentity();
        } else if (session != null && syncSettings.account == null) {
          await syncLocal.setAccount(
            AccountSummary(userId: session.userId, email: session.email),
          );
        }
        if (session != null && (await syncLocal.settings()).enabled) {
          unawaited(_resumeSyncQuietly(accountSyncRepository));
        }
      } on Object {
        // 用户仍可使用全部本地能力，并可稍后从“我的”重试登录。
      }

      // 先完成到期永久删除和中断文件清理，再按最新引用清理孤儿文件。
      await recycleBinRepository.purgeExpired();

      // 先成功读取数据库引用，再执行清理。数据库打不开时绝不触碰现有图片。
      final referencedPaths = await repository.referencedImagePaths();
      await imageStore.removeOrphans(referencedPaths);

      return CardfolioDependencies._(
        database: database,
        imageStore: imageStore,
        repository: repository,
        imageProcessor: imageProcessor,
        recycleBinRepository: recycleBinRepository,
        backupRepository: backupRepository,
        accountSyncRepository: accountSyncRepository,
        httpClient: httpClient,
        localAppStateStore: localAppStateStore,
        initialAppState: initialAppState,
      );
    } on AppFailure {
      httpClient?.close();
      if (database != null) await _closeQuietly(database);
      rethrow;
    } catch (error) {
      httpClient?.close();
      if (database != null) await _closeQuietly(database);
      throw DatabaseUnavailableFailure('卡迹暂时无法启动，请重试。', error);
    }
  }

  Future<void> close() async {
    httpClient.close();
    await database.close();
  }

  static Future<void> _closeQuietly(AppDatabase database) async {
    try {
      await database.close();
    } on Object {
      // 初始化已失败，关闭异常不能覆盖原始失败。
    }
  }

  static Future<void> _resumeSyncQuietly(
    AccountSyncRepository repository,
  ) async {
    try {
      await repository.syncNow();
    } on Object {
      // 后台恢复失败会保留队列和重试状态，不影响本地模式启动。
    }
  }

  static Future<void> _resetBackupWorkDirectory(Directory directory) async {
    try {
      if (directory.existsSync()) await directory.delete(recursive: true);
      await directory.create(recursive: true);
    } on FileSystemException catch (error) {
      throw BackupStorageFailure('无法准备备份临时空间，请检查存储空间。', error);
    }
  }

  static Future<void> _resetImageProcessingWorkDirectory(
    Directory directory,
  ) async {
    try {
      if (directory.existsSync()) await directory.delete(recursive: true);
      await directory.create(recursive: true);
    } on FileSystemException catch (error) {
      throw ImageProcessingFailure('无法准备图片处理空间，请检查存储空间。', error);
    }
  }
}

/// 启动门：依赖就绪后才渲染业务 App，失败时提供原地重试。
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({this.initializer, super.key});

  final AppBootstrapInitializer? initializer;

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  CardfolioDependencies? _dependencies;
  Object? _failure;
  bool _loading = true;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    final generation = ++_generation;
    final initializer = widget.initializer ?? CardfolioDependencies.initialize;

    Future<CardfolioDependencies>.sync(initializer).then(
      (dependencies) async {
        if (!mounted || generation != _generation) {
          await dependencies.close();
          return;
        }
        setState(() {
          _dependencies = dependencies;
          _failure = null;
          _loading = false;
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!mounted || generation != _generation) return;
        setState(() {
          _failure = error;
          _loading = false;
        });
      },
    );
  }

  void _retry() {
    setState(() {
      _failure = null;
      _loading = true;
    });
    _initialize();
  }

  @override
  void dispose() {
    _generation++;
    final dependencies = _dependencies;
    if (dependencies != null) {
      unawaited(dependencies.close());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = _dependencies;
    if (dependencies != null) {
      return ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(dependencies.database),
          managedImageStoreProvider.overrideWithValue(dependencies.imageStore),
          cardRepositoryProvider.overrideWithValue(dependencies.repository),
          imageProcessorProvider.overrideWithValue(dependencies.imageProcessor),
          recycleBinRepositoryProvider.overrideWithValue(
            dependencies.recycleBinRepository,
          ),
          backupRepositoryProvider.overrideWithValue(
            dependencies.backupRepository,
          ),
          accountSyncRepositoryProvider.overrideWithValue(
            dependencies.accountSyncRepository,
          ),
          localAppStateStoreProvider.overrideWithValue(
            dependencies.localAppStateStore,
          ),
        ],
        child: CardfolioApp(
          router: createAppRouter(
            initialLocation: dependencies.initialAppState.onboardingCompleted
                ? libraryPath
                : onboardingPath,
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildCardfolioTheme(),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: _loading
                ? const CircularProgressIndicator(semanticsLabel: '正在打开本地收藏库')
                : _BootstrapFailure(failure: _failure, onRetry: _retry),
          ),
        ),
      ),
    );
  }
}

class _BootstrapFailure extends StatelessWidget {
  const _BootstrapFailure({required this.failure, required this.onRetry});

  final Object? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = switch (failure) {
      AppFailure(:final userMessage) => userMessage,
      _ => '卡迹暂时无法启动，请重试。',
    };

    return Padding(
      padding: EdgeInsets.all(context.tokens.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.storage_outlined, size: 48, color: AppColors.error),
          SizedBox(height: context.tokens.spaceMd),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: context.tokens.spaceLg),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        ],
      ),
    );
  }
}
