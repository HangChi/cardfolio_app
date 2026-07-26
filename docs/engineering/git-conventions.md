# Git 协作约定

## 1. 分支

- `main` 始终保持可构建、可测试。
- 功能分支使用 `codex/<feature>-<summary>`。
- 修复分支使用 `codex/fix-<summary>`。
- 分支只承载一个清晰目标，完成后及时合并并删除。

## 2. 提交

提交信息使用英文祈使句，示例：

- `Add local card database`
- `Document image storage policy`
- `Fix duplicate card submission`

每个提交应可独立理解并尽量通过相关测试。生成代码必须与生成源同一提交。不要提交密钥、个人数据、构建产物、IDE 临时文件或设备日志。

## 3. Pull Request

PR 描述包含：

- 问题与范围；
- 关键设计决定；
- 对应 PRD/Feature/ADR；
- 测试命令和结果；
- UI 变更截图或录屏；
- 数据迁移、权限、隐私和回滚影响；
- 已知限制。

至少一名评审者确认业务行为和工程质量；涉及视觉的 PR 同时完成 Figma 对照；涉及 schema、安全或同步的 PR 需专项评审。

## 4. 禁止事项

- 不在共享分支强制推送。
- 不用 `git reset --hard` 清理他人改动。
- 不把格式化整个仓库与单一业务变更混合。
- 不绕过失败测试合并。
- 不在提交信息或 PR 中粘贴访问令牌、用户文件路径或敏感日志。
