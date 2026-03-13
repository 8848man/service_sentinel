// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../../core/error/app_error.dart';
// import '../../presentation/providers/project_provider.dart';
// import '../../domain/entities/project.dart';

// /// Create project dialog - Form for creating a new project
// /// Consumes: createProjectProvider
// /// Calls: createProject.execute() use case
// ///
// /// Features:
// /// - Input validation
// /// - Loading state within dialog
// /// - Error display within dialog
// /// - Returns true if project was created successfully
// class CreateProjectDialog extends ConsumerStatefulWidget {
//   const CreateProjectDialog({super.key});

//   @override
//   ConsumerState<CreateProjectDialog> createState() => _CreateProjectDialogState();
// }

// class _CreateProjectDialogState extends ConsumerState<CreateProjectDialog> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   bool _isLoading = false;
//   String? _errorMessage;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descriptionController.dispose();
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

//     try {
//       // Call createProject use case via createProjectProvider
//       final useCase = ref.read(createProjectProvider);
//       final result = await useCase.execute(
//         ProjectCreate(
//           name: _nameController.text.trim(),
//           description: _descriptionController.text.trim().isEmpty
//               ? null
//               : _descriptionController.text.trim(),
//         ),
//       );

//       if (!mounted) return;

//       if (result.isSuccess) {
//         // Close dialog and return success
//         Navigator.of(context).pop(true);
//       } else {
//         // Display error within dialog
//         setState(() {
//           _isLoading = false;
//           if (result.errorOrNull is ValidationError) {
//             _errorMessage = result.errorOrNull!.message;
//           } else {
//             _errorMessage = 'Failed to create project. Please try again.';
//           }
//         });
//       }
//     } catch (error) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'An unexpected error occurred';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return AlertDialog(
//       title: const Text('Create New Project'),
//       content: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Project name field
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Project Name',
//                   hintText: 'My Monitoring Project',
//                   prefixIcon: Icon(Icons.folder),
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Project name is required';
//                   }
//                   if (value.length > 100) {
//                     return 'Project name cannot exceed 100 characters';
//                   }
//                   return null;
//                 },
//                 enabled: !_isLoading,
//                 autofocus: true,
//               ),

//               const SizedBox(height: 16),

//               // Project description field
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: const InputDecoration(
//                   labelText: 'Description (Optional)',
//                   hintText: 'Describe your project',
//                   prefixIcon: Icon(Icons.description),
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//                 enabled: !_isLoading,
//               ),

//               // Error message (displayed within dialog)
//               if (_errorMessage != null)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 16),
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: theme.colorScheme.errorContainer,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.error_outline,
//                           color: theme.colorScheme.error,
//                           size: 20,
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             _errorMessage!,
//                             style: theme.textTheme.bodySmall?.copyWith(
//                               color: theme.colorScheme.onErrorContainer,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton.icon(
//           onPressed: _isLoading ? null : _handleCreate,
//           icon: _isLoading
//               ? const SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 )
//               : const Icon(Icons.add),
//           label: Text(_isLoading ? 'Creating...' : 'Create'),
//         ),
//       ],
//     );
//   }
// }
