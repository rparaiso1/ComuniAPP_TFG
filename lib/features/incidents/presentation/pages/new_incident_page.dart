import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/utils/responsive.dart';
import '../controllers/incident_controller.dart';

class NewIncidentPage extends ConsumerStatefulWidget {
  const NewIncidentPage({super.key});

  @override
  ConsumerState<NewIncidentPage> createState() => _NewIncidentPageState();
}

class _NewIncidentPageState extends ConsumerState<NewIncidentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedPriority = 'MEDIUM';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(incidentControllerProvider.notifier).createIncident(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
        );

    final state = ref.read(incidentControllerProvider);
    if (mounted) {
      if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l.error}: ${state.error}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l.incidentCreated),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.goNamed('incidents');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(incidentControllerProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: context.colors.backgroundGradient,
        ),
        child: SafeArea(
          child: FormConstraint(
            child: CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: context.colors.onGradient),
                    tooltip: context.l.goBack,
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.goNamed('incidents'),
                  ),
                ),
                flexibleSpace: Container(
                  decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Text(
                        context.l.newIncidentTitle,
                        style: TextStyle(
                          color: context.colors.onGradient,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),

              // Form
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Título
                        _buildLabel(context.l.title),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _titleController,
                          decoration:
                              _inputDecoration(context.l.describeProblem),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? context.l.titleRequired
                              : null,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),

                        // Descripción
                        _buildLabel(context.l.description),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: _inputDecoration(
                              context.l.detailProblem),
                          maxLines: 5,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? context.l.descriptionRequired
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Prioridad
                        _buildLabel(context.l.priority),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: context.colors.card,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: context.colors.softShadow,
                          ),
                          child: Row(
                            children: [
                              _PriorityChip(
                                label: context.l.priorityLow,
                                value: 'LOW',
                                color: AppColors.success,
                                selected: _selectedPriority == 'LOW',
                                onTap: () =>
                                    setState(() => _selectedPriority = 'LOW'),
                              ),
                              _PriorityChip(
                                label: context.l.priorityMedium,
                                value: 'MEDIUM',
                                color: AppColors.warning,
                                selected: _selectedPriority == 'MEDIUM',
                                onTap: () =>
                                    setState(() => _selectedPriority = 'MEDIUM'),
                              ),
                              _PriorityChip(
                                label: context.l.priorityHigh,
                                value: 'HIGH',
                                color: AppColors.error,
                                selected: _selectedPriority == 'HIGH',
                                onTap: () =>
                                    setState(() => _selectedPriority = 'HIGH'),
                              ),
                              _PriorityChip(
                                label: context.l.priorityCritical,
                                value: 'URGENT',
                                color: const Color(0xFF7B1FA2),
                                selected: _selectedPriority == 'URGENT',
                                onTap: () =>
                                    setState(() => _selectedPriority = 'URGENT'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Ubicación
                        _buildLabel(context.l.locationOptional),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _locationController,
                          decoration: _inputDecoration(
                              context.l.locationExampleLong),
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 32),

                        // Botón enviar
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: state.isCreating ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: context.colors.onGradient,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: state.isCreating
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: context.colors.onGradient,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.send_rounded),
                                      const SizedBox(width: 8),
                                      Text(
                                        context.l.submitIncident,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: context.colors.textPrimary,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textTertiary.withValues(alpha: 0.6)),
      filled: true,
      fillColor: context.colors.inputBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _PriorityChip({
    required this.label,
    required this.value,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: selected ? color : context.colors.border,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? color : context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
