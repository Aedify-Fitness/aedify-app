import 'package:aedify/features/programmes/presentation/widgets/programme_builder_back_gesture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Harness {
  _Harness._();

  static Widget wrap({
    required VoidCallback onBack,
    bool enabled = true,
    TextDirection direction = TextDirection.ltr,
    Widget child = const SizedBox.expand(),
  }) => MaterialApp(
    home: Directionality(
      textDirection: direction,
      child: ProgrammeBuilderBackGesture(
        enabled: enabled,
        onBack: onBack,
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  testWidgets('RTL back swipe starts at the right edge and moves left', (
    tester,
  ) async {
    var backs = 0;
    await tester.pumpWidget(
      _Harness.wrap(onBack: () => backs++, direction: TextDirection.rtl),
    );
    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    await tester.dragFrom(Offset(width - 4, 200), const Offset(-180, 0));
    expect(backs, 1);
    await tester.dragFrom(const Offset(4, 200), const Offset(180, 0));
    expect(backs, 1);
  });

  testWidgets('disabled and cancelled swipes do not call back', (tester) async {
    var backs = 0;
    await tester.pumpWidget(
      _Harness.wrap(onBack: () => backs++, enabled: false),
    );
    await tester.dragFrom(const Offset(4, 200), const Offset(180, 0));
    expect(backs, 0);
    await tester.pumpWidget(_Harness.wrap(onBack: () => backs++));
    final gesture = await tester.startGesture(const Offset(4, 200));
    await gesture.moveBy(const Offset(180, 0));
    await gesture.cancel();
    expect(backs, 0);
  });

  testWidgets('a horizontal list away from the edge keeps scrolling', (
    tester,
  ) async {
    var backs = 0;
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _Harness.wrap(
        onBack: () => backs++,
        child: ListView(
          controller: controller,
          scrollDirection: Axis.horizontal,
          children: const [SizedBox(width: 1600)],
        ),
      ),
    );
    await tester.dragFrom(const Offset(300, 200), const Offset(-180, 0));
    await tester.pumpAndSettle();
    expect(controller.offset, greaterThan(0));
    expect(backs, 0);
  });
}
