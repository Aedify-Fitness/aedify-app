class Redaction {
  static const String redactedPlaceholder = '[REDACTED]';
  static const String pathSeparator = '/';
  Redaction._();

  static String sensitive(String? value) {
    if (value == null) return Redaction.redactedPlaceholder;
    return Redaction.redactedPlaceholder;
  }

  static String apiKey(String? key) {
    if (key == null) return Redaction.redactedPlaceholder;
    if (key.length < 8) return Redaction.redactedPlaceholder;
    return '${key.substring(0, 4)}...${key.substring(key.length - 4)}';
  }

  static String filePath(String? path) {
    if (path == null) return Redaction.redactedPlaceholder;
    final segments = path.split(Redaction.pathSeparator);
    if (segments.length < 2) return Redaction.redactedPlaceholder;
    return '.../${segments.last}';
  }
}
