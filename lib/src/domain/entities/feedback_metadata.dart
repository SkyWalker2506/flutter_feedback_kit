import 'package:flutter/foundation.dart';

/// Device and application metadata collected at feedback submission time.
///
/// Use [FeedbackMetadataCollector] to gather this automatically, or construct
/// it manually with known values.
@immutable
class FeedbackMetadata {
  const FeedbackMetadata({
    this.osName,
    this.osVersion,
    this.deviceModel,
    this.appName,
    this.buildNumber,
    this.extra = const {},
  });

  /// Deserialises from a JSON map produced by [toJson].
  factory FeedbackMetadata.fromJson(Map<String, dynamic> json) =>
      FeedbackMetadata(
        osName: json['osName'] as String?,
        osVersion: json['osVersion'] as String?,
        deviceModel: json['deviceModel'] as String?,
        appName: json['appName'] as String?,
        buildNumber: json['buildNumber'] as String?,
        extra:
            (json['extra'] as Map<String, dynamic>?)?.cast<String, String>() ??
            const {},
      );

  /// Operating system name, e.g. `'android'`, `'ios'`, `'web'`.
  final String? osName;

  /// OS version string, e.g. `'14.5'`.
  final String? osVersion;

  /// Device model identifier, e.g. `'Pixel 7'`, `'iPhone 15'`.
  final String? deviceModel;

  /// Human-readable application name.
  final String? appName;

  /// Application build number.
  final String? buildNumber;

  /// Arbitrary key-value pairs for custom metadata.
  final Map<String, String> extra;

  /// Serialises to a JSON-compatible map. Omits null / empty fields.
  Map<String, dynamic> toJson() => {
        if (osName != null) 'osName': osName,
        if (osVersion != null) 'osVersion': osVersion,
        if (deviceModel != null) 'deviceModel': deviceModel,
        if (appName != null) 'appName': appName,
        if (buildNumber != null) 'buildNumber': buildNumber,
        if (extra.isNotEmpty) 'extra': extra,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackMetadata &&
          osName == other.osName &&
          osVersion == other.osVersion &&
          deviceModel == other.deviceModel &&
          appName == other.appName &&
          buildNumber == other.buildNumber &&
          mapEquals(extra, other.extra);

  @override
  int get hashCode => Object.hash(
        osName,
        osVersion,
        deviceModel,
        appName,
        buildNumber,
        Object.hashAll(extra.entries),
      );
}
