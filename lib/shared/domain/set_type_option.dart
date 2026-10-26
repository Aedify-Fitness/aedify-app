import 'package:aedify/shared/domain/set_type.dart';

class SetTypeOption {
  const SetTypeOption({
    required this.type,
    required this.label,
    required this.description,
  });

  final SetType type;
  final String label;
  final String description;
}
