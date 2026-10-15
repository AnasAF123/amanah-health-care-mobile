/// Extensible representation of a log category or channel.
///
/// Designed to be decoupled and agnostic. Developers can use standard constants
/// or instantiate custom categories via [LogCategory.custom('channel_name')].
class LogCategory {
  const LogCategory(this.name);

  final String name;

  // Standard pre-defined channels
  static const LogCategory http = LogCategory('http');
  static const LogCategory api = LogCategory('api');
  static const LogCategory auth = LogCategory('auth');
  static const LogCategory storage = LogCategory('storage');
  static const LogCategory database = LogCategory('database');
  static const LogCategory system = LogCategory('system');
  static const LogCategory ui = LogCategory('ui');

  /// Factory for dynamic / custom categories
  const factory LogCategory.custom(String name) = LogCategory;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogCategory &&
          runtimeType == other.runtimeType &&
          name.toLowerCase() == other.name.toLowerCase();

  @override
  int get hashCode => name.toLowerCase().hashCode;

  @override
  String toString() => name;
}
