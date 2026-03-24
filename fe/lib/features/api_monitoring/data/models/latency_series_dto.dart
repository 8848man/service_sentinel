import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/latency_series.dart';

part 'latency_series_dto.freezed.dart';
part 'latency_series_dto.g.dart';

/// DTO for a single time-bucketed latency point
@freezed
class LatencyPointDto with _$LatencyPointDto {
  const factory LatencyPointDto({
    @JsonKey(name: 'bucket_start') required String bucketStart,
    @JsonKey(name: 'avg_ms') required double avgMs,
    @JsonKey(name: 'p95_ms') required double p95Ms,
    @JsonKey(name: 'sample_count') required int sampleCount,
  }) = _LatencyPointDto;

  const LatencyPointDto._();

  factory LatencyPointDto.fromJson(Map<String, dynamic> json) =>
      _$LatencyPointDtoFromJson(json);

  LatencyPoint toDomain() => LatencyPoint(
        bucketStart: DateTime.parse(bucketStart),
        avgMs: avgMs,
        p95Ms: p95Ms,
        sampleCount: sampleCount,
      );
}

/// DTO for a latency time-series response
@freezed
class LatencySeriesDto with _$LatencySeriesDto {
  const factory LatencySeriesDto({
    @JsonKey(name: 'service_id') required int serviceId,
    required String period,
    required String bucket,
    @JsonKey(name: 'avg_latency_ms') required double avgLatencyMs,
    @JsonKey(name: 'p95_latency_ms') required double p95LatencyMs,
    @JsonKey(name: 'data_points') required List<LatencyPointDto> dataPoints,
  }) = _LatencySeriesDto;

  const LatencySeriesDto._();

  factory LatencySeriesDto.fromJson(Map<String, dynamic> json) =>
      _$LatencySeriesDtoFromJson(json);

  LatencySeries toDomain() => LatencySeries(
        serviceId: serviceId,
        period: period,
        bucket: bucket,
        avgLatencyMs: avgLatencyMs,
        p95LatencyMs: p95LatencyMs,
        dataPoints: dataPoints.map((p) => p.toDomain()).toList(),
      );
}
