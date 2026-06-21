import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/shared/constants/app_strings.dart';

class ProgressMediaScreen extends ConsumerWidget {
  const ProgressMediaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.progressMedia)),
      body: const Center(child: Text(AppStrings.progressMedia)),
    );
  }
}
