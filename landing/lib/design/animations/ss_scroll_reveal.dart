import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../tokens.dart';

class SSScrollReveal extends StatefulWidget {
  const SSScrollReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = SSMotion.slow,
    this.slideFrom = const Offset(0, 0.05),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slideFrom;

  @override
  State<SSScrollReveal> createState() => _SSScrollRevealState();
}

class _SSScrollRevealState extends State<SSScrollReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Key _visKey;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _visKey = UniqueKey();
    _controller =
        AnimationController(vsync: this, duration: widget.duration);
    final curve =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _fade  = Tween<double>(begin: 0, end: 1).animate(curve);
    _slide =
        Tween<Offset>(begin: widget.slideFrom, end: Offset.zero).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!_triggered && info.visibleFraction > 0.08) {
      _triggered = true;
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visKey,
      onVisibilityChanged: _onVisibilityChanged,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      ),
    );
  }
}
