import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/shared/constants/app_strings.dart';

class ProgrammesScreen extends ConsumerWidget {
  const ProgrammesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.programmes)),
      body: const Center(child: Text(AppStrings.programmes)),
    );
  }
}
