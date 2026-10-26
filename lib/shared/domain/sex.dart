enum Sex {
  male,
  female,
  notSpecified;

  String get dbValue {
    return switch (this) {
      Sex.notSpecified => 'not_specified',
      _ => name,
    };
  }

  static Sex fromDb(String value) {
    return Sex.values.firstWhere((e) => e.dbValue == value);
  }
}
