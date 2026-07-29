import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

@immutable
final class DeviceSettingsSnapshot {
  const DeviceSettingsSnapshot({
    required this.cameraPermission,
    required this.photoPermission,
    required this.freeBytes,
    required this.totalBytes,
  });

  const DeviceSettingsSnapshot.unavailable()
    : cameraPermission = 'unknown',
      photoPermission = 'unknown',
      freeBytes = null,
      totalBytes = null;

  final String cameraPermission;
  final String photoPermission;
  final int? freeBytes;
  final int? totalBytes;
}

abstract interface class DeviceSettingsGateway {
  Future<DeviceSettingsSnapshot> inspect();

  Future<void> openAppSettings();
}

final class MethodChannelDeviceSettingsGateway
    implements DeviceSettingsGateway {
  const MethodChannelDeviceSettingsGateway();

  static const _channel = MethodChannel('cardfolio/device_settings');

  @override
  Future<DeviceSettingsSnapshot> inspect() async {
    try {
      final result = await _channel.invokeMapMethod<String, Object?>('inspect');
      if (result == null) return const DeviceSettingsSnapshot.unavailable();
      return DeviceSettingsSnapshot(
        cameraPermission: result['cameraPermission'] as String? ?? 'unknown',
        photoPermission: result['photoPermission'] as String? ?? 'unknown',
        freeBytes: result['freeBytes'] as int?,
        totalBytes: result['totalBytes'] as int?,
      );
    } on MissingPluginException {
      return const DeviceSettingsSnapshot.unavailable();
    } on PlatformException {
      return const DeviceSettingsSnapshot.unavailable();
    }
  }

  @override
  Future<void> openAppSettings() async {
    try {
      await _channel.invokeMethod<void>('openAppSettings');
    } on MissingPluginException {
      // 非移动平台无系统设置页。
    }
  }
}

final Provider<DeviceSettingsGateway> deviceSettingsGatewayProvider =
    Provider<DeviceSettingsGateway>(
      (ref) => const MethodChannelDeviceSettingsGateway(),
    );

final FutureProvider<DeviceSettingsSnapshot> deviceSettingsSnapshotProvider =
    FutureProvider<DeviceSettingsSnapshot>(
      (ref) => ref.watch(deviceSettingsGatewayProvider).inspect(),
    );
