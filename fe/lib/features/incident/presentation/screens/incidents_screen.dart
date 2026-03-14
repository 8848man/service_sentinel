import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/incidents_list_section.dart';

/// Incidents screen - Display and manage incidents
/// Layout only. Provider consumption happens in section widgets.
///
/// Features:
/// - Display all incidents for current project
/// - Filter by status and severity
/// - View incident details
/// - Status visualization
class IncidentsScreen extends StatelessWidget {
  const IncidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Incidents list section (ConsumerWidget)
              IncidentsListSection(),
            ],
          ),
        ),
      ),
    );
  }
}
