import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraHelper {
  const CameraHelper._();

  static List<CameraDescription>? _cameras;

  /// Mandatory method to call before [findBestCamera]
  static Future<void> init() async {
    if (!isSupported) {
      _cameras = <CameraDescription>[];
    } else {
      try {
        _cameras = await availableCameras();
      } catch (_) {
        _cameras = <CameraDescription>[];
      }
    }
  }

  /// Returns if the device has more than one camera
  static bool get hasMoreThanOneCamera {
    if (_cameras != null && _cameras!.isNotEmpty) {
      return _cameras!.length > 1;
    }
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Returns if the device has at least one camera
  static bool get hasACamera {
    if (_cameras != null && _cameras!.isNotEmpty) {
      return true;
    }
    return Platform.isAndroid || Platform.isIOS;
  }

  static bool get isSupported => kIsWeb || Platform.isAndroid || Platform.isIOS;
}
