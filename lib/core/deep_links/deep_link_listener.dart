import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:centinela_milagro/core/deep_links/deep_link_handler.dart';
import 'package:centinela_milagro/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Escucha enlaces `centinela://reset-password?token=...` y navega en GoRouter.
class DeepLinkListener extends ConsumerStatefulWidget {
  const DeepLinkListener({
    super.key,
    required this.appRouter,
    required this.child,
  });

  final GoRouter appRouter;
  final Widget child;

  @override
  ConsumerState<DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends ConsumerState<DeepLinkListener> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (_) {
      // Enlace inicial no disponible o plataforma sin soporte.
    }

    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (_) {},
    );
  }

  void _handleUri(Uri uri) {
    DeepLinkHandler.remember(uri);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tryNavigate(uri);
    });
  }

  void _tryNavigate(Uri uri) {
    final authStatus = ref.read(authProvider).authStatus;
    if (authStatus == AuthStatus.checking) {
      DeepLinkHandler.remember(uri);
      return;
    }
    DeepLinkHandler.navigate(widget.appRouter, uri);
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (previous?.authStatus == AuthStatus.checking &&
          next.authStatus != AuthStatus.checking) {
        DeepLinkHandler.flushPending(widget.appRouter);
      }
    });

    return widget.child;
  }
}
