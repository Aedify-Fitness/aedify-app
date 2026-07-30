import 'package:aedify/features/lift_log/presentation/widgets/history_error_banner.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget widget) {
  return MaterialApp(
    theme: ThemeData(splashFactory: NoSplash.splashFactory),
    home: Scaffold(body: widget),
  );
}

void main() {
  testWidgets('renders an inline error and retries', (tester) async {
    var retryCount = 0;

    await tester.pumpWidget(
      _wrap(
        HistoryErrorBanner(
          message: AppStrings.workoutHistoryLoadFailed,
          onRetry: () => retryCount++,
        ),
      ),
    );

    expect(find.text(AppStrings.workoutHistoryLoadFailed), findsOneWidget);
    expect(find.text(AppStrings.retry), findsOneWidget);

    await tester.tap(find.text(AppStrings.retry));
    await tester.pump();

    expect(retryCount, 1);
  });
}
