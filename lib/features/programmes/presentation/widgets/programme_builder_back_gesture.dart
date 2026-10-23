import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Reserves a swipe from the leading edge for programme step navigation.
class ProgrammeBuilderBackGesture extends StatefulWidget {
  const ProgrammeBuilderBackGesture({
    super.key,
    required this.child,
    required this.onBack,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback onBack;
  final bool enabled;

  @override
  State<ProgrammeBuilderBackGesture> createState() =>
      _ProgrammeBuilderBackGestureState();
}

class _ProgrammeBuilderBackGestureState
    extends State<ProgrammeBuilderBackGesture> {
  double _distance = 0;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final direction = rtl ? -1 : 1;
    final screenWidth = MediaQuery.sizeOf(context).width;
    return RawGestureDetector(
      gestures: {
        _EdgeBackDragRecognizer:
            GestureRecognizerFactoryWithHandlers<_EdgeBackDragRecognizer>(
              _EdgeBackDragRecognizer.new,
              (recognizer) {
                recognizer.acceptPointer = (event) =>
                    widget.enabled &&
                    (rtl
                        ? event.position.dx >=
                              screenWidth -
                                  AppProgrammeBuilderTokens.backSwipeEdge
                        : event.position.dx <=
                              AppProgrammeBuilderTokens.backSwipeEdge);
                recognizer.onStart = (_) {
                  _distance = 0;
                };
                recognizer.onUpdate = (details) {
                  _distance += details.delta.dx * direction;
                };
                recognizer.onCancel = () {
                  _distance = 0;
                };
                recognizer.onEnd = (details) {
                  final velocity = (details.primaryVelocity ?? 0) * direction;
                  final completed =
                      _distance >=
                          AppProgrammeBuilderTokens.backSwipeDistance ||
                      (_distance >= AppProgrammeBuilderTokens.backSwipeEdge &&
                          velocity >=
                              AppProgrammeBuilderTokens.backSwipeVelocity);
                  _distance = 0;
                  if (widget.enabled && !recognizer.wasCancelled && completed) {
                    widget.onBack();
                  }
                };
              },
            ),
      },
      child: widget.child,
    );
  }
}

class _EdgeBackDragRecognizer extends HorizontalDragGestureRecognizer {
  bool Function(PointerEvent)? acceptPointer;
  bool wasCancelled = false;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    wasCancelled = false;
    super.addAllowedPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerCancelEvent) {
      wasCancelled = true;
    }
    super.handleEvent(event);
  }

  @override
  bool isPointerAllowed(PointerEvent event) =>
      (acceptPointer?.call(event) ?? false) && super.isPointerAllowed(event);
}
