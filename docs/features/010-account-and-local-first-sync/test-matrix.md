# Feature 010 测试矩阵

| ID | 类型 | 场景 | 自动化 |
|---|---|---|---|
| T01 | 领域 | 三方 disjoint 合并 | `sync_models_test.dart` |
| T02 | 领域 | 同字段与删除/修改冲突 | `sync_models_test.dart` |
| T03 | SQLite | 20 条离线变更、稳定操作 ID、ack | `sync_local_store_test.dart` |
| T04 | SQLite | pull 应用、游标原子推进 | `sync_local_store_test.dart` |
| T05 | SQLite | 冲突副本与解决 | `sync_local_store_test.dart` |
| T06 | 迁移 | v1..v6 到 v7 与 v6 数据保留 | `migration_test.dart` |
| T07 | REST | auth、push/pull、附件、HTTPS、错误 | `rest_account_sync_remote_test.dart` |
| T08 | 安全 | 令牌安全存储生命周期 | `secure_session_store_test.dart` |
| T09 | 仓储 | 重放、刷新、退避、退出保留 | `account_sync_repository_impl_test.dart` |
| T10 | Widget | 本地模式、登录、开关、状态、冲突、删除确认 | `profile_screen_test.dart` |

## 自动化结果

- Feature 010、迁移、图片存储、App shell 与启动定向测试：88 项通过。
- 完整宿主机测试套件：377 项通过。
- `flutter analyze --no-pub`：0 问题。
- Dart 格式检查：30 个变更文件，0 个需修改。
- 本轮没有启动模拟器或真机；以下步骤保留给设备环境手动执行。

## 模拟器/真机手动步骤

1. 使用测试服务地址启动 App，未登录创建卡片，确认“我的”显示本地模式且可离线浏览。
2. 注册并开启同步；飞行模式下再创建 20 张，强停重启，确认待同步数保留。
3. 恢复网络，点“立即同步”；服务端确认 20 条且无重复，App 显示队列清零。
4. 两台设备同步同一卡，离线分别改名称，恢复网络，确认后同步设备出现冲突且原值保留。
5. 一台删除、另一台修改，确认冲突不会静默永久删除修改。
6. 退出并选择保留本地，切飞行模式、重启，确认收藏和图片可浏览编辑。
7. 检查 Android Keystore/iOS Keychain 路径，普通 preferences、SQLite 和日志无令牌。
8. 上传接近 64 MiB 图片并注入中断，重试后校验和一致且无半文件。
9. 将两设备时间分别偏移 ±24 小时，确认冲突判断不随客户端时钟改变。
10. 删除账号分别走保留和删除本地副本路径，核对云端 RLS 数据和私有对象均清除。

上述步骤本次不由自动化启动模拟器；由用户在已部署测试服务的设备环境执行。
