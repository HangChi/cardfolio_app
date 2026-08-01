# 卡迹 Cardfolio 本地开发 Changelog

> 仅供个人使用。此文件位于 `docs/local/`，已被 `.gitignore` 排除，不会进入仓库提交。

整理日期：2026-08-01
覆盖范围：当前项目目录下 23 个 Codex 任务、Git 全部 42 个提交、当前工作树代码与公开文档。

## 当前快照

- 分支：`main`
- 整理前最新提交：`500a983 feat: optimize card images and quantity entry`
- Flutter/Dart：Dart SDK 约束 `^3.12.0`
- 本地数据库：Drift schema v9，21 张表
- 核心形态：本地优先移动 App；账号与同步可选；未配置服务地址时为纯本地模式
- 发布状态：客户端功能基线完整，真机矩阵、生产同步、CI、签名和商店发布尚未闭环

## 2026-07-26：项目初始化与文档基线

### 决策与交付

- 将 PRD 归档到 `docs/product/卡迹App_PRD_v1.0.md`。
- 初始化 Git `main`，提交 Flutter 多平台骨架。
- 读取 Figma 核心流程，冻结 Feature 001 为 Android 优先、本地相册建卡、不含裁切增强的最小闭环。
- 选择 Riverpod + Drift + go_router、功能优先分层、UUID、本地私有图片目录和本地优先边界。
- 完成产品、架构、ADR、设计、工程、质量、安全、运维以及 Feature 文档体系。

### 提交

- `915e116` Initial Flutter project setup
- `b1a1f6d` Document Feature 001 design
- `966eb4c` Plan Feature 001 implementation
- `18e7fde` Complete Cardfolio project documentation
- `5b3fdec` Build Cardfolio app shell
- `9c538a4` Regenerate platform plugin registrants
- `7d88709` Define card domain contracts
- `27a7688` Add local card database
- `360ef24` Persist card images and records atomically
- `b37a96a` Add gallery card creation state

## 2026-07-27～07-28：本地建卡、多图、套卡、整理、成本

### Feature 001：本地建卡闭环

- 实现收藏空状态、相册导入、建卡表单、详情、路由、幂等保存和图片缺失兜底。
- 启动门初始化数据库/图片目录，数据库失败时提供重试而不删库。
- 完成强停重启持久化集成测试和 Android Debug APK 构建。
- 提交：`765ef2b`、`71e4dea`。

### Feature 002：多图与封面

- 单卡最多 20 图，支持正面、背面、包装、编号、细节、其他用途。
- 支持排序、封面、追加、删除、失败补偿与 v1→v2 迁移。
- 最后一张图片当时禁止删除，后续卡片无图编辑需求将此规则改为允许删除。
- 初次实现曾使用功能分支，随后按用户要求合并并删除，后续全部直接在 `main`。
- 提交：`7407c44`、`8c6fc20`。

### Feature 003：套卡与完成度

- 创建/编辑套卡、成员定义、缺失成员、成员编号/必需性/排序、封面和完成度。
- 完成度按不同必需款式计算；重复不抬高完成度。
- 提交：`dfbe85d`、`73d436d`。

### Feature 004：标签、系列与筛选

- 标签的创建、重命名、合并、删除和影响预览。
- 系列（后续产品语义改为集卡册）、自定义字段、组合筛选、搜索防抖和稳定排序。
- Drift schema v4。
- 提交：`ee7e208`。

### Feature 005：购买与成本账本

- 初版提供独立购买记录、多目标分摊、运费/手续费、退款、多币种和成本排序。
- Drift schema v5；目标名称使用快照，删除目标后历史仍可解释。
- 后续产品收敛为卡片新建/编辑内的人民币卡片金额与运费，独立购买 UI 和成本排序被移除，
  但底层 schema 保留兼容旧数据、备份和同步。
- 提交：`866ecd6`。

## 2026-07-29：首页统计、回收站、备份、图片和同步

### Feature 006：首页与统计

- 首页收藏摘要、最近录入、即将集齐、待补资料。
- 六维数量分布与成本趋势，统计桶下钻到共享收藏查询。
- 提交：`8bb9ea4`。

### Feature 007：回收站

- 卡片软删除、恢复、永久删除、7/30/90 天保留期和启动自动清理。
- 文件物理删除失败写入持久队列，下次启动重试。
- Drift schema v6。
- 提交：`f939d44`。

### Feature 008：导入、导出与迁移

- 版本化 ZIP、清单、SHA-256、路径/体积/压缩比校验。
- 空库恢复、仅新增合并、冲突预览、文件 staging、原子回滚、进度和取消。
- 提交：`8f9fd2c`。

### Feature 009：相机与图片处理

- 初版实现相机单拍/连续拍摄、Android 丢失结果恢复、边缘识别、四角、透视、旋转、
  亮度/对比度/清晰度、模板、预览、撤销和原图/派生图分离。
- 后续改为拍照后先进入资料页，用户主动编辑时再调用系统裁剪；不再固定输出 4096px。
- 提交：`d02615d`。

### Feature 010：账号与本地优先同步

- 邮箱注册/登录、安全会话、同步开关、持久 outbox、增量游标、附件、指数退避、冲突副本。
- 支持退出保留本地、账号删除时选择本地副本、同字段冲突和删除/修改冲突处理。
- Drift schema v7；提供 Supabase RLS/幂等参考迁移，但生产服务未部署。
- 提交：`68dfea4`。

### 卡片编辑与批量录入

- 卡片基础资料、日期、数量、标签、集卡册、正反面可以后续编辑；当时允许空名称/无图保存。
- 原“系列”在 UI 中改为“集卡册”，同一文件夹可包含卡片或套卡，集卡册不使用标签。
- 多卡草稿、逐张正反面、日期/标签和稳定 ID 重试。
- 后续交互又收紧为新建时名称与城市必填，已有旧数据仍有展示回退。
- 提交：`143bf31`。

## 2026-07-30：卡片中心流程、高级编目、OCR 和 CSV

### 卡片内成本与导航

- 修复详情返回来源页；首页增加圆形快捷建卡。
- 独立购买记录页面、详情“记录购买”和相关路由移除。
- 新建/编辑/批量流程中填写人民币卡片金额和运费；每卡稳定内部记录避免重复累计。
- 录入时支持新建标签并自动选中，关联范围仅套卡/集卡册。
- 提交：`97b8c12`。

### 高级编目与批量工作流

- 品相、发行数量、发售价、无图建档、复制资料、完整编辑。
- 批量共享资料、批次内创建套卡、逐卡确认和跨进程草稿恢复。
- 三屏首次引导、权限/存储信息、诊断开关、重新查看引导。
- UTF-8 BOM CSV 导出、Android ML Kit 中文 OCR、内置交通卡资料库和可选远程目录。
- 提交：`bc6ef36`。

### 弹窗生命周期修复

- 修复标签/套卡/筛选命名弹窗退场动画未结束时提前释放 `TextEditingController` 引发断言。
- 提交：`b5b0898`。

## 2026-08-01：品牌、图片编辑、收藏体验与 UI 重构

### 应用标识与拍摄流程

- 应用显示名统一“卡迹”，替换 Android/iOS/macOS/Windows/Linux/Web 图标。
- 移除重复成本入口和“单卡多图连拍”入口；新建/编辑/批量均可相机或相册追加。
- 提交：`ce32c5c`、`bf84535`。

### 图片编辑与自动补全重做

- 根因确认旧四角裁剪坐标和预览处理过重；改用 image_cropper 的系统照片式裁剪。
- 拍照后不强制裁剪，主动编辑时才移动/缩放/旋转。
- 保留原图，编辑结果保持当前像素尺寸；亮度/对比度即时预览，清晰度保存时处理。
- 城市改为中国省/市/县区选择，国外手输；品相改下拉。
- OCR 改为字段候选确认，iOS 增加 Vision。
- 默认进入首页，正反面展示改为交通卡比例。
- 提交：`d5e2c1a`。

### 收藏表单与一致性

- 日期中文化、县区可省略、首页概览跳转、最近录入封面/10 条。
- 新建卡片按钮、集卡册封面、套卡整套张数、重复数改为实际多出张数。
- Drift schema v8 保存集卡册自定义封面。
- 修复保留自定义字段重复、筛选级联、集卡册成员跳转和封面来源。
- 累计花费排除删除卡片并可进入统计；修复分享返回、两次返回等导航问题。
- 提交：`bd07c2b`、`c2aafb9`。

### 整体 UI

- 保留米白、深绿、橙色品牌，增加完整暗色主题。
- 建立设计令牌、通用表面/指标/操作/状态组件。
- 手机底部导航、宽屏侧栏，高频页面统一层级、触控和无障碍语义。
- 提交：`4c8ec56`、`65bd50c`、`6286479`。

### 消费日历、删除一致性和最后收尾

- 统一拍摄图标；本月新增按 `acquired_at` 自然月筛选。
- 首页累计花费改为活跃收藏的全时期人民币净消费。
- 新增消费日历、每日明细和卡片跳转；统计固定总卡片/总花费并调整区块顺序。
- 统一集卡册、标签/字段计数和统计的软删除可见性；清理图片封面悬空引用。
- 修复日历 const 编译错误并重新设计 UI。
- 实现主导航 2 秒内双击返回退出。
- 删除收藏成本排序和常用筛选 UI，保留旧 JSON 兼容。
- 图片编辑保存增加 JPEG 直通和跳过全图透视；详情图集改为无叠加大图滑动；新建增加数量。
- 提交：`509bfae`、`662b6f6`、`e710806`、`b45d5df`、`d72daf5`、`500a983`。

### 建卡、套卡与集卡册体验收尾

- 新建草稿图片增加删除入口，封面删除后按图片顺序自动递补；封面角标改为小型半透明标记。
- 复制资料建卡会先创建全新草稿，只带入字段和整理关系，不复用图片或幂等 ID。
- Android 中文 OCR 识别器改为 Activity 生命周期内复用，并区分图片失效、图片不可读和识别失败。
- 入手日期统一为 UTC 同年月日的日历日期；升级时修正旧日期偏移，并让快捷成本记账日期跟随入手日期。
- Drift schema v9 为套卡增加独立封面路径；封面可拍摄、从相册选择、使用成员卡面或清除。
- 套卡详情将已拥有、缺失、重复压缩到同一行，成员按钮改为紧凑操作，发行信息和备注改为信息卡。
- 集卡册增加票夹/站牌风格的纯色文字默认封面，详情按“集卡册 → 套卡 → 卡片”展示目录。
- 主导航返回拦截增加同一次物理返回事件去重，切换模块会重置退出确认，五个模块统一两次返回退出。
- 套卡独立封面进入备份、同步载荷和图片引用扫描；相关页面统一 8/16/24 间距层级。

## 工具链与运行问题记录

- Windows 使用 Flutter 插件需要开启开发者模式以创建符号链接。
- Android Studio 即使 Run 也可能内部出现 `--start-paused`；设备下拉选错曾导致 App 安装到真机而观察模拟器。
- Android 37.1 预览 AVD + SwiftShader/Fast Boot 曾出现 Surface 黑屏；建议 Cold Boot、Hardware Graphics，
  或使用 Android 35/36 稳定镜像。
- JDK 21 可运行 Gradle，Android Java/Kotlin target 统一 17。
- `file_picker`、`share_plus` 的 Kotlin 插件警告属于未来 Flutter Built-in Kotlin 兼容提醒。
- Flutter APK 实际输出为 `build/app/outputs/flutter-apk/app-debug.apk` 或 `app-release.apk`；
  只打开 `android/` 时 Android Studio 原生 APK 目录规则不同。

## 被后续替代的早期设计

| 早期行为 | 当前行为 |
|---|---|
| 拍照后立即四角裁剪 | 拍照后进入资料页，主动编辑时系统相册式裁剪 |
| 手动四角/透视为主 | image_cropper 移动、缩放、旋转；像素调整按需 isolate |
| 固定 4096px 高清输出 | 保持裁剪结果像素尺寸，原图独立保留 |
| 独立购买记录与多币种 UI | 卡片内人民币金额 + 运费；旧账本仅兼容 |
| 收藏按入手成本排序 | 已移除 |
| 常用筛选 UI | 已移除，旧状态可解析 |
| 系列 | 产品语义为集卡册，schema/路由仍保留 series 名 |
| 新建资料全部可空 | 当前新建 UI 要求名称、城市、数量；图片与其余字段可后补 |
| 最后一张图片不可删除 | 允许无图卡片，最后一图可删除 |

## 全部 Git 提交索引

```text
915e116 Initial Flutter project setup
b1a1f6d Document Feature 001 design
966eb4c Plan Feature 001 implementation
18e7fde Complete Cardfolio project documentation
5b3fdec Build Cardfolio app shell
9c538a4 Regenerate platform plugin registrants
7d88709 Define card domain contracts
27a7688 Add local card database
360ef24 Persist card images and records atomically
b37a96a Add gallery card creation state
765ef2b Build local card creation flow
71e4dea Complete local card creation slice
7407c44 Complete multi-image and cover management
8c6fc20 Ignore local Claude workspace files
dfbe85d Define card set progress behavior
73d436d Complete card set progress management
ee7e208 Complete tags series and collection filters
866ecd6 Complete purchases and cost ledger
8bb9ea4 Complete dashboard and statistics
f939d44 Complete recycle bin and permanent deletion
8f9fd2c Complete import export and migration
d02615d Complete camera and image processing
68dfea4 Complete account and local-first sync
143bf31 Complete card editing and batch entry
97b8c12 Revise card entry and cost tracking
bc6ef36 Add advanced cataloging and batch workflows
b5b0898 Fix inline name dialog lifecycle
ce32c5c Improve app identity and camera workflows
bf84535 Update Flutter platform configuration
d5e2c1a Redesign card image editing and metadata entry
bd07c2b Improve collection forms and progress views
c2aafb9 Improve collection management and app behavior
4c8ec56 Document overall UI refresh design
65bd50c Plan overall UI refresh implementation
6286479 Polish Cardfolio UI across themes
509bfae feat: add spending calendar and fix deletion consistency
662b6f6 fix: correct spending calendar weekday header
e710806 style: refine spending calendar UI
b45d5df feat: require double back to exit
d72daf5 refactor: simplify collection filters and sorting
500a983 feat: optimize card images and quantity entry
```
