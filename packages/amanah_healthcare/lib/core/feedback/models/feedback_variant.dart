/// Categorical variants for application sensory feedback.
enum FeedbackSoundVariant {
  /// General system notifications, alert banners, and foreground push events.
  system,

  /// General action success and verified operations.
  success,

  /// Business rule conflicts, network failures, or unhandled exceptions.
  exception,
}
