class Redaction {
  static const String redactedPlaceholder = '[REDACTED]';
  static const String pathSeparator = '/';

  Redaction._();

  static const _sensitiveFields = {
    'api_key',
    'prompt',
    'response',
    'chat_history',
    'file_path',
    'body_measurements',
    'set_logs',
  };

  static const _sensitiveHeaderPrefixes = [
    'authorization',
    'x-api-key',
    'set-cookie',
    'cookie',
    'x-auth-token',
  ];

  static String sensitive(String? value) {
    if (value == null) return redactedPlaceholder;
    return redactedPlaceholder;
  }

  static String apiKey(String? key) {
    if (key == null) return redactedPlaceholder;
    if (key.length < 8) return redactedPlaceholder;
    return '${key.substring(0, 4)}...${key.substring(key.length - 4)}';
  }

  static String filePath(String? path) {
    if (path == null) return redactedPlaceholder;
    final segments = path.split(pathSeparator);
    if (segments.length < 2) return redactedPlaceholder;
    return '.../${segments.last}';
  }

  static Object? valueForField(String key, Object? value) {
    if (value == null) return null;
    if (_sensitiveFields.contains(key)) return sensitive(value.toString());
    return value;
  }

  static Map<String, Object?> metadata(Map<String, Object?> input) {
    return input.map((key, value) => MapEntry(key, valueForField(key, value)));
  }

  static Map<String, Object?> headers(Map<String, Object?> input) {
    return input.map((key, value) {
      final lower = key.toLowerCase();
      for (final prefix in _sensitiveHeaderPrefixes) {
        if (lower.startsWith(prefix)) {
          return MapEntry(key, sensitive(value.toString()));
        }
      }
      return MapEntry(key, value);
    });
  }

  static Map<String, Object?> queryParameters(Map<String, Object?> input) {
    return input.map((key, value) {
      if (key.toLowerCase() == 'api_key' || key.toLowerCase() == 'token') {
        return MapEntry(key, sensitive(value.toString()));
      }
      return MapEntry(key, value);
    });
  }
}
