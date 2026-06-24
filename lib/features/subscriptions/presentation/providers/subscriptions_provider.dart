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

final userZonaProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).user?.zona;
});

final monitoredBarriosProvider = Provider<List<String>>((ref) {
  final subscribed = ref.watch(barriosSubscribedProvider);
  final own = ref.watch(authProvider).user?.barrio;
  if (own == null || own.isEmpty) return List.unmodifiable(subscribed);
  return List.unmodifiable([own, ...subscribed]);
});

final userEsNivelZonaProvider = Provider<bool>((ref) {
  final user = ref.watch(authProvider).user;
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
      final subscribed = ref.watch(barriosSubscribedProvider);
      final home = ref.watch(authProvider).user?.barrio;
      return (barrio) => categorizeBarrio(
        barrio,
        homeBarrio: home?.isNotEmpty == true ? home : null,
        subscribed: subscribed,
      );
    });

final availableBarriosToSubscribeProvider = Provider<List<String>>((ref) {
  final subscribed = ref.watch(barriosSubscribedProvider);
  final own = ref.watch(authProvider).user?.barrio ?? '';
  final zona = ref.watch(authProvider).user?.zona ?? '';
  if (!zonaTieneBarrios(zona)) return const [];
  return barriosDeZona(zona).where((b) => b != own && !subscribed.contains(b)).toList();
});

final selectableBarriosEnZonaProvider = Provider<List<String>>((ref) {
  final homeBarrio = ref.watch(authProvider).user?.barrio ?? '';
  final zona = ref.watch(authProvider).user?.zona ?? '';
  if (!zonaTieneBarrios(zona)) return const [];
  return barriosDeZona(zona).where((b) => b != homeBarrio).toList();
});
