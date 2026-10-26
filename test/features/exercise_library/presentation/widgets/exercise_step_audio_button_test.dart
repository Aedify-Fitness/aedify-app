import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/application/exercise_step_audio_controller.dart';
import 'package:aedify/features/exercise_library/domain/exercise_step_audio_state.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_step_audio_button.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

class _PreloadedAudioController extends ExerciseStepAudioController {
  _PreloadedAudioController(this.initialState);

  final Map<String, ExerciseStepAudioState> initialState;
  ({int exerciseId, int stepIndex, String text})? playedStep;
  ({int exerciseId, int stepIndex})? stoppedStep;

  @override
  Map<String, ExerciseStepAudioState> build() => initialState;

  @override
  Future<void> playStep({
    required int exerciseId,
    required int stepIndex,
    required String text,
  }) async {
    playedStep = (exerciseId: exerciseId, stepIndex: stepIndex, text: text);
  }

  @override
  Future<void> stop(int exerciseId, int stepIndex) async {
    stoppedStep = (exerciseId: exerciseId, stepIndex: stepIndex);
  }
}

Widget createTestApp(
  Map<String, ExerciseStepAudioState> initialState, {
  int exerciseId = 1,
  int stepIndex = 0,
  String text = 'Step one',
  ExerciseStepAudioController? controller,
}) {
  return ProviderScope(
    overrides: [
      AppProviders.exerciseStepAudioControllerProvider.overrideWith(
        () => controller ?? _PreloadedAudioController(initialState),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: ExerciseStepAudioButton(
          exerciseId: exerciseId,
          stepIndex: stepIndex,
          text: text,
        ),
      ),
    ),
  );
}

void main() {
  group('ExerciseStepAudioButton', () {
    testWidgets('renders play action in idle state', (tester) async {
      await tester.pumpWidget(createTestApp({}, exerciseId: 1, stepIndex: 0));
      await tester.pump();

      expect(find.byTooltip(AppStrings.playStepAudio), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
      expect(
        tester.getSize(find.byType(IconButton)),
        const Size.square(AppExerciseDetailTokens.controlSize),
      );
    });

    testWidgets('renders stop action while speaking', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          {
            '1:0': const ExerciseStepAudioState(
              phase: ExerciseStepAudioPhase.speaking,
              activeStepIndex: 0,
            ),
          },
          exerciseId: 1,
          stepIndex: 0,
        ),
      );
      await tester.pump();

      expect(find.byTooltip(AppStrings.stopStepAudio), findsOneWidget);
    });

    testWidgets('shows progress indicator while checking cache', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          {
            '1:0': const ExerciseStepAudioState(
              phase: ExerciseStepAudioPhase.checkingCache,
            ),
          },
          exerciseId: 1,
          stepIndex: 0,
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows progress indicator while generating', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          {
            '1:0': const ExerciseStepAudioState(
              phase: ExerciseStepAudioPhase.generating,
            ),
          },
          exerciseId: 1,
          stepIndex: 0,
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows unavailable fallback when TTS unavailable', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(
          {
            '1:0': const ExerciseStepAudioState(
              phase: ExerciseStepAudioPhase.unavailable,
              errorCode: 'tts_unavailable',
            ),
          },
          exerciseId: 1,
          stepIndex: 0,
        ),
      );
      await tester.pump();

      expect(find.byTooltip(AppStrings.audioUnavailable), findsOneWidget);
      expect(
        tester.widget<IconButton>(find.byType(IconButton)).onPressed,
        isNull,
      );
    });

    testWidgets('shows failed state with error tooltip', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          {
            '1:0': const ExerciseStepAudioState(
              phase: ExerciseStepAudioPhase.failed,
              errorCode: 'audio_playback_failed',
              errorMessage: 'Could not play step audio.',
            ),
          },
          exerciseId: 1,
          stepIndex: 0,
        ),
      );
      await tester.pump();

      expect(find.byTooltip('Could not play step audio.'), findsOneWidget);
    });

    testWidgets('play is tappable at the edge of its 48px target', (
      tester,
    ) async {
      final controller = _PreloadedAudioController({});
      await tester.pumpWidget(
        createTestApp(
          {},
          exerciseId: 12,
          stepIndex: 2,
          text: 'Keep your chest tall.',
          controller: controller,
        ),
      );
      await tester.pump();

      final bounds = tester.getRect(find.byType(IconButton));
      await tester.tapAt(
        Offset(bounds.right - AppSpacing.xs, bounds.center.dy),
      );
      await tester.pump();

      expect(controller.playedStep, (
        exerciseId: 12,
        stepIndex: 2,
        text: 'Keep your chest tall.',
      ));
    });

    testWidgets('stop dispatches the selected exercise and step', (
      tester,
    ) async {
      final controller = _PreloadedAudioController({
        '12:2': const ExerciseStepAudioState(
          phase: ExerciseStepAudioPhase.speaking,
          activeStepIndex: 2,
        ),
      });
      await tester.pumpWidget(
        createTestApp({}, exerciseId: 12, stepIndex: 2, controller: controller),
      );

      await tester.tap(find.byTooltip(AppStrings.stopStepAudio));
      await tester.pump();

      expect(controller.stoppedStep, (exerciseId: 12, stepIndex: 2));
      expect(controller.playedStep, isNull);
    });

    testWidgets('failed control retries the same instruction', (tester) async {
      final controller = _PreloadedAudioController({
        '1:0': const ExerciseStepAudioState(
          phase: ExerciseStepAudioPhase.failed,
          errorMessage: 'Could not play step audio.',
        ),
      });
      await tester.pumpWidget(
        createTestApp(
          {},
          text: 'Brace before lifting.',
          controller: controller,
        ),
      );

      await tester.tap(find.byTooltip('Could not play step audio.'));
      await tester.pump();

      expect(controller.playedStep, (
        exerciseId: 1,
        stepIndex: 0,
        text: 'Brace before lifting.',
      ));
    });
  });
}
