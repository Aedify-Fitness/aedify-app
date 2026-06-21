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
    'progress_media_path',
    'body_measurements',
    'set_logs',
    'candidate_exercise_list',
    'candidate_exercise_lists',
    'injury_note',
    'injuries',
    'screenshot_path',
    'source_file_excerpt',
    'local_database_dump',
    'prompt_text',
    'ai_response_json',
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
    final normalizedKey = key.toLowerCase();
    if (_sensitiveFields.contains(normalizedKey)) {
      return sensitive(value.toString());
    }
    if (normalizedKey.contains('api_key') ||
        normalizedKey.contains('token') ||
        normalizedKey.contains('secret') ||
        normalizedKey.contains('prompt') ||
        normalizedKey.contains('response') ||
        normalizedKey.contains('candidate') ||
        normalizedKey.contains('injur') ||
        normalizedKey.contains('screenshot') ||
        normalizedKey.contains('file_path') ||
        normalizedKey.contains('database_dump')) {
      return sensitive(value.toString());
    }
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
