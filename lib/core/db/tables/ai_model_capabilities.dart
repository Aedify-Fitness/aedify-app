import 'package:drift/drift.dart';

class AiModelCapabilities extends Table {
  TextColumn get id => text()();
  TextColumn get providerName => text()();
  TextColumn get modelName => text()();
  BoolColumn get supportsTextInput => boolean()();
  BoolColumn get supportsImageInput => boolean()();
  BoolColumn get supportsJsonSchemaMode => boolean()();
  BoolColumn get supportsStreaming => boolean()();
  BoolColumn get supportsToolCalling => boolean().nullable()();
  IntColumn get maxContextTokens => integer().nullable()();
  IntColumn get maxOutputTokens => integer().nullable()();
  IntColumn get maxImagesPerRequest => integer().nullable()();
  DateTimeColumn get checkedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
