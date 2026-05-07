// RF-0303: Report page - 3 step stepper
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/incident_type_chips.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  int _currentStep = 0;
  String? _selectedType;
  late TextEditingController _descriptionController;
  bool _hasAttachment = false;

  // Mock GPS
  final double _mockLat = -2.1234;
  final double _mockLng = -79.5678;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Reporte')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0 && _selectedType == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Selecciona un tipo de incidente')),
            );
            return;
          }
          if (_currentStep == 1 && _descriptionController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Escribe una descripción')),
            );
            return;
          }
          setState(() => _currentStep++);
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        steps: [
          // Step 1: Type
          Step(
            title: const Text('Tipo'),
            subtitle: _selectedType != null
                ? Text(_selectedType!.replaceAll('_', ' '))
                : const Text('Selecciona un tipo'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IncidentTypeChipsWidget(
                  onSelected: (type) => setState(() => _selectedType = type),
                  selectedType: _selectedType,
                ),
              ],
            ),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          // Step 2: Description
          Step(
            title: const Text('Descripción'),
            subtitle: _descriptionController.text.isNotEmpty
                ? Text(
                    '${_descriptionController.text.length}/280',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : const Text('Describe el incidente'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _descriptionController,
                  maxLength: 280,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Describe lo que pasó...',
                    counterText: '',
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'GPS: $_mockLat, $_mockLng (simulado)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Adjuntar foto/video'),
                  value: _hasAttachment,
                  onChanged: (value) => setState(() => _hasAttachment = value),
                ),
                if (_hasAttachment)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.camera_alt),
                        const SizedBox(width: 8),
                        const Text('📷 Cámara no disponible en demo'),
                      ],
                    ),
                  ),
              ],
            ),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          // Step 3: Confirm
          Step(
            title: const Text('Confirmar'),
            subtitle: const Text('Revisa antes de enviar'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tipo: ${_selectedType?.replaceAll('_', ' ') ?? 'N/A'}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Descripción: ${_descriptionController.text}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'GPS: $_mockLat, $_mockLng',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              const Text('Enviando reporte...'),
                            ],
                          ),
                        ),
                      );
                      Future.delayed(
                        const Duration(milliseconds: 1500),
                        () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  '✅ Reporte enviado correctamente'),
                            ),
                          );
                          context.go('/home');
                        },
                      );
                    },
                    child: const Text('Enviar Reporte'),
                  ),
                ),
              ],
            ),
            isActive: _currentStep >= 2,
            state: StepState.indexed,
          ),
        ],
      ),
    );
  }
}
