import 'package:freezed_annotation/freezed_annotation.dart';

part 'latency_series.freezed.dart';

/// A single time-bucketed latency measurement
@freezed
class LatencyPoint with _$LatencyPoint {
  const factory LatencyPoint({
    required DateTime bucketStart,
    required double avgMs,
    required double p95Ms,
    required int sampleCount,
  }) = _LatencyPoint;
}

/// Latency time-series for a single service
@freezed
class LatencySeries with _$LatencySeries {
  const factory LatencySeries({
    required int serviceId,
    required String period,
    required String bucket,
    required double avgLatencyMs,
    required double p95LatencyMs,
    required List<LatencyPoint> dataPoints,
  }) = _LatencySeries;
}
