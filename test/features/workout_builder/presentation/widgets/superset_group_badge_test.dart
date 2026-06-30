import 'package:aedify/features/workout_builder/presentation/widgets/superset_group_badge.dart';
import 'package:aedify/shared/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget widget) {
  return MaterialApp(home: Scaffold(body: widget));
}

void main() {
  group('SupersetGroupBadge', () {
    testWidgets('renders superset label with order', (tester) async {
      await tester.pumpWidget(
        _wrap(const SupersetGroupBadge(groupId: 'g1', order: 0)),
      );
      expect(find.text('Superset 1'), findsOneWidget);
    });

    testWidgets('renders without order', (tester) async {
      await tester.pumpWidget(_wrap(const SupersetGroupBadge(groupId: 'g1')));
      expect(find.text(AppStrings.superset), findsOneWidget);
    });
  });
}
