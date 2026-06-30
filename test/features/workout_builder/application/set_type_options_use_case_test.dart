import 'package:aedify/features/workout_builder/application/set_type_options_use_case.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/domain/set_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SetTypeOptionsUseCase', () {
    late SetTypeOptionsUseCase useCase;

    setUp(() {
      useCase = const SetTypeOptionsUseCase();
    });

    test('returns two options', () {
      final options = useCase.execute();
      expect(options.length, 2);
    });

    test('first option is working', () {
      final options = useCase.execute();
      expect(options[0].type, SetType.working);
      expect(options[0].label, AppStrings.setTypeWorking);
      expect(options[0].description, AppStrings.setTypeWorkingDescription);
    });

    test('second option is warmup', () {
      final options = useCase.execute();
      expect(options[1].type, SetType.warmup);
      expect(options[1].label, AppStrings.setTypeWarmup);
      expect(options[1].description, AppStrings.setTypeWarmupDescription);
    });
  });
}
