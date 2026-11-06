import 'package:aedify/app/theme/app_theme.dart';
import 'package:aedify/features/progress_media/application/progress_deletion_providers.dart';
import 'package:aedify/features/progress_media/domain/progress_deletion.dart';
import 'package:aedify/features/progress_media/presentation/progress_delete_controls.dart';
import 'package:aedify/features/progress_media/presentation/progress_storage_screen.dart';
import 'package:aedify/shared/constants/app_error_strings.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  for (final scope in ProgressDeleteScope.values) {
    testWidgets(
      '${scope.name} deletion requires explicit confirmation and cancel is a no-op',
      (tester) async {
        final controller = _DeletionUiController();
        await _DeletionUiController.mount(
          tester,
          controller,
          child: ProgressDeleteButton(
            scope: scope,
            sessionId: 'session',
            itemId: 'item',
          ),
        );
        await tester.tap(find.byType(TextButton).first);
        await tester.pumpAndSettle();
        expect(controller.deletes, 0);
        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.tap(find.text(AppStrings.cancel));
        await tester.pumpAndSettle();
        expect(controller.deletes, 0);
        await tester.tap(find.byType(TextButton).first);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('progress_confirm_delete')));
        await tester.pumpAndSettle();
        expect(controller.deletes, 1);
        expect(controller.lastScope, scope);
        expect(find.text(AppStrings.progressDeleted), findsOneWidget);
      },
    );
  }
  testWidgets('a target changed behind an open confirmation is never deleted', (
    tester,
  ) async {
    final controller = _DeletionUiController();
    final target = ValueNotifier<String>('first');
    addTearDown(target.dispose);
    await _DeletionUiController.mount(
      tester,
      controller,
      child: ValueListenableBuilder<String>(
        valueListenable: target,
        builder: (_, id, _) => ProgressDeleteButton(
          scope: ProgressDeleteScope.item,
          sessionId: 'session',
          itemId: id,
        ),
      ),
    );
    await tester.tap(find.byType(TextButton).first);
    await tester.pumpAndSettle();
    target.value = 'second';
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('progress_confirm_delete')));
    await tester.pumpAndSettle();
    expect(controller.deletes, 0);
  });
  testWidgets(
    'failed delete retains the control and exposes only safe recovery copy',
    (tester) async {
      final controller = _DeletionUiController()..fail = true;
      await _DeletionUiController.mount(
        tester,
        controller,
        child: const ProgressDeleteButton(
          scope: ProgressDeleteScope.session,
          sessionId: 'session',
        ),
      );
      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('progress_confirm_delete')));
      await tester.pumpAndSettle();
      expect(find.text(AppErrorStrings.progressDeletionFailed), findsOneWidget);
      expect(find.textContaining('private-error-sentinel'), findsNothing);
      expect(
        tester.widget<TextButton>(find.byType(TextButton).first).onPressed,
        isNotNull,
      );
    },
  );
  testWidgets('committed deletion with file failure reports pending cleanup', (
    tester,
  ) async {
    final controller = _DeletionUiController()..pending = true;
    await _DeletionUiController.mount(
      tester,
      controller,
      child: const ProgressDeleteButton(
        scope: ProgressDeleteScope.session,
        sessionId: 'session',
      ),
    );
    await tester.tap(find.byType(TextButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('progress_confirm_delete')));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.progressDeletedPending), findsOneWidget);
  });
  for (final dark in [false, true]) {
    testWidgets(
      'storage/retry/confirmation fit 320px and 2x text in ${dark ? 'dark' : 'light'}',
      (tester) async {
        tester.view.physicalSize = const Size(320, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = _DeletionUiController()..pending = true;
        await _DeletionUiController.mount(
          tester,
          controller,
          child: const ProgressStorageScreen(),
          dark: dark,
          scale: 2,
        );
        expect(
          find.text(AppErrorStrings.progressCleanupPending),
          findsOneWidget,
        );
        final retry = find.byKey(const ValueKey('progress_retry_cleanup'));
        await tester.ensureVisible(retry);
        await tester.tap(retry);
        await tester.pumpAndSettle();
        expect(controller.recovers, greaterThanOrEqualTo(2));
        final delete = find.byKey(const ValueKey('progress_delete_all'));
        await tester.ensureVisible(delete);
        await tester.tap(delete);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text(AppStrings.cancel));
        await tester.pumpAndSettle();
        expect(controller.deletes, 0);
      },
    );
  }
}

class _DeletionUiController extends ProgressDeletionController {
  int deletes = 0;
  int recovers = 0;
  bool fail = false;
  bool pending = false;
  ProgressDeleteScope? lastScope;
  ProgressCleanupStatus get result => ProgressCleanupStatus(
    sessionCount: 2,
    activeBytes: 4096,
    pendingFiles: pending ? 2 : 0,
    pendingBytes: pending ? 1024 : 0,
  );
  @override
  Future<ProgressCleanupStatus> build() async => result;
  @override
  Future<ProgressCleanupStatus> recover() async {
    recovers++;
    state = AsyncData(result);
    return result;
  }

  Future<ProgressCleanupStatus> _delete(ProgressDeleteScope scope) async {
    if (fail) throw StateError('private-error-sentinel');
    deletes++;
    lastScope = scope;
    return result;
  }

  @override
  Future<ProgressCleanupStatus> deleteItem(String s, String i) =>
      _delete(ProgressDeleteScope.item);
  @override
  Future<ProgressCleanupStatus> deleteSession(String s) =>
      _delete(ProgressDeleteScope.session);
  @override
  Future<ProgressCleanupStatus> deleteAll() => _delete(ProgressDeleteScope.all);
  static Future<void> mount(
    WidgetTester tester,
    _DeletionUiController controller, {
    required Widget child,
    bool dark = false,
    double scale = 1,
  }) async {
    final container = ProviderContainer(
      overrides: [
        ProgressDeletionProviders.controllerProvider.overrideWith(
          () => controller,
        ),
      ],
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(body: child),
        ),
      ],
    );
    addTearDown(() {
      router.dispose();
      container.dispose();
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }
}
