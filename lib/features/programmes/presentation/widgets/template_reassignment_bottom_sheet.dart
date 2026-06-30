import 'package:flutter/material.dart';
import 'package:aedify/features/programmes/domain/programme_builder_template_draft.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class TemplateReassignmentBottomSheet extends StatelessWidget {
  const TemplateReassignmentBottomSheet({
    super.key,
    this.availableTemplates,
    this.onSelected,
  });

  final List<ProgrammeBuilderTemplateDraft>? availableTemplates;
  final void Function(ProgrammeBuilderTemplateDraft)? onSelected;

  @override
  Widget build(BuildContext context) {
    final templates = availableTemplates ?? [];
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.assignTemplate, style: context.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          if (templates.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: Text(
                  AppStrings.noWorkoutTemplatesAvailable,
                  style: context.textTheme.bodyMedium,
                ),
              ),
            )
          else
            ...templates.map((template) {
              return ListTile(
                title: Text(template.name),
                subtitle: template.dayType != null
                    ? Text(
                        '${AppStrings.dayTypeLabel}: ${template.dayType!.name}',
                      )
                    : null,
                onTap: () {
                  onSelected?.call(template);
                  Navigator.of(context).pop();
                },
              );
            }),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
