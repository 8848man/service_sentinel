import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../tokens.dart';

class SSHoverScale extends StatefulWidget {
  const SSHoverScale({
    super.key,
    required this.child,
    this.scale = 1.03,
    this.duration = SSMotion.fast,
  });

  final Widget child;
  final double scale;
  final Duration duration;

  @override
  State<SSHoverScale> createState() => _SSHoverScaleState();
}

class _SSHoverScaleState extends State<SSHoverScale> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && MediaQuery.sizeOf(context).width < SSBreakpoint.mobile) {
      return widget.child;
    }
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? widget.scale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
