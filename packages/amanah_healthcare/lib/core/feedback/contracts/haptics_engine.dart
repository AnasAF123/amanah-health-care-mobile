/// Low-level abstraction for physical tactile/vibration hardware.
abstract interface class HapticsEngine {
  /// Emits a single affirmative tactile pulse.
  Future<void> success();

  /// Emits a distinct error pattern pulse.
  Future<void> error();

  /// Emits a light selection or system tap click.
  Future<void> light();
}
