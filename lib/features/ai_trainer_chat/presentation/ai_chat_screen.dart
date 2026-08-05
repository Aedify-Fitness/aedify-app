import 'package:aedify/shared/constants/app_strings.dart';
import 'package:aedify/shared/widgets/app_bottom_navigation_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiChatScreen extends ConsumerWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.aiTrainer)),
      body: const AppBottomNavigationContentInset(
        child: Center(child: Text(AppStrings.aiChat)),
      ),
    );
  }
}
