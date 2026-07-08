// RF-0301, RF-0302: Auth page with login and register tabs
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/view_insets.dart';
import '../../../../core/utils/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';
import '../widgets/privacy_badge_widget.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BarrioSeguro'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalMargin,
        ),
        child: Column(
          children: [
            TabBar(
              dividerColor: AppConfig.primaryLight,
              controller: _tabController,
              tabs: const [
                Tab(text: 'Entrar'),
                Tab(text: 'Registrarse'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _AuthTabContent(
                    subtitle: '¿Ya tienes cuenta? Inicia sesión.',
                    switchTabLabel: '¿No tienes cuenta? Regístrate',
                    onSwitchTab: () => _tabController.animateTo(1),
                    child: LoginForm(),
                  ),
                  _AuthTabContent(
                    subtitle:
                        'Crea tu cuenta para reportar y recibir alertas en tu barrio.',
                    switchTabLabel: '¿Ya tienes cuenta? Inicia sesión',
                    onSwitchTab: () => _tabController.animateTo(0),
                    child: RegisterForm(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeBottomBar(
        padding: const EdgeInsets.fromLTRB(
          AppConfig.horizontalMargin,
          8,
          AppConfig.horizontalMargin,
          8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrivacyBadgeWidget(
              uuid: authState.user?.uuid ?? 'Pendiente de autenticación',
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).loginAsVisitor();
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Ingresar como Visitante'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthTabContent extends StatelessWidget {
  const _AuthTabContent({
    required this.subtitle,
    required this.child,
    required this.switchTabLabel,
    required this.onSwitchTab,
  });

  final String subtitle;
  final Widget child;
  final String switchTabLabel;
  final VoidCallback onSwitchTab;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppConfig.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          child,
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: onSwitchTab,
              child: Text(switchTabLabel),
            ),
          ),
        ],
      ),
    );
  }
}
