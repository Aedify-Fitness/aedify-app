import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:aedify/shared/theme/app_spacing.dart';
import 'package:aedify/shared/theme/context_extensions.dart';

class OnboardingMetricRuler extends StatefulWidget {
  const OnboardingMetricRuler({
    super.key,
    required this.keyPrefix,
    required this.label,
    required this.value,
    required this.defaultValue,
    required this.minimumValue,
    required this.maximumValue,
    required this.step,
    required this.onChanged,
  });

  static const _tickCount = 41;
  static const _settleDuration = Duration(milliseconds: 240);
  static const _velocityProjectionSeconds = 0.18;
  static const _maximumProjectedSteps = 8.0;
  static const _positionEpsilon = 0.001;

  final String keyPrefix;
  final String label;
  final double? value;
  final double defaultValue;
  final double minimumValue;
  final double maximumValue;
  final double step;
  final void Function(double value) onChanged;

  @override
  State<OnboardingMetricRuler> createState() => _MetricRulerState();
}

class _MetricRulerState extends State<OnboardingMetricRuler>
    with SingleTickerProviderStateMixin {
  late final AnimationController _settleController;
  Animation<double>? _settleAnimation;
  late double _positionInSteps;
  double? _localValue;
  late int _lastEmittedStep;
  bool _isDragging = false;
  bool _disableAnimations = false;

  double get _effectiveValue =>
      (_localValue ?? widget.value ?? widget.defaultValue)
          .clamp(widget.minimumValue, widget.maximumValue)
          .toDouble();

  int get _maximumStep =>
      ((widget.maximumValue - widget.minimumValue) / widget.step).floor();

  @override
  void initState() {
    super.initState();
    _positionInSteps = _positionForValue(_effectiveValue);
    _lastEmittedStep = _stepForPosition(_positionInSteps);
    _settleController = AnimationController(
      vsync: this,
      duration: OnboardingMetricRuler._settleDuration,
    )..addListener(_handleSettleTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  }

  @override
  void didUpdateWidget(OnboardingMetricRuler oldWidget) {
    super.didUpdateWidget(oldWidget);
    final scaleChanged =
        oldWidget.minimumValue != widget.minimumValue ||
        oldWidget.maximumValue != widget.maximumValue ||
        oldWidget.step != widget.step;
    final valueChanged =
        oldWidget.value != widget.value ||
        oldWidget.defaultValue != widget.defaultValue;
    if (!scaleChanged && !valueChanged) return;

    _localValue = widget.value;
    final nextPosition = _positionForValue(_effectiveValue);
    final nextStep = _stepForPosition(nextPosition);
    final reflectsRulerChange =
        !scaleChanged &&
        (_isDragging || _settleController.isAnimating) &&
        nextStep == _lastEmittedStep;

    if (!reflectsRulerChange) {
      _settleController.stop();
      _settleAnimation = null;
      _isDragging = false;
      _positionInSteps = nextPosition;
      _lastEmittedStep = nextStep;
    }
  }

  @override
  void dispose() {
    _settleController.dispose();
    super.dispose();
  }

  double _positionForValue(double value) {
    return ((value - widget.minimumValue) / widget.step)
        .clamp(0.0, _maximumStep.toDouble())
        .toDouble();
  }

  int _stepForPosition(double position) {
    return position.round().clamp(0, _maximumStep).toInt();
  }

  double _valueForStep(int step) {
    return (widget.minimumValue + (step * widget.step))
        .clamp(widget.minimumValue, widget.maximumValue)
        .toDouble();
  }

  void _applyPosition(double position, {required bool notify}) {
    final nextPosition = position
        .clamp(0.0, _maximumStep.toDouble())
        .toDouble();
    final nextStep = _stepForPosition(nextPosition);

    setState(() {
      _positionInSteps = nextPosition;
    });

    if (!notify || nextStep == _lastEmittedStep) return;

    _lastEmittedStep = nextStep;
    final nextValue = _valueForStep(nextStep);
    _localValue = nextValue;
    widget.onChanged(nextValue);
  }

  void _handleSettleTick() {
    final animation = _settleAnimation;
    if (animation == null) return;
    _applyPosition(animation.value, notify: true);
  }

  void _animateToPosition(double target) {
    final snappedTarget = target
        .roundToDouble()
        .clamp(0.0, _maximumStep.toDouble())
        .toDouble();
    _settleController.stop();

    if (_disableAnimations ||
        (snappedTarget - _positionInSteps).abs() <
            OnboardingMetricRuler._positionEpsilon) {
      _settleAnimation = null;
      _applyPosition(snappedTarget, notify: true);
      return;
    }

    _settleAnimation =
        Tween<double>(begin: _positionInSteps, end: snappedTarget).animate(
          CurvedAnimation(
            parent: _settleController,
            curve: Curves.easeOutCubic,
          ),
        );
    _settleController.forward(from: 0);
  }

  void _handleDragStart(DragStartDetails details) {
    _settleController.stop();
    _settleAnimation = null;
    _isDragging = true;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _applyPosition(
      _positionInSteps - (details.delta.dx / AppSpacing.controlGap),
      notify: true,
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    _isDragging = false;
    final velocity = details.primaryVelocity ?? 0;
    final projectedSteps =
        (-(velocity / AppSpacing.controlGap) *
                OnboardingMetricRuler._velocityProjectionSeconds)
            .clamp(
              -OnboardingMetricRuler._maximumProjectedSteps,
              OnboardingMetricRuler._maximumProjectedSteps,
            )
            .toDouble();
    _animateToPosition(_positionInSteps + projectedSteps);
  }

  void _handleDragCancel() {
    _isDragging = false;
    _animateToPosition(_positionInSteps);
  }

  void _handleTap(TapUpDetails details, double width) {
    final tappedStepOffset =
        (details.localPosition.dx - (width / 2)) / AppSpacing.controlGap;
    _animateToPosition(_positionInSteps + tappedStepOffset);
  }

  void _increase() {
    _animateToPosition((_lastEmittedStep + 1).toDouble());
  }

  void _decrease() {
    _animateToPosition((_lastEmittedStep - 1).toDouble());
  }

  String _semanticValue(double value) {
    return widget.step < 1
        ? value.toStringAsFixed(1)
        : value.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    final value = _effectiveValue;
    final centerTick = _positionInSteps.floor();
    final fractionalPosition = _positionInSteps - centerTick;
    final firstTick = centerTick - (OnboardingMetricRuler._tickCount ~/ 2);
    final tickStripWidth =
        OnboardingMetricRuler._tickCount * AppSpacing.controlGap;

    return Semantics(
      slider: true,
      label: widget.label,
      value: _semanticValue(value),
      increasedValue: _semanticValue(
        (value + widget.step)
            .clamp(widget.minimumValue, widget.maximumValue)
            .toDouble(),
      ),
      decreasedValue: _semanticValue(
        (value - widget.step)
            .clamp(widget.minimumValue, widget.maximumValue)
            .toDouble(),
      ),
      onIncrease: _increase,
      onDecrease: _decrease,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            dragStartBehavior: DragStartBehavior.down,
            onHorizontalDragStart: _handleDragStart,
            onHorizontalDragUpdate: _handleDragUpdate,
            onHorizontalDragEnd: _handleDragEnd,
            onHorizontalDragCancel: _handleDragCancel,
            onTapUp: (details) => _handleTap(details, constraints.maxWidth),
            child: SizedBox(
              height: AppSizing.onboardingMetricRulerHeight,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned.fill(
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.bottomCenter,
                        minWidth: tickStripWidth,
                        maxWidth: tickStripWidth,
                        minHeight: AppSizing.onboardingMetricRulerHeight,
                        maxHeight: AppSizing.onboardingMetricRulerHeight,
                        child: Transform.translate(
                          key: ValueKey<String>(
                            '${widget.keyPrefix}_tick_strip',
                          ),
                          offset: Offset(
                            -fractionalPosition * AppSpacing.controlGap,
                            0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List<Widget>.generate(
                              OnboardingMetricRuler._tickCount,
                              (index) {
                                final tick = firstTick + index;
                                final isInRange =
                                    tick >= 0 && tick <= _maximumStep;
                                final major = tick % 5 == 0;

                                return SizedBox(
                                  width: AppSpacing.controlGap,
                                  child: isInRange
                                      ? Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            key: ValueKey<String>(
                                              '${widget.keyPrefix}_tick_$tick',
                                            ),
                                            width: major
                                                ? AppSizing.strokeWidth
                                                : AppSizing.divider,
                                            height: major
                                                ? AppSizing
                                                      .onboardingMetricRulerMajorTick
                                                : AppSizing
                                                      .onboardingMetricRulerMinorTick,
                                            color: major
                                                ? context.colorScheme.outline
                                                : context
                                                      .colorScheme
                                                      .outlineVariant,
                                          ),
                                        )
                                      : null,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: AppSizing.strokeWidth,
                      height: AppSizing.onboardingMetricRulerHeight,
                      decoration: BoxDecoration(
                        color: context.theme.brightness == Brightness.dark
                            ? context.colorScheme.primary
                            : context.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
