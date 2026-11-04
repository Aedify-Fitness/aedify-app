import 'dart:io';

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/progress_media/application/progress_media_providers.dart';
import 'package:aedify/features/progress_media/domain/progress_media.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'feature repository uses injected database/files and surfaces empty async state',
    () async {
      final directory = await Directory.systemTemp.createTemp('m6_providers_');
      final db = AppDatabase(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [
          AppProviders.appDatabaseProvider.overrideWithValue(db),
          AppProviders.localFileStoreProvider.overrideWithValue(
            LocalFileStore(basePath: directory.path),
          ),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
        await directory.delete(recursive: true);
      });
      final subscription = container.listen(
        ProgressMediaProviders.timelineProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      expect(
        container.read(ProgressMediaProviders.timelineProvider).isLoading,
        isTrue,
      );
      expect(
        await container.read(ProgressMediaProviders.timelineProvider.future),
        isEmpty,
      );
      expect(
        (await container
                .read(ProgressMediaProviders.repositoryProvider)
                .getReminderState())
            .canPrompt,
        isFalse,
      );
    },
  );
  test('storage failure reaches async state as a safe error', () async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.readiness();
    await db.customStatement('DROP TABLE progress_media_sessions');
    final container = ProviderContainer(
      overrides: [AppProviders.appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    final subscription = container.listen(
      ProgressMediaProviders.timelineProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);
    await expectLater(
      container.read(ProgressMediaProviders.timelineProvider.future),
      throwsA(ProgressMediaFailure.unavailable),
    );
    expect(
      container.read(ProgressMediaProviders.timelineProvider).error,
      ProgressMediaFailure.unavailable,
    );
  });
}
