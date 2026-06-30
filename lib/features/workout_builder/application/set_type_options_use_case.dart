import 'package:aedify/shared/domain/set_type.dart';
import 'package:aedify/shared/domain/set_type_option.dart';
import 'package:aedify/shared/constants/app_strings.dart';

class SetTypeOptionsUseCase {
  const SetTypeOptionsUseCase();

  List<SetTypeOption> execute() {
    return [
      SetTypeOption(
        type: SetType.working,
        label: AppStrings.setTypeWorking,
        description: AppStrings.setTypeWorkingDescription,
      ),
      SetTypeOption(
        type: SetType.warmup,
        label: AppStrings.setTypeWarmup,
        description: AppStrings.setTypeWarmupDescription,
      ),
    ];
  }
}
