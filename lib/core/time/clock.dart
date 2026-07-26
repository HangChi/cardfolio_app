/// 时间抽象。所有时间戳以 UTC 存储，测试可注入固定时钟。
abstract interface class Clock {
  DateTime nowUtc();
}

/// 生产实现：系统时钟。
final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

/// 测试实现：固定或手动推进的时钟。
final class FixedClock implements Clock {
  FixedClock(this._now);

  DateTime _now;

  @override
  DateTime nowUtc() => _now.toUtc();

  void advance(Duration duration) => _now = _now.add(duration);
}
