import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/shared/constants/app_strings.dart';

class LiftLogScreen extends ConsumerWidget {
  const LiftLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.liftLog)),
      body: const Center(child: Text(AppStrings.liftLog)),
    );
  }
}
