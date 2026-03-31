import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../domain/entities/feedback_metadata.dart';

/// Collects device and application metadata automatically.
///
/// Pass an instance to [FeedbackWidget.metadataCollector] to enrich every
/// [FeedbackEntry] with OS, device model, and app info.
///
/// ```dart
/// FeedbackWidget(
///   backend: myBackend,
///   appVersion: '1.0.0',
///   metadataCollector: FeedbackMetadataCollector(),
/// )
/// ```
class FeedbackMetadataCollector {
  const FeedbackMetadataCollector();

  /// Collects metadata from the current device and package.
  Future<FeedbackMetadata> collect() async {
    final packageInfo = await PackageInfo.fromPlatform();
    String? osName;
    String? osVersion;
    String? deviceModel;

    final deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      final webInfo = await deviceInfo.webBrowserInfo;
      osName = 'web';
      osVersion = webInfo.browserName.name;
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          final info = await deviceInfo.androidInfo;
          osName = 'android';
          osVersion = info.version.release;
          deviceModel = info.model;
        case TargetPlatform.iOS:
          final info = await deviceInfo.iosInfo;
          osName = 'ios';
          osVersion = info.systemVersion;
          deviceModel = info.model;
        case TargetPlatform.macOS:
          final info = await deviceInfo.macOsInfo;
          osName = 'macos';
          osVersion = info.osRelease;
          deviceModel = info.model;
        case TargetPlatform.windows:
          final info = await deviceInfo.windowsInfo;
          osName = 'windows';
          osVersion = info.displayVersion;
          deviceModel = info.productName;
        case TargetPlatform.linux:
          final info = await deviceInfo.linuxInfo;
          osName = 'linux';
          osVersion = info.version;
          deviceModel = info.prettyName;
        default:
          osName = defaultTargetPlatform.name.toLowerCase();
      }
    }

    return FeedbackMetadata(
      osName: osName,
      osVersion: osVersion,
      deviceModel: deviceModel,
      appName: packageInfo.appName,
      buildNumber: packageInfo.buildNumber,
    );
  }
}
