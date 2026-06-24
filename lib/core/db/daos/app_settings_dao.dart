import 'package:drift/drift.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/db/tables/app_settings.dart';

part 'app_settings_dao.g.dart';

@DriftAccessor(tables: [AppSettings])
class AppSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$AppSettingsDaoMixin {
  AppSettingsDao(super.db);

  Future<AppSetting?> getSettings() {
    return select(appSettings).getSingleOrNull();
  }

  Future<void> upsertSettings(AppSettingsCompanion settings) {
    return into(appSettings).insertOnConflictUpdate(settings);
  }
}
