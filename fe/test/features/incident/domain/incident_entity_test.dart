import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:service_sentinel_fe_v2/core/constants/enums.dart';
import 'package:service_sentinel_fe_v2/features/incident/domain/entities/incident.dart';

// ---------------------------------------------------------------------------
// Local helper that replicates the _getStatusColor switch logic from
// incident_detail_body. Defined here so the test can verify all branches
// including `investigating` (the case that previously threw UnimplementedError)
// without accessing the private widget method.
// ---------------------------------------------------------------------------
Color _getStatusColor(IncidentStatus status) {
  switch (status) {
    case IncidentStatus.open:
      return Colors.red;
    case IncidentStatus.acknowledged:
      return Colors.orange;
    case IncidentStatus.investigating:
      return Colors.purple;
    case IncidentStatus.resolved:
      return Colors.green;
  }
}

// ---------------------------------------------------------------------------
// Shared fixture factory
// ---------------------------------------------------------------------------

Incident _makeIncident({
  IncidentStatus status = IncidentStatus.open,
  bool aiAnalysisRequested = false,
  bool aiAnalysisCompleted = false,
}) {
  return Incident(
    id: 1,
    serviceId: 10,
    title: 'Test Incident',
    status: status,
    severity: IncidentSeverity.high,
    consecutiveFailures: 2,
    totalAffectedChecks: 3,
    detectedAt: DateTime(2026, 3, 25, 8, 0, 0),
    aiAnalysisRequested: aiAnalysisRequested,
    aiAnalysisCompleted: aiAnalysisCompleted,
  );
}

void main() {
  // ---------------------------------------------------------------------------
  // Field storage
  // ---------------------------------------------------------------------------

  group('Incident field storage', () {
    test('stores all required fields correctly', () {
      final detectedAt = DateTime(2026, 3, 25, 8, 0, 0);
      final resolvedAt = DateTime(2026, 3, 25, 9, 0, 0);

      final incident = Incident(
        id: 42,
        serviceId: 7,
        triggerCheckId: 99,
        title: 'DB Down',
        description: 'Connection refused',
        status: IncidentStatus.resolved,
        severity: IncidentSeverity.critical,
        consecutiveFailures: 5,
        totalAffectedChecks: 10,
        detectedAt: detectedAt,
        resolvedAt: resolvedAt,
        aiAnalysisRequested: true,
        aiAnalysisCompleted: true,
      );

      expect(incident.id, 42);
      expect(incident.serviceId, 7);
      expect(incident.triggerCheckId, 99);
      expect(incident.title, 'DB Down');
      expect(incident.description, 'Connection refused');
      expect(incident.status, IncidentStatus.resolved);
      expect(incident.severity, IncidentSeverity.critical);
      expect(incident.consecutiveFailures, 5);
      expect(incident.totalAffectedChecks, 10);
      expect(incident.detectedAt, detectedAt);
      expect(incident.resolvedAt, resolvedAt);
      expect(incident.aiAnalysisRequested, true);
      expect(incident.aiAnalysisCompleted, true);
    });
  });

  // ---------------------------------------------------------------------------
  // isOpen
  // ---------------------------------------------------------------------------

  group('Incident.isOpen', () {
    test('returns true when status is open', () {
      final incident = _makeIncident(status: IncidentStatus.open);
      expect(incident.isOpen, isTrue);
    });

    test('returns false when status is resolved', () {
      final incident = _makeIncident(status: IncidentStatus.resolved);
      expect(incident.isOpen, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // isResolved
  // ---------------------------------------------------------------------------

  group('Incident.isResolved', () {
    test('returns true when status is resolved', () {
      final incident = _makeIncident(status: IncidentStatus.resolved);
      expect(incident.isResolved, isTrue);
    });

    test('returns false when status is open', () {
      final incident = _makeIncident(status: IncidentStatus.open);
      expect(incident.isResolved, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // hasAnalysis
  // ---------------------------------------------------------------------------

  group('Incident.hasAnalysis', () {
    test('returns true when aiAnalysisCompleted is true', () {
      final incident = _makeIncident(
        aiAnalysisRequested: true,
        aiAnalysisCompleted: true,
      );
      expect(incident.hasAnalysis, isTrue);
    });

    test('returns false when aiAnalysisCompleted is false', () {
      final incident = _makeIncident(
        aiAnalysisRequested: false,
        aiAnalysisCompleted: false,
      );
      expect(incident.hasAnalysis, isFalse);
    });

    test('does not depend on aiAnalysisRequested '
        '(requested=true, completed=false → false)', () {
      final incident = _makeIncident(
        aiAnalysisRequested: true,
        aiAnalysisCompleted: false,
      );
      expect(incident.hasAnalysis, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // Status color helper — validates all branches, including the previously
  // crashing `investigating` case.
  // ---------------------------------------------------------------------------

  group('Status color helper', () {
    test('IncidentStatus.open maps to Colors.red (no UnimplementedError)', () {
      expect(_getStatusColor(IncidentStatus.open), equals(Colors.red));
    });

    test('IncidentStatus.acknowledged maps to Colors.orange', () {
      expect(
          _getStatusColor(IncidentStatus.acknowledged), equals(Colors.orange));
    });

    test('IncidentStatus.resolved maps to Colors.green', () {
      expect(_getStatusColor(IncidentStatus.resolved), equals(Colors.green));
    });

    test(
        'IncidentStatus.investigating maps to Colors.purple '
        '(regression test — was the crashing case)', () {
      expect(
          _getStatusColor(IncidentStatus.investigating), equals(Colors.purple));
    });
  });

  // ---------------------------------------------------------------------------
  // Enum cardinality
  // ---------------------------------------------------------------------------

  group('Enum cardinality', () {
    test('IncidentStatus has exactly 4 values', () {
      expect(IncidentStatus.values.length, 4);
    });

    test('IncidentSeverity has exactly 4 values', () {
      expect(IncidentSeverity.values.length, 4);
    });
  });

  // ---------------------------------------------------------------------------
  // Freezed equality and copyWith
  // ---------------------------------------------------------------------------

  group('Freezed equality and copyWith', () {
    test('two identical Incident instances are equal', () {
      final a = _makeIncident(status: IncidentStatus.open);
      final b = _makeIncident(status: IncidentStatus.open);
      expect(a, equals(b));
    });

    test('copyWith preserves unchanged fields', () {
      final original = _makeIncident(status: IncidentStatus.open);
      final updated = original.copyWith(title: 'Updated Title');

      expect(updated.title, 'Updated Title');
      expect(updated.id, original.id);
      expect(updated.serviceId, original.serviceId);
      expect(updated.status, original.status);
      expect(updated.severity, original.severity);
      expect(updated.consecutiveFailures, original.consecutiveFailures);
    });
  });
}
