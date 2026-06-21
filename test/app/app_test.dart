import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedify/app/app.dart';

void main() {
  testWidgets('AedifyApp renders without error', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AedifyApp()));
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
