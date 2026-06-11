// RF: Onboarding page - Introduction to users
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ms_undraw/ms_undraw.dart';
import '../../../../core/utils/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late PageController _pageController;
  int _currentPage = 0;

  static const _slides = [
    (
      illustration: UnDrawIllustration.alert,
      title: 'Reporta incidentes',
      subtitle: 'Reporta incidentes en segundos',
    ),
    (
      illustration: UnDrawIllustration.click_here,
      title: 'Botón SOS',
      subtitle: 'SOS de emergencia con un toque',
    ),
    (
      illustration: UnDrawIllustration.current_location,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [
              for (final slide in _slides)
                _buildSlide(
                  illustration: slide.illustration,
                  title: slide.title,
                  subtitle: slide.subtitle,
                ),
            ],
          ),
          Positioned(
            top: 40,
            right: 16,
            child: _currentPage < _slides.length - 1
                ? TextButton(
                    onPressed: () => context.go('/auth'),
                    child: const Text('Saltar'),
                  )
                : const SizedBox.shrink(),
          ),
          Positioned(
            bottom: 100,
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
            bottom: 30,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage == _slides.length - 1) {
                  context.go('/auth');
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
    required UnDrawIllustration illustration,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 130),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: UnDraw(
              illustration: illustration,
              color: AppConfig.primary,
              fit: BoxFit.contain,
              padding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppConfig.textSecondary,
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
