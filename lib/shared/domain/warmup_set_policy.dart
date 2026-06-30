import 'package:aedify/shared/domain/set_type.dart';

class WarmupSetPolicy {
  const WarmupSetPolicy();

  bool isWarmup(SetType setType) => setType == SetType.warmup;

  bool isWorking(SetType setType) => setType == SetType.working;

  bool shouldBeExcludedFromFutureAnalytics(SetType setType) =>
      setType == SetType.warmup;
}
