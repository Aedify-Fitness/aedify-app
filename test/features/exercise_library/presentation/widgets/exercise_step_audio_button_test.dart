import 'package:aedify/app/providers/providers.dart';
import 'package:aedify/features/exercise_library/application/exercise_step_audio_controller.dart';
import 'package:aedify/features/exercise_library/domain/exercise_step_audio_state.dart';
import 'package:aedify/features/exercise_library/presentation/widgets/exercise_step_audio_button.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

class _PreloadedAudioController extends ExerciseStepAudioController {
  _PreloadedAudioController(this.initialState);

  final Map<String, ExerciseStepAudioState> initialState;

  @override
  Map<String, ExerciseStepAudioState> build() => initialState;
}

Widget createTestApp(
  Map<String, ExerciseStepAudioState> initialState, {
  int exerciseId = 1,
  int stepIndex = 0,
  String text = 'Step one',
}) {
  return ProviderScope(
    overrides: [
      AppProviders.exerciseStepAudioControllerProvider.overrideWith(
        () => _PreloadedAudioController(initialState),
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

    testWidgets('play button is tappable', (tester) async {
      await tester.pumpWidget(createTestApp({}, exerciseId: 1, stepIndex: 0));
      await tester.pump();

      expect(find.byTooltip(AppStrings.playStepAudio), findsOneWidget);
    });
  });
}
