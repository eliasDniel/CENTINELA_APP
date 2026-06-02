// RF-0302, RF-0707: privacidad y eliminación de cuenta (LOPDP)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/app_colors.dart';

class PrivacyPage extends ConsumerWidget {
  static const routeName = 'privacy';

  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    if (user == null || user.isVisitor) {
      return Scaffold(
        appBar: AppBar(title: const Text('Privacidad')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Inicia sesión para gestionar tu privacidad',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go('/auth'),
                  child: const Text('Iniciar sesión'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Privacidad y datos')),
      body: ListView(
        padding: const EdgeInsets.all(AppConfig.horizontalMargin),
        children: [
          _SectionCard(
            icon: Icons.shield_outlined,
            title: 'Pseudonimización',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Los operadores de Centinela Milagro solo ven tu pseudónimo '
                  '(UUID), nunca tu alias real ni tu teléfono. Tus reportes y '
                  'alertas SOS se vinculan a ese identificador anónimo.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppConfig.textSecondary,
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConfig.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppConfig.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.fingerprint,
                          color: AppConfig.primaryLight, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tu pseudónimo',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: AppConfig.textTertiary),
                            ),
                            SelectableText(
                              user.uuid,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copiar',
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: user.uuid),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pseudónimo copiado'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.storage_outlined,
            title: 'Datos que guardamos',
            child: Column(
              children: const [
                _DataRow(
                  icon: Icons.person_outline,
                  label: 'Alias',
                  detail: 'Cifrado en reposo · solo tú lo ves en la app',
                ),
                _DataRow(
                  icon: Icons.location_on_outlined,
                  label: 'Barrio',
                  detail: 'Para filtrar alertas y reportes de tu zona',
                ),
                _DataRow(
                  icon: Icons.report_outlined,
                  label: 'Reportes',
                  detail: 'Vinculados a tu pseudónimo, sin nombre real',
                ),
                _DataRow(
                  icon: Icons.phone_outlined,
                  label: 'Teléfono',
                  detail: 'Opcional · cifrado si lo proporcionaste',
                ),
                _DataRow(
                  icon: Icons.gps_fixed,
                  label: 'Ubicación',
                  detail: 'Solo al enviar SOS o reportes, no rastreo continuo',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.description_outlined,
            title: 'Documentos legales',
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.privacy_tip_outlined,
                      color: AppConfig.primary),
                  title: const Text('Política de privacidad'),
                  subtitle: const Text('LOPDP Ecuador · tratamiento de datos'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLegalSheet(
                    context,
                    title: 'Política de privacidad',
                    body: _privacyPolicyText,
                  ),
                ),
                const Divider(height: 1, color: Colors.white24),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      const Icon(Icons.gavel_outlined, color: AppConfig.primary),
                  title: const Text('Términos de uso'),
                  subtitle: const Text('Condiciones del servicio Centinela'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLegalSheet(
                    context,
                    title: 'Términos de uso',
                    body: _termsText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Derecho al olvido (LOPDP Art. 19)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Puedes eliminar tu cuenta y todos tus datos de forma permanente. '
            'Esta acción no se puede deshacer.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppConfig.textSecondary,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppConfig.error,
              side: const BorderSide(color: AppConfig.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => _confirmDeleteAccount(context, ref),
            icon: const Icon(Icons.delete_forever_outlined),
            label: const Text('Eliminar mi cuenta'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showLegalSheet(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppConfig.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppConfig.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppConfig.textSecondary,
                          height: 1.5,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar tu cuenta?'),
        content: const Text(
          'Se borrarán tu cuenta, tokens e historial de reportes de forma '
          'permanente. No podrás recuperar tus datos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppConfig.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Eliminando cuenta...'),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    ref.read(authProvider.notifier).logout();
    context.go('/auth');
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppConfig.primary, size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.icon,
    required this.label,
    required this.detail,
  });

  final IconData icon;
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppConfig.textTertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  detail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConfig.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _privacyPolicyText = '''
Centinela Milagro trata tus datos conforme a la Ley Orgánica de Protección de Datos Personales (LOPDP) de Ecuador.

Responsable del tratamiento: GAD Municipal / operador Centinela Milagro.

Finalidad: gestionar alertas de seguridad ciudadana, reportes anónimos y notificaciones por barrio.

Base legal: consentimiento del titular y interés público en seguridad comunitaria.

Datos tratados: alias (cifrado), pseudónimo UUID, barrio, teléfono opcional (cifrado), ubicación puntual en SOS/reportes, historial de reportes vinculado al pseudónimo.

Tus derechos: acceso, rectificación, eliminación (Art. 19), oposición y portabilidad. Contacto: privacidad@centinela-milagro.gob.ec

Conservación: mientras mantengas la cuenta activa o el plazo legal aplicable.
''';

const _termsText = '''
Al usar Centinela Milagro aceptas:

1. Usar la app de forma responsable; las falsas alertas pueden tener consecuencias legales.
2. No suplantar identidades ni abusar del botón SOS.
3. Aceptar que tus reportes son pseudonimizados y visibles para operadores autorizados.
4. Recibir notificaciones push según tu barrio y suscripciones configuradas.
5. Que el servicio es un complemento, no sustituto, de emergencias oficiales (ECU-911).

El municipio puede suspender cuentas por uso indebido.

Versión prototipo · Milagro, Ecuador.
''';
