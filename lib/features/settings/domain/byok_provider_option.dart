import 'package:aedify/features/settings/domain/byok_model_option.dart';

class ByokProviderOption {
  const ByokProviderOption({
    required this.id,
    required this.providerName,
    required this.displayName,
    required this.description,
    required this.models,
  });

  final String id;
  final String providerName;
  final String displayName;
  final String description;
  final List<ByokModelOption> models;
}
