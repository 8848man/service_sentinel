import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_sentinel_fe_v2/features/api_monitoring/presentation/widgets/create_service_set_form.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../application/providers/service_provider.dart';
import '../../domain/entities/service.dart';

// /// Create service dialog - Form for registering a new service/API
// /// Consumes: (will use ServiceRepository via use case when creating)
// ///
// /// Features:
// /// - Service name and description
// /// - Endpoint URL
// /// - HTTP method selection
// /// - Service type selection
// /// - Basic configuration (timeout, interval, threshold)
// /// - Input validation
// /// - Loading state within dialog
// ///
// /// Returns: true if service was created successfully
// class CreateServiceSetDialog extends ConsumerStatefulWidget {
//   const CreateServiceSetDialog({super.key});

//   @override
//   ConsumerState<CreateServiceSetDialog> createState() =>
//       _CreateServiceDialogState();
// }

// class _CreateServiceDialogState extends ConsumerState<CreateServiceSetDialog> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _endpointController = TextEditingController();

//   bool _isLoading = false;
//   String? _errorMessage;
//   @override
//   void initState() {
//     super.initState();
//     _nameController.text = '';
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descriptionController.dispose();
//     _endpointController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleCreate() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     final createData = ServiceCreate(
//       name: _nameController.text.trim(),
//       description: _descriptionController.text.trim().isEmpty
//           ? null
//           : _descriptionController.text.trim(),
//       endpointUrl: _endpointController.text.trim(),
//       httpMethod: HttpMethod.get,
//       serviceType: ServiceType.httpsApi,
//       timeoutSeconds: 10,
//       checkIntervalSeconds: 300,
//       failureThreshold: 3,
//     );

//     final useCase = ref.read(createServiceProvider);
//     final result = await useCase.execute(createData);

//     if (!mounted) return;

//     setState(() {
//       _isLoading = false;
//     });

//     if (result.isSuccess) {
//       // Invalidate services list to refresh
//       ref.invalidate(servicesProvider);

//       // Close dialog and return the created service
//       Navigator.of(context).pop(result.dataOrNull);
//     } else {
//       final l10n = context.l10n;
//       setState(() {
//         _errorMessage =
//             result.errorOrNull?.message ?? l10n.error_failed_to_create_service;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final l10n = context.l10n;

// return AlertDialog(
//   title: Text(l10n.services_add_service),
//   content: SingleChildScrollView(
//     child: Form(
//       key: _formKey,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // Service name
//           TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(
//                   labelText: l10n.services_service_name,
//                   hintText: l10n.services_service_name_hint,
//                   prefixIcon: const Icon(Icons.label),
//                   border: const OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return l10n.validation_required;
//                   }
//                   return null;
//                 },
//                 enabled: !_isLoading,
//               ),

//               const SizedBox(height: 16),

//               // Description
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: InputDecoration(
//                   labelText: l10n.services_description_optional,
//                   prefixIcon: const Icon(Icons.description),
//                   border: const OutlineInputBorder(),
//                 ),
//                 maxLines: 2,
//                 enabled: !_isLoading,
//               ),

//               const SizedBox(height: 16),

//               // Endpoint URL
//               TextFormField(
//                 controller: _endpointController,
//                 decoration: InputDecoration(
//                   labelText: l10n.services_endpoint_url,
//                   hintText: l10n.services_endpoint_url_hint,
//                   prefixIcon: const Icon(Icons.link),
//                   border: const OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return l10n.validation_required;
//                   }
//                   if (!value.startsWith('http://') &&
//                       !value.startsWith('https://')) {
//                     return l10n.validation_url_protocol;
//                   }
//                   return null;
//                 },
//                 enabled: !_isLoading,
//               ),
//             ],
//           ),
//         ),
//       ),
//       actions: [
//         // TextButton(
//         //   onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
//         //   child: Text(l10n.common_cancel),
//         // ),
//         ElevatedButton.icon(
//           onPressed: _isLoading ? null : _handleCreate,
//           icon: _isLoading
//               ? const SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 )
//               : const Icon(Icons.add),
//           label: Text(_isLoading ? l10n.common_creating : l10n.common_create),
//         ),
//       ],
//     );
//   }
// }

// class CreateServiceSetDialogTab extends ConsumerStatefulWidget {
//   const CreateServiceSetDialogTab({super.key});

//   @override
//   ConsumerState<CreateServiceSetDialogTab> createState() =>
//       _CreateServiceSetDialogTabState();
// }

// class _CreateServiceSetDialogTabState
//     extends ConsumerState<CreateServiceSetDialogTab>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       // title: const Text('Create Service Set'),
//       content: SizedBox(
//         width: 300,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(
//               height: 400,
//               child: TabBarView(
//                 controller: _tabController,
//                 physics: const NeverScrollableScrollPhysics(), // 드래그 전환 disable
//                 children: const [
//                   CreateServiceForm(
//                     title: 'Landing Page Monitoring',
//                     defaultName: 'Landing Page',
//                   ),
//                   CreateServiceForm(
//                     title: 'Frontend Hosting Monitoring',
//                     defaultName: 'Frontend',
//                   ),
//                   CreateServiceForm(
//                     title: 'API Health Check Monitoring',
//                     defaultName: 'API Server',
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class CreateServiceSetDialog extends StatefulWidget {
  const CreateServiceSetDialog({super.key});

  @override
  State<CreateServiceSetDialog> createState() => _CreateServiceSetDialogState();
}

class _CreateServiceSetDialogState extends State<CreateServiceSetDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int _currentIndex = 0;

  final _tabs = const [
    ('Landing Page', 'Landing Page Monitoring', 'Landing Page'),
    ('Frontend', 'Frontend Hosting Monitoring', 'Frontend'),
    ('API', 'API Health Check Monitoring', 'API Server'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    _tabController.addListener(() {
      if (_currentIndex != _tabController.index) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildCurrentForm() {
    final tab = _tabs[_currentIndex];

    return CreateServiceForm(
      key: ValueKey(_currentIndex),
      title: tab.$2,
      defaultName: tab.$3,
      tabController: _tabController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // const Text(
              //   'Create Service Set',
              //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              // ),
              // const SizedBox(height: 20),
              // TabBar(
              //   controller: _tabController,
              //   tabs: _tabs.map((t) => Tab(text: t.$1)).toList(),
              // ),
              // const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _buildCurrentForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
