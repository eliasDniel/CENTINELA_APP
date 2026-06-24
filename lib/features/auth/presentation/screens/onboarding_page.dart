// RF: Onboarding page - Introduction to users
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/view_insets.dart';
import '../../../../core/utils/app_colors.dart';
import '../providers/onboarding_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late PageController _pageController;
  int _currentPage = 0;

  static const _slides = [
    (
      icon: Icons.warning_amber_outlined,
      title: 'Reporta incidentes',
      subtitle: 'Reporta incidentes en segundos',
    ),
    (
      icon: Icons.crisis_alert_outlined,
      title: 'Botón SOS',
      subtitle: 'SOS de emergencia con un toque',
    ),
    (
      icon: Icons.location_on_outlined,
      title: 'Mapa de alertas',
      subtitle: 'Mantente informado en tu barrio',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    await ref.read(onboardingCompletedProvider.notifier).complete();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = bottomViewInset(context);
    final topSafe = topViewInset(context);

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [
              for (final slide in _slides)
                _buildSlide(
                  icon: slide.icon,
                  title: slide.title,
                  subtitle: slide.subtitle,
                ),
            ],
          ),
          Positioned(
            top: topSafe + 8,
            right: 16,
            child: _currentPage < _slides.length - 1
                ? TextButton(
                    onPressed: _finishOnboarding,
                    child: const Text('Saltar'),
                  )
                : const SizedBox.shrink(),
          ),
          Positioned(
            bottom: 100 + bottomSafe,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => Container(
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentPage == index
                        ? AppConfig.primary
                        : AppConfig.textTertiary,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24 + bottomSafe,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage == _slides.length - 1) {
                  _finishOnboarding();
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                _currentPage == _slides.length - 1 ? 'Comenzar' : 'Siguiente',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 130),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Icon(
              icon,
              size: 160,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppConfig.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
