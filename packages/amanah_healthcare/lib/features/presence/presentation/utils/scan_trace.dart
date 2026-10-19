import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:amanah_healthcare/core/logging/app_log.dart';

/// Monotonic latency benchmark tracker for QR scanner performance analysis.
///
/// Records timing intervals between key phases:
/// - screenOpened -> cameraReady
/// - firstDetect -> accepted
/// - accepted -> loadingPainted
/// - loadingPainted -> apiDone
class ScanTrace {
  ScanTrace._();

  static final Stopwatch _stopwatch = Stopwatch();
  static final Map<String, int> _marks = <String, int>{};

  /// Start or reset the stopwatch when scanner screen initializes.
  static void start() {
    if (kReleaseMode) return;
    _stopwatch
      ..reset()
      ..start();
    _marks.clear();
    mark('screenOpened');
  }

  /// Record a checkpoint mark with current elapsed milliseconds.
  static void mark(String phase) {
    if (kReleaseMode) return;
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
    }
    final int elapsed = _stopwatch.elapsedMilliseconds;
    _marks[phase] = elapsed;

    if (phase == 'loadingPainted' || phase == 'apiDone') {
      _report();
    }
  }

  /// Print structured timing intervals for DevTools / log inspection.
  static void _report() {
    final int? screenOpened = _marks['screenOpened'];
    final int? cameraReady = _marks['cameraReady'];
    final int? firstDetect = _marks['firstDetect'];
    final int? accepted = _marks['accepted'];
    final int? loadingPainted = _marks['loadingPainted'];
    final int? apiDone = _marks['apiDone'];

    final StringBuffer buffer = StringBuffer('[ScanTrace] Latency Report: ');

    if (screenOpened != null && cameraReady != null) {
      buffer.write('screenOpened->cameraReady=${cameraReady - screenOpened}ms | ');
    }
    if (firstDetect != null && accepted != null) {
      buffer.write('firstDetect->accepted=${accepted - firstDetect}ms | ');
    }
    if (accepted != null && loadingPainted != null) {
      buffer.write('accepted->loadingPainted=${loadingPainted - accepted}ms | ');
    }
    if (loadingPainted != null && apiDone != null) {
      buffer.write('loadingPainted->apiDone=${apiDone - loadingPainted}ms | ');
    }
    if (firstDetect != null && loadingPainted != null) {
      buffer.write('TOTAL firstDetect->loadingPainted=${loadingPainted - firstDetect}ms');
    }

    developer.log(buffer.toString(), name: 'Amanah.ScanTrace');
    AppLog.scanner(buffer.toString());
    debugPrint(buffer.toString());
  }

  /// Reset all recorded timestamps.
  static void reset() {
    if (kReleaseMode) return;
    _stopwatch.reset();
    _marks.clear();
  }
}
