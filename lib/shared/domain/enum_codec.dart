import 'dart:convert';

class EnumCodec {
  EnumCodec._();

  static Set<T> decodeSet<T>(String json, T Function(String value) fromDb) {
    return decodeList(json, fromDb).toSet();
  }

  static List<T> decodeList<T>(String json, T Function(String value) fromDb) {
    try {
      final values = (jsonDecode(json) as List<dynamic>).cast<String>();
      return values.map(fromDb).toList();
    } catch (_) {
      return <T>[];
    }
  }

  static String encodeSet<T>(Set<T> values, String Function(T value) toDb) {
    return encodeList(values.toList(), toDb);
  }

  static String encodeList<T>(List<T> values, String Function(T value) toDb) {
    return jsonEncode(values.map(toDb).toList());
  }
}
