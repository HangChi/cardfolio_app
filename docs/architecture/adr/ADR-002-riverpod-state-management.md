# ADR-002：Riverpod 状态管理与依赖注入

日期：2026-07-26
状态：Accepted

## 背景

页面需要处理响应式数据库流、异步保存、权限错误和未来同步状态，同时测试必须能够替换仓储、时间和平台服务。

## 决策

使用 Riverpod 作为状态管理和依赖注入容器。首期手写 Provider/Notifier，不引入 Riverpod 代码生成；Drift 仍可独立使用其生成流程。

## 理由

- Provider 状态由容器隔离，适合单元和 Widget 测试覆盖。
- 对 loading/data/error 和组合数据流支持清晰。
- 依赖覆盖不需要全局可变单例。
- 避免同时维护 Riverpod 与 Drift 两套生成注解，降低 M1 配置成本。

## 后果

- Provider 定义必须集中在 Feature 的装配文件，避免散落。
- Widget 只监听需要的状态片段，防止无关重建。
- Notifier 不持有 BuildContext。
- 当样板代码出现可量化维护成本后，另立 ADR 评估 Riverpod 代码生成。

## 未采用

- 仅 `setState`：不适合跨页面持久数据和可替换依赖。
- Provider/ChangeNotifier：可行，但异步状态和组合流需要更多手工协议。
- BLoC/Cubit：状态显式，但 Feature 001 的事件样板成本更高。
