import 'package:aedify/shared/constants/app_strings.dart';

class ByokModelOption {
  const ByokModelOption({
    required this.id,
    required this.displayName,
    required this.inputCostPer1kTokens,
    required this.outputCostPer1kTokens,
  });

  final String id;
  final String displayName;
  final double inputCostPer1kTokens;
  final double outputCostPer1kTokens;

  double get totalCostPer1kTokens =>
      inputCostPer1kTokens + outputCostPer1kTokens;

  String get estimatedCostPerWorkout {
    const int estimatedInputTokens = 2000;
    const int estimatedOutputTokens = 1000;
    final cost =
        (estimatedInputTokens / 1000) * inputCostPer1kTokens +
        (estimatedOutputTokens / 1000) * outputCostPer1kTokens;
    if (cost < 0.01) {
      return '${AppStrings.lessThan}\$0.01';
    }
    return '\$${cost.toStringAsFixed(2)}';
  }

  bool get isCheapest => totalCostPer1kTokens == 0;
}
