// RF-0309: Estado de suscripciones a barrios
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/barrio_membership.dart';
import '../../domain/constants/zonas_administrativas.dart';

class BarriosSubscribedNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void setBarrios(List<String> barrios) {
    state = List.unmodifiable(barrios.take(kMaxBarriosAdicionales));
  }

  bool subscribe(String barrio, String userBarrio) {
    if (barrio == userBarrio || state.contains(barrio)) return false;
    if (state.length >= kMaxBarriosAdicionales) return false;
    state = [...state, barrio];
    return true;
  }

  void unsubscribe(String barrio) {
    state = state.where((b) => b != barrio).toList();
  }

  void toggleBarrio(String barrio, String userBarrio) {
    if (state.contains(barrio)) {
      unsubscribe(barrio);
    } else {
      subscribe(barrio, userBarrio);
    }
  }
}

final barriosSubscribedProvider =
    NotifierProvider<BarriosSubscribedNotifier, List<String>>(
  BarriosSubscribedNotifier.new,
);

/// Zona del usuario registrado.
final userZonaProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).user?.zona;
});

/// Barrio de registro + hasta 3 suscritos (solo si el usuario tiene barrio).
final monitoredBarriosProvider = Provider<List<String>>((ref) {
  final auth = ref.watch(authProvider);
  final subscribed = ref.watch(barriosSubscribedProvider);
  final own = auth.user?.barrio;
  if (own == null || own.isEmpty) return List.unmodifiable(subscribed);
  return List.unmodifiable([own, ...subscribed]);
});

/// Indica si el usuario opera a nivel de zona (sin barrio específico).
final userEsNivelZonaProvider = Provider<bool>((ref) {
  final auth = ref.watch(authProvider);
  final user = auth.user;
  if (user == null) return false;
  return !user.tieneBarrio;
});

final subscriptionSlotsUsedProvider = Provider<int>((ref) {
  return ref.watch(barriosSubscribedProvider).length;
});

final canSubscribeMoreProvider = Provider<bool>((ref) {
  if (!zonaTieneBarrios(ref.watch(userZonaProvider) ?? '')) return false;
  return ref.watch(subscriptionSlotsUsedProvider) < kMaxBarriosAdicionales;
});

final barrioCategoryFnProvider =
    Provider<BarrioMapCategory Function(String)>((ref) {
  final auth = ref.watch(authProvider);
  final subscribed = ref.watch(barriosSubscribedProvider);
  final home = auth.user?.barrio;
  return (barrio) => categorizeBarrio(
        barrio,
        homeBarrio: home?.isNotEmpty == true ? home : null,
        subscribed: subscribed,
      );
});

/// Barrios de la zona del usuario disponibles para suscribirse.
final availableBarriosToSubscribeProvider = Provider<List<String>>((ref) {
  final auth = ref.watch(authProvider);
  final subscribed = ref.watch(barriosSubscribedProvider);
  final own = auth.user?.barrio ?? '';
  final zona = auth.user?.zona ?? '';
  if (!zonaTieneBarrios(zona)) return const [];
  return barriosDeZona(zona)
      .where((b) => b != own && !subscribed.contains(b))
      .toList();
});

/// Barrios seleccionables en la pantalla de gestión (misma zona, excluye propio).
final selectableBarriosEnZonaProvider = Provider<List<String>>((ref) {
  final auth = ref.watch(authProvider);
  final homeBarrio = auth.user?.barrio ?? '';
  final zona = auth.user?.zona ?? '';
  if (!zonaTieneBarrios(zona)) return const [];
  return barriosDeZona(zona).where((b) => b != homeBarrio).toList();
});
