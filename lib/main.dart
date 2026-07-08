import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/deep_links/deep_link_listener.dart';
import 'core/map/map_tile_cache.dart';
import 'core/realtime/map_realtime_service.dart';
import 'core/permissions/post_auth_permissions.dart';
import 'core/notifications/notification_preferences.dart';
import 'core/utils/app_theme.dart';
import 'core/utils/app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/notifications/blocs/notifications/notifications_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es5');
  await dotenv.load(fileName: ".env");
  await NotificationPreferences.load();
  await initializeMapTileCache();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationsBloc.initializeFCM();
  runApp(ProviderScope(
      child: MultiBlocProvider(
        providers: [BlocProvider(create: (_) => NotificationsBloc())],
        child: const MainApp(),
      ),
    ),);
}

final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(appRouterProvider);
    return MaterialApp.router(
      scaffoldMessengerKey: messengerKey,
      routerConfig: appRouter,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => PostAuthPermissionsListener(
        child: DeepLinkListener(
          appRouter: appRouter,
          child: FcmAuthSync(
            child: MapRealtimeSync(
              child: HandleNotificationInteraction(
                appRouter: appRouter,
                child: child!,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HandleNotificationInteraction extends StatefulWidget {
  final Widget child;
  final GoRouter appRouter;
  const HandleNotificationInteraction({
    super.key,
    required this.child,
    required this.appRouter,
  });

  @override
  State<HandleNotificationInteraction> createState() =>
      _HandleNotificationInteractionState();
}

class _HandleNotificationInteractionState
    extends State<HandleNotificationInteraction> {
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (!NotificationPreferences.enabled) return;
    context.read<NotificationsBloc>().handleRemoteMessage(message);
    widget.appRouter.go('/home/0/notifications');
  }

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class FcmAuthSync extends ConsumerStatefulWidget {
  const FcmAuthSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<FcmAuthSync> createState() => _FcmAuthSyncState();
}

class _FcmAuthSyncState extends ConsumerState<FcmAuthSync>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (!NotificationPreferences.enabled) return;

    final auth = ref.read(authProvider);
    if (auth.authStatus != AuthStatus.authenticated) return;

    ref.read(authProvider.notifier).resolveAccessToken().then((token) {
      if (!mounted || token == null || token.isEmpty) return;
      context.read<NotificationsBloc>().add(NotificationsLoadHistory(token));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationsBloc, NotificationsState>(
      listenWhen: (previous, current) =>
          previous.token != current.token && current.token != null,
      listener: (context, state) {
        if (!NotificationPreferences.enabled) return;
        final auth = ref.read(authProvider);
        if (auth.authStatus == AuthStatus.authenticated) {
          ref.read(authProvider.notifier).syncFcmWithBackend();
        }
      },
      child: widget.child,
    );
  }
}
