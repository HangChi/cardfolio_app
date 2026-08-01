# 卡迹 Cardfolio 完整技术实现文档

> 仅供个人使用。此文件位于 `docs/local/`，已被 `.gitignore` 排除，不会提交或推送。

整理日期：2026-08-01
代码基线：`main`，整理前 HEAD `500a983`

## 1. 系统概览

卡迹是 Flutter 编写的本地优先交通卡收藏应用。所有核心业务先写入本机 Drift/SQLite；图片
复制到 App 私有目录。账号和云同步是可选增强，没有服务地址时使用不可用远端适配器，
不会阻断本地收藏。

### 技术栈

| 能力 | 组件 |
|---|---|
| UI / 多平台 | Flutter Material 3、flutter_localizations |
| 状态和 DI | flutter_riverpod 3.3.2 |
| 路由 | go_router 17.3.0 |
| 本地数据库 | Drift 2.34.0、SQLite、生成式类型安全查询 |
| 相机/相册 | image_picker 1.2.3 |
| 系统裁剪 | image_cropper 12.2.1（Android uCrop、iOS TOCropViewController） |
| 像素处理 | image 4.9.1，在 isolate 中执行 |
| 文件与路径 | path_provider、path、crypto SHA-256 |
| ZIP/文件选择/分享 | archive、file_picker、share_plus |
| 网络/安全会话 | http、flutter_secure_storage |
| OCR | Android ML Kit 中文文本识别；iOS Vision；MethodChannel |

## 2. 启动、依赖注入与失败恢复

入口 `lib/main.dart` 渲染 `AppBootstrap`。核心实现位于
`lib/app/bootstrap/app_bootstrap.dart`。

### 初始化顺序

1. `WidgetsFlutterBinding.ensureInitialized()`。
2. 取得平台应用支持目录，建立 `cardfolio/` 数据根目录。
3. 从 `app-state.json` 读取引导完成、主题、诊断开关和批量草稿。
4. 重建 `backup-work/`、`image-processing-work/` 两个可丢弃临时目录。
5. 以 `NativeDatabase.createInBackground` 打开 `cardfolio.sqlite`，执行 Drift v1→v8 迁移。
6. 构造 `ManagedImageStore`、`CardRepositoryImpl`、`LocalImageProcessor`、回收站、备份和同步仓储。
7. 根据 `CARD_FOLIO_API_BASE_URL` 选择 `RestAccountSyncRemote` 或纯本地的
   `UnavailableAccountSyncRemote`。
8. 读取安全会话，对齐本地同步身份；启用同步时异步恢复一次 `syncNow()`。
9. 执行回收站到期清理和文件清理队列。
10. 从数据库取得全部引用图片路径，成功后才删除孤儿文件。
11. 通过 `ProviderScope.overrides` 注入真实实现。
12. 未完成引导进入 `/onboarding`，否则进入 `/home`。

初始化异常统一转为 `AppFailure`。启动页只展示用户可理解的信息和“重试”；数据库打开失败
时关闭句柄但不删库，且不会在无法读取引用时清理图片。

## 3. UI、主题和导航

### 主题

`lib/app/app_theme.dart` 定义：

- `AppPalette`：品牌绿、暖橙、纸张/墨绿表面以及语义色。
- `AppTokens`：4/8 间距体系、圆角、阴影、页面最大宽度和动效时长。
- 亮色、暗色两套 Material 3 ThemeData。

`LocalAppState.themePreference` 支持跟随系统、亮色、暗色，写入 `app-state.json`。
`core/widgets` 提供页面标题、Section、Surface、Metric、ActionTile、Badge、Empty 和 Error 组件。

### 主导航

`createAppRouter()` 使用 `StatefulShellRoute.indexedStack`：

- `/home` 首页
- `/library` 收藏
- `/capture` 拍摄
- `/stats` 统计
- `/profile` 我的

手机使用 NavigationBar，宽屏使用 NavigationRail。分支状态在会话中保留。Android 主导航根页
用时间窗口实现双击返回：第一次提示，2 秒内第二次允许系统退出；160ms 事件去重避免单次物理
返回被分支重复派发，切换分支会清空退出窗口。详情和表单仍单次返回。

业务页面通过稳定 ID 路由，例如 `/cards/:id`、`/sets/:id`、`/series/:id`。`series` 路径保留
是为了兼容历史数据，用户界面统一显示“集卡册”。

## 4. 本地状态文件

`JsonLocalAppStateStore` 原子读写 `app-state.json`，包含：

- `onboardingCompleted`
- `diagnosticsEnabled`
- `themePreference`
- `savedFilters`（UI 已移除，但保留解析和升级兼容）
- `batchEntry`（共享资料和逐卡草稿快照）

这个文件不属于业务数据库和同步实体；损坏时应以安全默认值恢复，而不是影响收藏库。

## 5. 数据库实现

`AppDatabase` 当前 schema v9，共 21 张表：

```text
card_definitions      card_items             card_images
card_sets             card_set_members
tags                  card_tags
series_records        series_cards           series_sets
custom_field_definitions                    custom_field_values
purchases             purchase_items         exchange_rates
recycle_bin_settings  file_cleanup_queue
sync_settings         sync_entity_states     sync_outbox       sync_conflicts
```

### 三层卡片模型

- `CardDefinition`：同款公共资料，名称、城市、机构、发行日期、编号、备注、类型、待完善。
- `CardItem`：实际藏品，数量、入手日期、创建/更新时间、软删除。
- `CardImage`：属于藏品实例的多图，用途、原图/派生路径、顺序、封面、校验值、软删除。

品相、发行数量、发售价等高级资料复用自定义字段表。`reserved_card_metadata.dart` 负责创建、
识别和从普通自定义字段列表过滤保留定义，避免编辑时重复创建同名字段。

### 迁移

- v1：卡片、实例、图片基础。
- v2：多图、封面、派生图和图片软删除。
- v3：套卡与成员。
- v4：标签、集卡册、字段和查询索引。
- v5：购买、目标、汇率。
- v6：回收站设置和文件清理队列。
- v7：同步设置、云端基线、outbox、冲突。
- v8：集卡册自定义封面路径。
- v9：套卡独立封面路径；升级时把历史入手时间转换成设备本地日历日，并同步校正快捷成本日期。

快照在 `drift_schemas/app/`，迁移生成物为 `card_database.steps.dart`，迁移测试位于
`test/drift/app/` 与卡片数据库迁移测试中。

## 6. 卡片新建、编辑、复制和详情

### 新建

`CreateCardScreen` + `CreateCardController` 管理草稿。当前 UI 要求：

- 名称非空，最多 100 字符；
- 城市必须选择或填写；
- 持有数量必须是大于 0 的整数；
- 图片可空，其余资料可后补；
- 最多 20 张图片。

每张草稿图片都可删除。图片列表第 1 张始终作为封面，删除后由下一张自动递补；这里只移除
尚未保存的草稿引用，不写数据库。封面角标和删除动作叠放在图片两角，不占用下方用途/排序空间。

控制器负责相册多选、逐张拍照、草稿图片用途和封面、字段错误、保存锁以及把表单转换为
`CreateCardRequest`。Request 的 cardItemId/definitionId/imageId 都提前生成 UUID，因此用户快速
重复点击或失败重试不会创建第二份记录。

`CardRepositoryImpl.createCard()`：

1. 规范化请求并检查幂等 ID。
2. 把临时图片导入受管目录，计算 SHA-256。
3. 在数据库事务写款式、实例和图片行。
4. 数据库失败时删除本批新增文件。
5. UI 再保存标签、套卡/集卡册和卡片成本；失败时保留可编辑结果，避免重复建卡。

### 编辑

`EditCardScreen` 订阅卡片、整理信息和成本，统一编辑基础资料、数量、城市/日期、保留字段、
标签、套卡、集卡册、卡片金额和运费。基础资料使用 `UpdateCardRequest`；图片使用独立仓储命令，
整理通过 `SaveCardOrganizationRequest` 原子替换关系，成本通过稳定内部购买 ID upsert。

### 复制

`/cards/:id/copy` 复用新建页。进入复制路由先调用 `startCopyDraft()` 清空图片、草稿 ID、失败状态
和表单状态，再复制公共资料、标签、套卡和集卡册；图片和实际成本不会进入新草稿，并生成全新稳定 ID。

### 详情

详情订阅 `watchCard(id)`；记录不存在/已删除显示缺失状态。图片采用 PageView 大图左右滑动，
图片上不叠用途/封面/菜单，下方统一展示用途、封面、页码、添加和管理。编辑、设封面、排序、
删除均复用仓储命令。

## 7. 相机、相册、图片编辑与性能

### 获取图片

- 相册：`ImagePickerGalleryPicker.pickMany`。
- 相机：`ImagePickerCameraCapture`，支持取消、权限错误和 Android lost data 恢复。
- 拍照完成后直接回资料页，不自动裁剪；用户可继续拍正面、背面和细节。

### 系统裁剪与像素调整

`ImageEditorScreen` 先调用 image_cropper 提供平台原生移动、缩放、矩形裁剪和旋转，再用
`LocalImageProcessor` 应用亮度、对比度、清晰度等需要像素处理的设置。

性能优化：

- 仅裁剪、没有额外调整且输出为 JPEG 时允许直接发布，避免第二次完整解码/编码。
- 四角等于完整画面时跳过无意义透视重采样。
- 处理在 isolate 中执行，避免 UI isolate 长时间阻塞。
- 输出 JPEG 质量 95，保持裁剪结果的当前像素尺寸，不统一缩放到 4096px。

高像素图片使用清晰度仍需完整解码、卷积和编码，是当前主要耗时来源。

### 文件一致性

- 原图路径 `relative_path` 永不被派生结果覆盖。
- 活动结果写 `derived_relative_path`，详情优先显示派生图。
- 图片写入失败补偿本批文件；永久删除失败写 `file_cleanup_queue`。
- 删除图片前清理引用其图片 ID/路径的套卡和集卡册封面。

## 8. OCR 与交通卡资料库

`CardTextRecognizer` 是平台接口：

- Android 通过 MethodChannel 调用内置 ML Kit 中文文字识别；识别器在 Activity 生命周期内复用，
  销毁 Activity 时关闭，调用前检查本地图片存在且可读。
- iOS 通过 MethodChannel 调用 Vision。

`RecognizedCardText.fromRawText` 对行去重并提取：

- 字母数字混合编号；
- 19xx/20xx 年份；
- 以公司/集团等结尾的发行机构；
- 含交通、公交、地铁、一卡通、市民卡等词的名称候选。

平台错误码区分图片路径失效、图片不可读和识别失败，UI 给出对应的重拍/重选提示。识别结果
不直接覆盖资料，而是展示候选供用户逐项确认。

交通卡目录由 `CompositeTransportCardCatalog` 合并：

- 内置常见卡（北京一卡通、上海公共交通卡、羊城通、深圳通、武汉通等）；
- 可选 `CARD_FOLIO_CATALOG_BASE_URL` 远程 REST 目录；
- 远程失败自动回退内置结果，按名称/城市/机构字符匹配计算置信度。

## 9. 批量录入

`BatchCardEntryScreen` 支持一个批次内多张卡：

- 共享城市、机构、类型、入手日期、套卡和集卡册；
- 批次内创建套卡并自动选中；
- 每张草稿独立名称、正面、背面、日期、标签、成本和数量；
- 逐张“资料已确认”；
- 每张草稿使用稳定 ID，保存成功后标记并跳过，失败后安全重试。

共享资料、草稿字段、图片临时路径和确认状态序列化为 `BatchEntrySnapshot`。强停后重新打开批量
页面恢复；全部卡成功后清除快照。

## 10. 标签、自定义字段、搜索和筛选

### 标签/字段

`OrganizationRepository` 提供标签创建、重命名、合并、删除和字段管理。删除前使用
`ChangeImpact` 返回受影响数量；合并在事务中迁移关系并软删除源标签。

字段支持 text/number/date，每个 field + definition 只有一个值；数据库 CHECK 保证三个值列
恰好一个非空。

### 搜索筛选

`CardLibraryQuery` 支持：

- 名称、编号、城市、机构、备注、标签搜索；
- 类型、市级城市、机构、发行年份；
- 标签任一/全部；
- 套卡成员状态、重复卡、待完善、套卡完成状态；
- 入手日期 UTC 起始包含/结束不包含；
- 创建、发行、入手、名称排序。

搜索输入 250ms 防抖，SQL 使用真实关系表和 `deleted_at IS NULL` 约束。重复卡按同一
definition 的活跃 quantity 总和 > 1 判断。常用筛选和成本排序 UI 已移除，但旧 JSON 仍能解析。

## 11. 套卡与集卡册

### 套卡

套卡 `CardSet` 有可知/未知整套张数、成员、编号、必需性、排序和封面。成员可指向已有款式，
也可创建尚未拥有的缺失款式。v9 的 `card_sets.cover_relative_path` 保存拍摄/相册导入的独立封面；
旧 `cover_image_id` 继续保存成员卡面封面。两种来源互斥，读取时独立路径优先。

完成度：

- ownedRequiredCount = 拥有至少 1 张的必需款式数；
- requiredMemberCount = 已知时整套张数，否则必需成员定义数；
- duplicateMemberCount = 每成员 `max(ownedQuantity - 1, 0)` 之和；
- 未知总数不显示百分比/已集齐状态。

实体卡删除后成员定义保留，只把 ownedQuantity 降为 0。

套卡详情的封面本身是入口，点击后选择拍摄、相册、成员卡面或清除。完成度面板把已拥有、缺失、
重复做成同一行等宽指标；发行信息和备注使用相同信息表面，成员添加使用紧凑图标按钮。

### 集卡册

`series_records` 在当前 UI 中叫“集卡册”，可以同时关联卡片款式和套卡，没有标签和完成度。
封面可来自相机、相册、卡片或套卡，也可由应用把集卡册名称和预设颜色绘制成受管 PNG。

详情读模型增加 `SeriesSetGroup`。每个已收录套卡加载其活跃实体成员，页面渲染为可展开的
“集卡册 → 套卡 → 卡片”目录；直接收录且没有出现在当前套卡目录中的卡片放入“其他卡片”。
同一卡片属于多个已收录套卡时会在每个真实目录下出现。

集卡册查询要求卡片款式至少存在一个活跃实体，因此软删除后不显示；关系本身不删除，恢复后
自动可见。编辑集卡册时保留当前隐藏成员，防止回收站状态造成关系丢失。

## 12. 卡片成本、总花费与消费日历

### 卡片内成本

`SaveCardEntryCostRequest` 使用人民币分，卡片金额和运费非负。内部购买 ID 由
`cardEntryCostPurchaseId(cardItemId)` 稳定生成：

- 新建成本：插入 purchases + purchase_items；
- 编辑成本：更新同一 purchase；
- 两项清空/为零：删除该内部成本事实；
- purchased_at 优先使用卡片入手日期。

入手日期属于 date-only 数据，规范化为 `DateTime.utc(year, month, day)`，不会再把设备本地零点
转换成前一天 UTC。快捷成本保存同一个 UTC 日历日；未填写入手日期时才使用仓储当前时间。

旧的普通购买、分摊、多币种和退款结构仍保留兼容，但当前路由没有独立购买 UI。

### 首页与统计

`DashboardDatabase` 用 SQL 聚合构造只读模型：

- 首页：活跃实例/款式/套卡/集卡册、本月入手、最近 10 条、差一款、待完善、总花费。
- 统计：固定总卡片数、总花费、六维分布和月度消费趋势。
- 统计桶直接生成 `CardLibraryQuery`，点击后复用收藏列表查询，避免两套口径。

总花费只统计活跃收藏；卡片软删除后排除，恢复后重新计入。当前展示统一 CNY。

### 消费日历

`SpendingCalendarRepository.watchSpendingMonth(month, options)` 返回：

- `SpendingCalendarMonth`：月份、每日汇总、月净额和笔数；
- `SpendingDaySummary`：日期、净额、明细；
- `SpendingCalendarEntry`：购买 ID、日期、标签、金额、可选 cardItemId。

页面生成固定 6 行月历，周一开始。当前月默认选今天，历史月选最近有记录日期。日明细中的
单卡记录可跳转详情。支出和退款用正负金额及语义颜色区分。

## 13. 回收站、级联可见性与永久删除

软删除只设置 `card_items.deleted_at`，保留图片和所有组织/成本关系。默认查询、集卡册成员、
标签/字段计数、套卡拥有量、首页、统计和消费都要求存在活跃实体。

恢复清空 deleted_at，因此关系自动回归。

永久删除流程：

1. 生成删除影响预览并二次确认。
2. 数据库事务计算原图/派生图，写入 `file_cleanup_queue`。
3. 清理套卡/集卡册封面引用、购买目标、图片和实体数据。
4. 事务提交后删除物理文件。
5. 失败保留队列项，启动时重试并更新 attemptCount。

到期清理使用 7/30/90 天单例设置。业务记录已删除但物理文件失败不会把卡片伪装回活跃状态。

## 14. ZIP 备份、恢复与 CSV

### ZIP

`BackupRepositoryImpl` 导出版本化逻辑快照和所有引用图片，manifest 包含版本、时间、计数、
相对路径、大小和 SHA-256，不包含绝对路径、安全令牌和日志。

导入先解压到隔离目录并验证：格式版本、路径逃逸、条目数、总大小、压缩比、SHA-256、UUID、
字段约束和关系。支持：

- emptyLibrary：空库完整恢复；
- mergeAddOnly：只新增，同主键同内容跳过，同主键不同内容阻断并预览冲突。

文件先 staging，数据库事务和文件发布任一步失败都补偿本批结果。提交前支持取消，提交开始后
不能伪装成安全取消。

套卡独立封面路径作为 `cardSets.coverRelativePath` 写入逻辑快照和同步载荷；旧快照缺少该键时
按 `null` 兼容。引用图片扫描同时读取卡片图片、集卡册封面和套卡独立封面，避免孤儿清理误删。

### CSV

CSV 导出使用 UTF-8 BOM，完整转义逗号、引号和多行文本，便于 Windows Excel 打开中文。
文件通过平台保存/分享适配器交付，不把外部路径持久化进业务库。

## 15. 账号与本地优先同步

### 会话和配置

- 邮箱注册/登录调用 REST；令牌存入 flutter_secure_storage。
- `sync_settings` 保存 deviceId、开关、游标、账号摘要和最近状态。
- 未登录或未配置端点不影响本地能力。

### Outbox

本地变更产生稳定 operationId、entityType/entityId、upsert/delete、baseServerVersion、payload、
changedFields。每实体只保留一条合并后的待发操作；失败记录 attemptCount、nextAttemptAt 和错误码。

### 同步过程

1. 取得安全会话和当前设置。
2. 先处理到期 outbox，附件先上传并校验 SHA-256。
3. 服务端按 operationId 幂等写入并返回版本。
4. 使用 cursor 拉取增量实体和附件。
5. 将远端变化与最近云端基线、本地当前值做三方合并。
6. 不同字段自动合并；同字段或删除/修改冲突写 `sync_conflicts`。
7. 用户选择保留本地、使用远端或提交手动合并后标记 resolvedAt。

生产部署需要 REST 网关、Supabase RLS/幂等 SQL、私有附件桶、账号数据清理、配额、监控和回滚。

## 16. 错误与一致性策略

`AppFailure` 体系隔离数据库、文件、权限、图片、备份、网络、认证、同步和校验异常。UI 只显示
`userMessage`，不暴露 SQL、路径、token 或堆栈。

关键策略：

- 输入先在 Domain request `normalized()` 校验，再进入数据库。
- 保存按钮有 UI 锁，数据库稳定 ID/唯一约束提供第二层幂等。
- 文件 + 数据库使用补偿；永久删除使用持久清理队列。
- 网络失败不回滚本地写入；同步状态保留可重试信息。
- 数据库失败不静默删库，备份失败不覆盖已有导出，导入失败不修改现有收藏。

## 17. 测试结构与验证建议

仓库当前约 76 个测试源文件和 1 个 integration_test：

- Domain：模型、不变量、金额、完成度、筛选、同步合并。
- Data：内存 SQLite、迁移、事务、补偿、文件、REST fake。
- Presentation：页面、控制器、导航、表单、主题和状态。
- Integration：真实设备上的数据库/图片持久化。

标准宿主机命令：

```powershell
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --no-pub
flutter test --no-pub
```

数据库修改后：

```powershell
dart run build_runner build --delete-conflicting-outputs
```

设备验证：

```powershell
flutter devices
flutter test -d <device-id> integration_test/card_persistence_test.dart
flutter run -d <device-id>
```

必须手工覆盖首次引导、相册/相机取消、权限拒绝、系统裁剪/OCR、HEIC、12MP、强停恢复、
批量草稿、软删恢复、ZIP 往返、CSV Excel、暗色、200% 字体、读屏和双设备同步。

## 18. 构建与环境

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build apk --debug
flutter build apk --release
```

APK 输出：

- `build/app/outputs/flutter-apk/app-debug.apk`
- `build/app/outputs/flutter-apk/app-release.apk`

Windows 需开启开发者模式。JDK 21 可运行 Gradle，Android Java/Kotlin target 为 17。
Android Studio 应打开仓库根目录。日常开发建议使用 Android 35/36 稳定 AVD，预览 AVD 的
SwiftShader/Fast Boot 可能产生 Surface 黑屏。

## 19. 已知限制和技术债

- 生产同步服务尚未部署，双设备、RLS、账号删除和附件冲突未在真实环境闭环。
- iOS 需要 macOS 构建和 Vision/OCR、裁剪、权限、分享真机验证。
- 高像素图片叠加清晰度仍需完整处理，保存可能明显耗时；尚无持久缩略图缓存。
- 内置交通卡目录条目有限，远程目录协议需要真实服务、数据授权和质量治理。
- 历史购买/多币种 schema 比当前 UI 更宽；未来如删除必须先设计备份/同步迁移。
- `savedFilters` Provider/JSON 兼容代码仍存在，UI 已移除；可在确认无需降级兼容后清理。
- 公开 PRD 和部分历史九件套仍记录旧的四角裁剪、独立购买、多币种或“系列”术语，应视为
  需求演进历史，当前最终口径见公开 README、架构文档和本实现文档。
- 当前仓库只有 CI/CD 文档，没有实际托管 CI workflow。
