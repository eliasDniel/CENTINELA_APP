// RF-0301, RF-0302: Auth page with login and register tabs
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';
import '../widgets/privacy_badge_widget.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> with TickerProviderStateMixin {
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
    final authNotifier = ref.read(authProvider.notifier);

    ref.listen(authProvider, (previous, next) {
      if (next.user != null && previous?.user == null) {
        context.go('/home');
      }
      if (next.error != null && next.error!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('BarrioSeguro'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Entrar'),
                        Tab(text: 'Registrarse'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 400,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Login tab
                          LoginForm(
                            onSubmit: () {},
                            onLogin: (alias, password) {
                              authNotifier.login(alias, password);
                            },
                            isLoading: authState.isLoading,
                          ),
                          // Register tab
                          RegisterForm(
                            onSubmit: () {},
                            onRegister: (alias, password, barrio, phone) async {
                              await authNotifier.register(
                                alias,
                                password,
                                barrio,
                                phone: phone,
                              );
                              // Show UUID dialog
                              if (mounted && authState.user != null) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Pseudónimo privado'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Tu pseudónimo único protege tu identidad:',
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppConfig.surface,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: AppConfig.primary),
                                          ),
                                          child: SelectableText(
                                            authState.user!.uuid,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Continuar'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            isLoading: authState.isLoading,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrivacyBadgeWidget(
                uuid: authState.user?.uuid ?? 'Pendiente de autenticación',
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () {
                  authNotifier.loginAsVisitor();
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Ingresar como Visitante'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
