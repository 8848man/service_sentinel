import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../providers/service_provider.dart';
import '../../domain/entities/service.dart';

/// Service Create Dialog
///
/// Modal dialog for creating a new monitored service/API.
/// Includes comprehensive form validation and error handling.
/// Consumes createServiceProvider for creation logic.
class ServiceCreateDialog extends ConsumerStatefulWidget {
  const ServiceCreateDialog({super.key});

  @override
  ConsumerState<ServiceCreateDialog> createState() =>
      _ServiceCreateDialogState();
}

class _ServiceCreateDialogState extends ConsumerState<ServiceCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _endpointUrlController = TextEditingController();
  final _timeoutController = TextEditingController(text: '10');
  final _checkIntervalController = TextEditingController(text: '60');
  final _failureThresholdController = TextEditingController(text: '3');

  HttpMethod _selectedHttpMethod = HttpMethod.get;
  ServiceType _selectedServiceType = ServiceType.httpsApi;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _endpointUrlController.dispose();
    _timeoutController.dispose();
    _checkIntervalController.dispose();
    _failureThresholdController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final createData = ServiceCreate(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      endpointUrl: _endpointUrlController.text.trim(),
      httpMethod: _selectedHttpMethod,
      serviceType: _selectedServiceType,
      timeoutSeconds: int.parse(_timeoutController.text),
      checkIntervalSeconds: int.parse(_checkIntervalController.text),
      failureThreshold: int.parse(_failureThresholdController.text),
    );

    final useCase = ref.read(createServiceProvider);
    final result = await useCase.execute(createData);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      // Invalidate services list to refresh
      ref.invalidate(servicesProvider);

      // Close dialog and return the created service
      Navigator.of(context).pop(result.dataOrNull);
    } else {
      final l10n = context.l10n;
      setState(() {
        _errorMessage =
            result.errorOrNull?.message ?? l10n.error_failed_to_create_service;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.services_add_service),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Service Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.services_service_name_required,
                  hintText: l10n.services_service_name_hint,
                  border: const OutlineInputBorder(),
                ),
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.validation_required;
                  }
                  if (value.length > 100) {
                    return l10n.validation_max_length(100);
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Endpoint URL Field
              TextFormField(
                controller: _endpointUrlController,
                decoration: InputDecoration(
                  labelText: l10n.services_endpoint_url_required,
                  hintText: l10n.services_endpoint_url_hint,
                  border: const OutlineInputBorder(),
                ),
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.validation_required;
                  }
                  final urlPattern = RegExp(r'^https?://');
                  if (!urlPattern.hasMatch(value)) {
                    return l10n.validation_url_protocol;
                  }
                  return null;
                },
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // HTTP Method Dropdown
              DropdownButtonFormField<HttpMethod>(
                value: _selectedHttpMethod,
                decoration: InputDecoration(
                  labelText: l10n.services_http_method_required,
                  border: const OutlineInputBorder(),
                ),
                items: HttpMethod.values.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method.displayName(context)),
                  );
                }).toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _selectedHttpMethod = value;
                          });
                        }
                      },
              ),
              const SizedBox(height: 16),

              // Service Type Dropdown
              DropdownButtonFormField<ServiceType>(
                value: _selectedServiceType,
                decoration: InputDecoration(
                  labelText: l10n.services_service_type_required,
                  border: const OutlineInputBorder(),
                ),
                items: ServiceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName(context)),
                  );
                }).toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _selectedServiceType = value;
                          });
                        }
                      },
              ),
              const SizedBox(height: 16),

              // Timeout Seconds Field
              TextFormField(
                controller: _timeoutController,
                decoration: InputDecoration(
                  labelText: l10n.services_timeout_seconds_required,
                  hintText: l10n.services_timeout_hint,
                  border: const OutlineInputBorder(),
                ),
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.validation_required;
                  }
                  final timeout = int.tryParse(value);
                  if (timeout == null || timeout <= 0 || timeout > 300) {
                    return l10n.validation_number_between(1, 300);
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Check Interval Field
              TextFormField(
                controller: _checkIntervalController,
                decoration: InputDecoration(
                  labelText: l10n.services_check_interval_seconds_required,
                  hintText: l10n.services_check_interval_hint,
                  border: const OutlineInputBorder(),
                ),
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.validation_required;
                  }
                  final interval = int.tryParse(value);
                  if (interval == null || interval < 10 || interval > 3600) {
                    return l10n.validation_number_between(10, 3600);
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Failure Threshold Field
              TextFormField(
                controller: _failureThresholdController,
                decoration: InputDecoration(
                  labelText: l10n.services_failure_threshold_required,
                  hintText: l10n.services_failure_threshold_hint,
                  border: const OutlineInputBorder(),
                ),
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.validation_required;
                  }
                  final threshold = int.tryParse(value);
                  if (threshold == null || threshold <= 0 || threshold > 10) {
                    return l10n.validation_number_between(1, 10);
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.services_description_optional,
                  hintText: l10n.services_description_hint,
                  border: const OutlineInputBorder(),
                ),
                enabled: !_isLoading,
                maxLines: 2,
                textInputAction: TextInputAction.done,
              ),

              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        // Cancel Button
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.common_cancel),
        ),

        // Create Button
        ElevatedButton(
          onPressed: _isLoading ? null : _handleCreate,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.common_create),
        ),
      ],
    );
  }
}
