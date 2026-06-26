import 'package:drift/drift.dart';

class AiProviderConfigs extends Table {
  TextColumn get id => text()();
  TextColumn get providerName => text()();
  TextColumn get displayName => text().nullable()();
  TextColumn get selectedModel => text().nullable()();
  TextColumn get secureKeyAlias => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();

  BoolColumn get supportsTextInput =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get supportsImageInput =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get supportsJsonSchemaMode =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get supportsStreaming =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get supportsToolCalling => boolean().nullable()();

  IntColumn get maxContextTokens => integer().nullable()();
  IntColumn get maxOutputTokens => integer().nullable()();
  IntColumn get maxImagesPerRequest => integer().nullable()();
  IntColumn get maxImageSizeBytes => integer().nullable()();

  DateTimeColumn get lastValidatedAt => dateTime().nullable()();
  TextColumn get lastValidationStatus => text().nullable()();
  TextColumn get lastErrorCode => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
