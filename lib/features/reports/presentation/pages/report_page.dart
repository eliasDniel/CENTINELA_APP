// RF-0303: Report page - Modern 3 step form with improved UX
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/incident_type_chips.dart';
import '../../../../core/utils/app_colors.dart' as app_colors;

class ReportPage extends ConsumerStatefulWidget {
  static const String routeName = 'report/new';
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  String? _selectedType;
  late TextEditingController _descriptionController;
  bool _hasAttachment = false;
  late AnimationController _animationController;

  // Mock GPS
  final double _mockLat = -2.1234;
  final double _mockLng = -79.5678;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && _selectedType == null) {
      _showErrorSnackBar('Selecciona un tipo de incidente');
      return;
    }
    if (_currentStep == 1 && _descriptionController.text.isEmpty) {
      _showErrorSnackBar('Escribe una descripción del incidente');
      return;
    }
    _animationController.reset();
    _animationController.forward();
    setState(() => _currentStep++);
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _animationController.reset();
      _animationController.forward();
      setState(() => _currentStep--);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _submitReport() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade900, Colors.blue.shade700],
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 4,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Enviando reporte...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Por favor espera',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    Future.delayed(const Duration(milliseconds: 1500), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Reporte enviado correctamente')),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
      Future.delayed(
        const Duration(milliseconds: 500),
        () => context.go('/home/2'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Reporte'), centerTitle: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Progress indicator - Line with cuts
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              children: [
                // Step label and counter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ['Selecciona el tipo', 'Agrega detalles', 'Confirma tu reporte'][_currentStep],
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.grey.shade300,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '${_currentStep + 1}/3',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: app_colors.AppConfig.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress line with cuts
                SizedBox(
                  height: 24,
                  child: Row(
                    children: List.generate(3, (index) {
                      bool isActive = index <= _currentStep;
                      
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Horizontal line
                            Container(
                              height: 2,
                              color: isActive
                                  ? app_colors.AppConfig.primary
                                  : Colors.grey.shade700,
                            ),
                            // Cut marker
                            const SizedBox(height: 6),
                            Container(
                              width: 2,
                              height: 10,
                              color: isActive
                                  ? app_colors.AppConfig.primary
                                  : Colors.grey.shade700,
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: FadeTransition(
              opacity: _animationController,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                children: [
                  if (_currentStep == 0) _buildStep1Content(),
                  if (_currentStep == 1) _buildStep2Content(),
                  if (_currentStep == 2) _buildStep3Content(),
                ],
              ),
            ),
          ),
          // Buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: app_colors.AppConfig.primary),
                      ),
                      child: const Text('Atrás'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentStep == 2 ? _submitReport : _nextStep,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: app_colors.AppConfig.primary,
                    ),
                    child: Text(
                      _currentStep == 2 ? 'Enviar Reporte' : 'Siguiente',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Qué tipo de incidente reportas?',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona la categoría que mejor describe el evento',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
        ),
        const SizedBox(height: 24),
        IncidentTypeChipsWidget(
          onSelected: (type) => setState(() => _selectedType = type),
          selectedType: _selectedType,
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStep2Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cuéntanos más detalles',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Describe qué sucedió, incluye detalles importantes',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
        ),
        const SizedBox(height: 24),
        // Incident type badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: app_colors.AppConfig.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: app_colors.AppConfig.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.label, size: 16, color: app_colors.AppConfig.primary),
              const SizedBox(width: 8),
              Text(
                _selectedType?.replaceAll('_', ' ') ?? '',
                style: TextStyle(
                  color: app_colors.AppConfig.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Description field
        TextField(
          controller: _descriptionController,
          maxLength: 280,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'Descripción del incidente',
            hintText:
                'Describe lo que pasó, dónde, cuándo y otros detalles relevantes...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade700),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: app_colors.AppConfig.primary,
                width: 2,
              ),
            ),
            counterText: '${_descriptionController.text.length}/280',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),
        // GPS Info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade900.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade700.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on,
                  size: 20,
                  color: Colors.blue.shade300,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ubicación detectada',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$_mockLat, $_mockLng',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Attachment toggle
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade700),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SwitchListTile(
            title: const Text('Adjuntar foto o video'),
            subtitle: const Text('Añade evidencia visual'),
            value: _hasAttachment,
            activeColor: app_colors.AppConfig.primary,
            onChanged: (value) => setState(() => _hasAttachment = value),
          ),
        ),
        if (_hasAttachment) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade900.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade700.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: Colors.amber.shade300,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cámara no disponible en demo',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Esta función está en desarrollo',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStep3Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Revisa tu reporte',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Asegúrate de que todo sea correcto antes de enviar',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
        ),
        const SizedBox(height: 24),
        // Review card
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade700),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Type section
              _buildReviewSection(
                icon: Icons.label,
                title: 'Tipo de incidente',
                value: _selectedType?.replaceAll('_', ' ') ?? 'N/A',
                backgroundColor: Colors.blue.shade900.withOpacity(0.1),
              ),
              Divider(color: Colors.grey.shade700, height: 1),
              // Description section
              _buildReviewSection(
                icon: Icons.description,
                title: 'Descripción',
                value: _descriptionController.text,
                backgroundColor: Colors.green.shade900.withOpacity(0.1),
                isLongText: true,
              ),
              Divider(color: Colors.grey.shade700, height: 1),
              // GPS section
              _buildReviewSection(
                icon: Icons.location_on,
                title: 'Ubicación',
                value: '$_mockLat, $_mockLng',
                backgroundColor: Colors.purple.shade900.withOpacity(0.1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Confirmation message
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade900.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade700.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.green.shade300),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tu reporte será revisado por el equipo de seguridad',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade300),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildReviewSection({
    required IconData icon,
    required String title,
    required String value,
    required Color backgroundColor,
    bool isLongText = false,
  }) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: app_colors.AppConfig.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: isLongText ? 3 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
