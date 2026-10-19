import 'package:flutter/services.dart';
import 'package:amanah_healthcare/core/feedback/feedback.dart';

/// Contract for scanner sensory feedback (vibration & audio cues).
abstract class IScannerFeedbackService {
  Future<void> onScanSuccess();
  Future<void> onScanError();
  Future<void> onButtonTap();
}

/// Production sensory feedback service orchestrating haptic and sound subsystems.
/// Delegates to the core agnostic [FeedbackService].
class ScannerFeedbackService implements IScannerFeedbackService {
  ScannerFeedbackService({
    FeedbackService? feedbackService,
  }) : _feedbackService = feedbackService ?? DefaultFeedbackService.instance;

  final FeedbackService _feedbackService;

  @override
  Future<void> onScanSuccess() async {
    try {
      await _feedbackService.notifySuccess(needVibration: true);
    } catch (_) {}
  }

  @override
  Future<void> onScanError() async {
    try {
      await _feedbackService.notifyException(needVibration: true);
    } catch (_) {}
  }

  @override
  Future<void> onButtonTap() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }
}
