import 'dart:async';
import 'package:amanah_healthcare/core/logging/app_log.dart';
import 'package:amanah_healthcare/features/authentication/domain/repositories/auth_repository.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_notification_model.dart';
import 'package:amanah_healthcare/features/permission/data/amanah_permission_store.dart';
import 'package:amanah_healthcare/features/queue/presentation/state/amanah_queue_store.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';

enum AuthSessionEvent {
  expired,
  restored,
}

/// Centralized Session Lifecycle Manager
/// Orchestrates authentication session events and clinical store cleanup across the application.
class AmanahAuthSessionManager {
  AmanahAuthSessionManager._();

  static final AmanahAuthSessionManager instance = AmanahAuthSessionManager._();

  final StreamController<AuthSessionEvent> _eventController =
      StreamController<AuthSessionEvent>.broadcast();

  Stream<AuthSessionEvent> get eventStream => _eventController.stream;

  DateTime? _lastExpirationNotification;
  DateTime? _lastLifecycleCheck;

  /// Broadcasts a session expiration event if not throttled by recent triggers.
  void notifySessionExpired({String? reason}) {
    final DateTime now = DateTime.now();
    if (_lastExpirationNotification != null &&
        now.difference(_lastExpirationNotification!).inSeconds < 3) {
      return;
    }
    _lastExpirationNotification = now;
    AppLog.warning(
      '[AmanahAuthSessionManager] Session expired: ${reason ?? 'Unauthorized session'}',
    );
    _eventController.add(AuthSessionEvent.expired);
  }

  /// Broadcasts a session restored event.
  void notifySessionRestored() {
    _eventController.add(AuthSessionEvent.restored);
  }

  /// Resets all local clinical stores to guarantee zero data leakage between user sessions.
  void resetAllStores() {
    AppLog.info('[AmanahAuthSessionManager] Resetting all clinical stores');
    AmanahScheduleStore.instance.reset();
    AmanahNotificationStore.instance.reset();
    AmanahPermissionStore.instance.reset();
    AmanahQueueStore.instance.reset();
  }

  /// Verifies active session validity, proactively attempting a silent refresh if needed.
  /// Applies a 5-second cooldown to prevent redundant network calls during rapid app resumes.
  Future<bool> verifySessionValidity({
    required AuthRepository authRepository,
    bool force = false,
  }) async {
    final DateTime now = DateTime.now();
    if (!force &&
        _lastLifecycleCheck != null &&
        now.difference(_lastLifecycleCheck!).inSeconds < 5) {
      return true;
    }
    _lastLifecycleCheck = now;

    try {
      final user = await authRepository.getSession();
      if (user == null) {
        // Try refreshing if access token was simply expired
        final bool refreshed = await authRepository.refreshToken();
        if (!refreshed) {
          notifySessionExpired(reason: 'Session invalid upon app resumption check');
          return false;
        }
        return true;
      }
      return true;
    } catch (_) {
      // In case of transient network failure, do not aggressively terminate the session
      return true;
    }
  }

  void dispose() {
    _eventController.close();
  }
}
