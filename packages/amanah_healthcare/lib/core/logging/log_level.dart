enum LogLevel {
  trace(100, 'TRACE'),
  debug(200, 'DEBUG'),
  info(300, 'INFO'),
  warning(400, 'WARN'),
  error(500, 'ERROR'),
  critical(600, 'CRITICAL');

  const LogLevel(this.value, this.label);

  final int value;
  final String label;

  bool operator >=(LogLevel other) => value >= other.value;
  bool operator <=(LogLevel other) => value <= other.value;
  bool operator >(LogLevel other) => value > other.value;
  bool operator <(LogLevel other) => value < other.value;
}
