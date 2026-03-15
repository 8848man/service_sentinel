import 'package:flutter/material.dart';
import '../tokens.dart';

class SSFadeIn extends StatefulWidget {
  const SSFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = SSMotion.slow,
    this.slideFrom = const Offset(0, 0.04),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slideFrom;

  @override
  State<SSFadeIn> createState() => _SSFadeInState();
}

class _SSFadeInState extends State<SSFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: widget.duration);
    final curve =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _fade  = Tween<double>(begin: 0, end: 1).animate(curve);
    _slide =
        Tween<Offset>(begin: widget.slideFrom, end: Offset.zero).animate(curve);
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
