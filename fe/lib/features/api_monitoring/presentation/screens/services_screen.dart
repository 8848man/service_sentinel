import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/services_list_section.dart';

/// Services screen - Display and manage monitored APIs/services
/// Layout only. Provider consumption happens in section widgets.
///
/// Features:
/// - Display all services for current project
/// - Create new service
/// - View service health status
/// - Navigate to service detail
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Services list section (ConsumerWidget)
              ServicesListSection(),
            ],
          ),
        ),
      ),
    );
  }
}
