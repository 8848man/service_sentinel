import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../domain/entities/latency_series.dart';

// ---------------------------------------------------------------------------
// Thresholds (configurable via this constants block – not hardcoded in logic)
// ---------------------------------------------------------------------------
const double _kLatencyNormalThresholdMs = 200.0;
const double _kLatencyDegradedThresholdMs = 500.0;

/// Returns the status color for a given latency value.
Color _statusColor(double latencyMs) {
  if (latencyMs <= _kLatencyNormalThresholdMs) return Colors.green;
  if (latencyMs <= _kLatencyDegradedThresholdMs) return Colors.amber;
  return Colors.red;
}

/// Renders a latency time-series chart using [CustomPainter].
///
/// - Blue solid line: average latency (avg_ms)
/// - Orange dashed line: 95th-percentile latency (p95_ms)
/// - Y-axis labels (ms) on the left
/// - X-axis time labels on the bottom
/// - A colour-coded dot at the latest data point reflecting current status
class LatencyChart extends StatelessWidget {
  final LatencySeries series;

  const LatencyChart({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = series.dataPoints;

    if (points.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'No latency data available for the selected period.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        Row(
          children: [
            _LegendDot(color: Colors.blue),
            const SizedBox(width: 4),
            Text('avg', style: theme.textTheme.labelSmall),
            const SizedBox(width: 12),
            _LegendDash(color: Colors.orange),
            const SizedBox(width: 4),
            Text('p95', style: theme.textTheme.labelSmall),
            const Spacer(),
            _StatusBadge(latencyMs: series.avgLatencyMs),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: CustomPaint(
            painter: _LatencyChartPainter(
              points: points,
              textStyle:
                  theme.textTheme.labelSmall ?? const TextStyle(fontSize: 10),
              surfaceColor: theme.colorScheme.surface,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _LegendDot extends StatelessWidget {
  final Color color;
  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _LegendDash extends StatelessWidget {
  final Color color;
  const _LegendDash({required this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(16, 12),
        painter: _DashPainter(color: color),
      );
}

class _DashPainter extends CustomPainter {
  final Color color;
  const _DashPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    const dashWidth = 4.0;
    const gap = 3.0;
    double x = 0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
      x += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}

class _StatusBadge extends StatelessWidget {
  final double latencyMs;
  const _StatusBadge({required this.latencyMs});

  String get _label {
    if (latencyMs <= _kLatencyNormalThresholdMs) return 'Normal';
    if (latencyMs <= _kLatencyDegradedThresholdMs) return 'Degraded';
    return 'Critical';
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(latencyMs);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        _label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

class _LatencyChartPainter extends CustomPainter {
  final List<LatencyPoint> points;
  final TextStyle textStyle;
  final Color surfaceColor;

  static const double _paddingLeft = 52.0;
  static const double _paddingRight = 12.0;
  static const double _paddingTop = 8.0;
  static const double _paddingBottom = 28.0;
  static const int _yLabelCount = 4;
  static const int _xLabelCount = 4;

  const _LatencyChartPainter({
    required this.points,
    required this.textStyle,
    required this.surfaceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final chartLeft = _paddingLeft;
    final chartRight = size.width - _paddingRight;
    final chartTop = _paddingTop;
    final chartBottom = size.height - _paddingBottom;
    final chartWidth = chartRight - chartLeft;
    final chartHeight = chartBottom - chartTop;

    // Determine Y range
    final maxY = points
        .map((p) => math.max(p.avgMs, p.p95Ms))
        .reduce(math.max)
        .clamp(1.0, double.infinity);
    final minY = 0.0;

    // Grid / axes
    _drawGrid(
        canvas, size, chartLeft, chartRight, chartTop, chartBottom, minY, maxY);

    // Avg line (solid blue)
    _drawLine(
      canvas: canvas,
      points: points,
      getValue: (p) => p.avgMs,
      color: Colors.blue,
      dashed: false,
      left: chartLeft,
      top: chartTop,
      width: chartWidth,
      height: chartHeight,
      minY: minY,
      maxY: maxY,
    );

    // P95 line (dashed orange)
    _drawLine(
      canvas: canvas,
      points: points,
      getValue: (p) => p.p95Ms,
      color: Colors.orange,
      dashed: true,
      left: chartLeft,
      top: chartTop,
      width: chartWidth,
      height: chartHeight,
      minY: minY,
      maxY: maxY,
    );

    // X-axis labels
    _drawXLabels(canvas, size, points, chartLeft, chartBottom, chartWidth);
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
    double left,
    double right,
    double top,
    double bottom,
    double minY,
    double maxY,
  ) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.5;

    final axisPaint = Paint()
      ..color = Colors.grey.withOpacity(0.6)
      ..strokeWidth = 1.0;

    // Horizontal grid lines + Y labels
    for (int i = 0; i <= _yLabelCount; i++) {
      final fraction = i / _yLabelCount;
      final y = bottom - fraction * (bottom - top);
      canvas.drawLine(Offset(left, y), Offset(right, y), gridPaint);

      final value = minY + fraction * (maxY - minY);
      _drawText(
        canvas,
        '${value.toStringAsFixed(0)}ms',
        Offset(0, y - 6),
        maxWidth: left - 4,
        align: TextAlign.right,
      );
    }

    // Axes
    canvas.drawLine(Offset(left, top), Offset(left, bottom), axisPaint);
    canvas.drawLine(Offset(left, bottom), Offset(right, bottom), axisPaint);
  }

  void _drawLine({
    required Canvas canvas,
    required List<LatencyPoint> points,
    required double Function(LatencyPoint) getValue,
    required Color color,
    required bool dashed,
    required double left,
    required double top,
    required double width,
    required double height,
    required double minY,
    required double maxY,
  }) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final n = points.length;
    for (int i = 0; i < n; i++) {
      final x = left + (i / (n - 1 == 0 ? 1 : n - 1)) * width;
      final ratio = (getValue(points[i]) - minY) / (maxY - minY);
      final y = top + height - ratio.clamp(0.0, 1.0) * height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    if (dashed) {
      _drawDashedPath(canvas, path, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    const dashLength = 6.0;
    const gapLength = 4.0;
    for (final metric in metrics) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dashLength : gapLength;
        if (draw) {
          canvas.drawPath(
            metric.extractPath(
                distance, math.min(distance + len, metric.length)),
            paint,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
  }

  void _drawXLabels(
    Canvas canvas,
    Size size,
    List<LatencyPoint> points,
    double left,
    double bottom,
    double width,
  ) {
    final n = points.length;
    if (n == 0) return;

    final step = math.max(1, (n / _xLabelCount).ceil());
    for (int i = 0; i < n; i += step) {
      final x = left + (i / (n - 1 == 0 ? 1 : n - 1)) * width;
      final dt = points[i].bucketStart.toLocal();
      final label =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      _drawText(
        canvas,
        label,
        Offset(x - 16, bottom + 4),
        maxWidth: 36,
        align: TextAlign.center,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    required double maxWidth,
    TextAlign align = TextAlign.left,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle.copyWith(
          color: Colors.grey.shade600,
          fontSize: 9,
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_LatencyChartPainter old) =>
      old.points.length != points.length || old.textStyle != textStyle;
}
