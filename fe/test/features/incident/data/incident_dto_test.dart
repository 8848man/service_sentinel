import 'package:flutter_test/flutter_test.dart';
import 'package:service_sentinel_fe_v2/core/constants/enums.dart';
import 'package:service_sentinel_fe_v2/features/incident/data/models/incident_dto.dart';
import 'package:service_sentinel_fe_v2/features/incident/domain/entities/incident.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Shared test fixtures
  // ---------------------------------------------------------------------------

  const fullJson = <String, dynamic>{
    'id': 1,
    'service_id': 10,
    'trigger_check_id': 99,
    'title': 'Service Down',
    'description': 'Health check failed',
    'status': 'open',
    'severity': 'high',
    'consecutive_failures': 3,
    'total_affected_checks': 5,
    'detected_at': '2026-03-25T08:00:00.000Z',
    'resolved_at': '2026-03-25T09:00:00.000Z',
    'acknowledged_at': '2026-03-25T08:30:00.000Z',
    'ai_analysis_requested': true,
    'ai_analysis_completed': false,
  };

  const minimalJson = <String, dynamic>{
    'id': 2,
    'service_id': 20,
    'title': 'Minor Issue',
    'status': 'resolved',
    'severity': 'low',
    'consecutive_failures': 1,
    'total_affected_checks': 1,
    'detected_at': '2026-03-25T10:00:00.000Z',
    'ai_analysis_requested': false,
    'ai_analysis_completed': false,
  };

  // ---------------------------------------------------------------------------
  // IncidentDto.fromJson
  // ---------------------------------------------------------------------------

  group('IncidentDto.fromJson', () {
    test('parses all fields including snake_case key mapping', () {
      final dto = IncidentDto.fromJson(fullJson);

      expect(dto.id, 1);
      expect(dto.serviceId, 10);
      expect(dto.triggerCheckId, 99);
      expect(dto.title, 'Service Down');
      expect(dto.description, 'Health check failed');
      expect(dto.status, 'open');
      expect(dto.severity, 'high');
      expect(dto.consecutiveFailures, 3);
      expect(dto.totalAffectedChecks, 5);
      expect(dto.detectedAt, '2026-03-25T08:00:00.000Z');
      expect(dto.resolvedAt, '2026-03-25T09:00:00.000Z');
      expect(dto.acknowledgedAt, '2026-03-25T08:30:00.000Z');
      expect(dto.aiAnalysisRequested, true);
      expect(dto.aiAnalysisCompleted, false);
    });

    test(
        'nullable fields are null when absent: '
        'triggerCheckId, description, resolvedAt, acknowledgedAt', () {
      final dto = IncidentDto.fromJson(minimalJson);

      expect(dto.triggerCheckId, isNull);
      expect(dto.description, isNull);
      expect(dto.resolvedAt, isNull);
      expect(dto.acknowledgedAt, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // IncidentDto.toDomain()
  // ---------------------------------------------------------------------------

  group('IncidentDto.toDomain()', () {
    test('maps id, serviceId, title, description, consecutiveFailures, '
        'totalAffectedChecks, aiAnalysisRequested, aiAnalysisCompleted', () {
      final incident = IncidentDto.fromJson(fullJson).toDomain();

      expect(incident.id, 1);
      expect(incident.serviceId, 10);
      expect(incident.title, 'Service Down');
      expect(incident.description, 'Health check failed');
      expect(incident.consecutiveFailures, 3);
      expect(incident.totalAffectedChecks, 5);
      expect(incident.aiAnalysisRequested, true);
      expect(incident.aiAnalysisCompleted, false);
    });

    test('parses detectedAt ISO string to DateTime', () {
      final incident = IncidentDto.fromJson(fullJson).toDomain();

      expect(incident.detectedAt, isA<DateTime>());
      expect(incident.detectedAt, DateTime.parse('2026-03-25T08:00:00.000Z'));
    });

    test('parses resolvedAt string to DateTime when present', () {
      final incident = IncidentDto.fromJson(fullJson).toDomain();

      expect(incident.resolvedAt, isNotNull);
      expect(incident.resolvedAt, DateTime.parse('2026-03-25T09:00:00.000Z'));
    });

    test('resolvedAt is null when absent', () {
      final incident = IncidentDto.fromJson(minimalJson).toDomain();

      expect(incident.resolvedAt, isNull);
    });

    test("converts status string 'open' to IncidentStatus.open", () {
      final dto = IncidentDto.fromJson({...fullJson, 'status': 'open'});
      expect(dto.toDomain().status, IncidentStatus.open);
    });

    test("converts status string 'resolved' to IncidentStatus.resolved", () {
      final dto = IncidentDto.fromJson({...fullJson, 'status': 'resolved'});
      expect(dto.toDomain().status, IncidentStatus.resolved);
    });

    test("converts status string 'investigating' to IncidentStatus.investigating",
        () {
      final dto =
          IncidentDto.fromJson({...fullJson, 'status': 'investigating'});
      expect(dto.toDomain().status, IncidentStatus.investigating);
    });

    test("converts status string 'acknowledged' to IncidentStatus.acknowledged",
        () {
      final dto =
          IncidentDto.fromJson({...fullJson, 'status': 'acknowledged'});
      expect(dto.toDomain().status, IncidentStatus.acknowledged);
    });

    test('unknown status string falls back to IncidentStatus.open', () {
      // _parseStatus uses firstWhere with orElse: () => IncidentStatus.open
      final dto =
          IncidentDto.fromJson({...fullJson, 'status': 'unknown_value'});
      expect(dto.toDomain().status, IncidentStatus.open);
    });

    test('converts severity strings to IncidentSeverity enum values', () {
      for (final severity in IncidentSeverity.values) {
        final dto =
            IncidentDto.fromJson({...fullJson, 'severity': severity.name});
        expect(dto.toDomain().severity, severity,
            reason: 'Expected severity.name="${severity.name}" to map to $severity');
      }
    });

    test('unknown severity string falls back to IncidentSeverity.medium', () {
      // _parseSeverity uses firstWhere with orElse: () => IncidentSeverity.medium
      final dto =
          IncidentDto.fromJson({...fullJson, 'severity': 'unknown_severity'});
      expect(dto.toDomain().severity, IncidentSeverity.medium);
    });
  });

  // ---------------------------------------------------------------------------
  // IncidentUpdateDto
  // ---------------------------------------------------------------------------

  group('IncidentUpdateDto', () {
    test('fromJson parses all optional fields', () {
      final dto = IncidentUpdateDto.fromJson({
        'title': 'Updated Title',
        'description': 'Updated description',
        'status': 'resolved',
        'severity': 'critical',
      });

      expect(dto.title, 'Updated Title');
      expect(dto.description, 'Updated description');
      expect(dto.status, 'resolved');
      expect(dto.severity, 'critical');
    });

    test('fromJson yields all-null fields when JSON is empty', () {
      final dto = IncidentUpdateDto.fromJson({});

      expect(dto.title, isNull);
      expect(dto.description, isNull);
      expect(dto.status, isNull);
      expect(dto.severity, isNull);
    });

    test('fromDomain converts IncidentUpdate domain object to DTO', () {
      const update = IncidentUpdate(
        title: 'My Title',
        status: IncidentStatus.investigating,
        severity: IncidentSeverity.high,
      );

      final dto = IncidentUpdateDto.fromDomain(update);

      expect(dto.title, 'My Title');
      expect(dto.description, isNull);
      expect(dto.status, 'investigating');
      expect(dto.severity, 'high');
    });

    test('fromDomain uses enum .name for status and severity strings', () {
      const update = IncidentUpdate(
        status: IncidentStatus.acknowledged,
        severity: IncidentSeverity.low,
      );

      final dto = IncidentUpdateDto.fromDomain(update);

      expect(dto.status, 'acknowledged');
      expect(dto.severity, 'low');
    });

    test('fromDomain produces null status/severity when domain fields are null',
        () {
      const update = IncidentUpdate(title: 'Only title');

      final dto = IncidentUpdateDto.fromDomain(update);

      expect(dto.status, isNull);
      expect(dto.severity, isNull);
    });
  });
}
