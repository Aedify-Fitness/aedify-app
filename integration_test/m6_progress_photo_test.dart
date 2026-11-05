import 'dart:io';
import 'dart:ui' as ui;

import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/core/db/app_database.dart';
import 'package:aedify/core/storage/local_file_store.dart';
import 'package:aedify/features/progress_media/application/progress_photo_providers.dart';
import 'package:aedify/features/progress_media/data/progress_photo_picker.dart';
import 'package:aedify/features/progress_media/presentation/progress_media_screen.dart';
import 'package:aedify/shared/constants/app_routes.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/preferred_unit.dart';
import 'package:aedify/shared/theme/app_colors.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native offline photo review, replacement, four poses, save and reopen',
    (tester) async {
      final priorHttp = HttpOverrides.current;
      final network = _BlockedPhotoNetwork();
      HttpOverrides.global = network;
      addTearDown(() => HttpOverrides.global = priorHttp);
      final root = await (await getTemporaryDirectory()).createTemp(
        'm6_photo_smoke_',
      );
      final databaseFile = File(p.join(root.path, 'fixture.sqlite'));
      var db = AppDatabase(NativeDatabase(databaseFile));
      final files = LocalFileStore(basePath: p.join(root.path, 'sandbox'));
      final picker = _NativeSelectionFixture(root);
      final source = ImagePickerProgressPhotoPicker(
        picker: picker,
        files: files,
      );
      final container = ProviderContainer(
        overrides: [
          AppProviders.appDatabaseProvider.overrideWithValue(db),
          AppProviders.localFileStoreProvider.overrideWithValue(files),
          ProgressPhotoProviders.pickerProvider.overrideWithValue(source),
          ProgressPhotoProviders.unitsProvider.overrideWith(
            (ref) async => PreferredUnit.imperial,
          ),
        ],
      );
      var dark = false;
      final router = GoRouter(
        initialLocation: AppRoutes.progress().path,
        routes: [
          GoRoute(
            path: AppRoutes.home().path,
            name: AppRoutes.home().name,
            builder: (_, _) => const Scaffold(),
          ),
          GoRoute(
            path: AppRoutes.progress().path,
            name: AppRoutes.progress().name,
            builder: (_, _) => const ProgressMediaScreen(),
          ),
        ],
      );
      Future<void> mount() => tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: RepaintBoundary(
            key: _PhotoSmoke.captureKey,
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
              routerConfig: router,
            ),
          ),
        ),
      );
      await mount();
      await tester.pumpAndSettle();
      await _PhotoSmoke.capture(tester, 'empty_light');
      for (final pose in ['front', 'back', 'leftSide', 'rightSide']) {
        await _PhotoSmoke.choose(
          tester,
          pose,
          pose == 'front' ? 'camera' : 'gallery',
        );
      }
      expect(await db.select(db.progressMediaSessions).get(), isEmpty);
      expect(await db.select(db.localFileRecords).get(), isEmpty);
      picker.cancelNext = true;
      await _PhotoSmoke.choose(tester, 'front', 'gallery');
      expect(find.text(AppStrings.progressPhotoCancelled), findsOneWidget);
      await _PhotoSmoke.choose(tester, 'front', 'gallery');
      await _PhotoSmoke.reveal(
        tester,
        find.byKey(const ValueKey('photo_bodyweight')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('photo_bodyweight')),
        '165.3467',
      );
      await _PhotoSmoke.reveal(
        tester,
        find.byKey(const ValueKey('photo_notes')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('photo_notes')),
        'Synthetic session',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await _PhotoSmoke.reveal(
        tester,
        find.byKey(const ValueKey('photo_action_front')),
      );
      await _PhotoSmoke.capture(tester, 'review_light');
      dark = true;
      await mount();
      await tester.pumpAndSettle();
      await _PhotoSmoke.capture(tester, 'review_dark');
      await _PhotoSmoke.reveal(
        tester,
        find.byKey(const ValueKey('photo_save')),
      );
      await tester.tap(find.byKey(const ValueKey('photo_save')));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.progressPhotoSaved), findsOneWidget);
      await _PhotoSmoke.capture(tester, 'saved_dark');
      final row = (await db.select(db.progressMediaSessions).get()).single;
      expect(row.isCompletePoseSet, isTrue);
      expect(row.isBaseline, isTrue);
      expect(row.bodyweightKg, closeTo(75, 0.001));
      expect(row.notes, 'Synthetic session');
      final items = await db.select(db.progressMediaItems).get();
      expect(items.length, 8);
      expect((await db.select(db.localFileRecords).get()).length, 8);
      for (final item in items) {
        expect(await files.statManagedFile(item.localRelativePath), isNotNull);
      }
      expect(picker.calls, 6);
      expect(picker.requestedFullMetadata, isFalse);
      expect(network.attempts, 0);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      router.dispose();
      await db.close();
      db = AppDatabase(NativeDatabase(databaseFile));
      expect(
        (await db.select(db.progressMediaSessions).get()).single.notes,
        'Synthetic session',
      );
      expect((await db.select(db.progressMediaItems).get()).length, 8);
      await db.close();
      await root.delete(recursive: true);
    },
  );
}

abstract final class _PhotoSmoke {
  static const captureKey = ValueKey('photo_smoke_capture');
  static Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  static Future<void> choose(
    WidgetTester tester,
    String pose,
    String source,
  ) async {
    final button = find.byKey(ValueKey('photo_action_$pose'));
    await reveal(tester, button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('photo_source_$source')));
    await tester.pumpAndSettle();
  }

  static Future<void> capture(WidgetTester tester, String name) async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(captureKey),
    );
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final folder = await getApplicationDocumentsDirectory();
    await File(
      p.join(folder.path, 'aedify_m6_photo_$name.png'),
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  }
}

/// Synthetic platform selection seam; camera/gallery hardware is not automated.
class _NativeSelectionFixture extends ImagePicker {
  _NativeSelectionFixture(this.root);
  final Directory root;
  int calls = 0;
  bool cancelNext = false;
  bool requestedFullMetadata = true;
  @override
  Future<LostDataResponse> retrieveLostData() async => LostDataResponse.empty();
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    calls++;
    requestedFullMetadata = requestFullMetadata;
    if (cancelNext) {
      cancelNext = false;
      return null;
    }
    final recorder = ui.PictureRecorder();
    ui.Canvas(
      recorder,
    ).drawColor(AedifyLightColors.secondary, ui.BlendMode.src);
    final picture = recorder.endRecording();
    final image = await picture.toImage(96, 128);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(p.join(root.path, 'selection_$calls.png'));
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
    picture.dispose();
    return XFile(file.path);
  }
}

class _BlockedPhotoNetwork extends HttpOverrides {
  int attempts = 0;
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    attempts++;
    throw StateError('Photo smoke must stay offline');
  }
}
