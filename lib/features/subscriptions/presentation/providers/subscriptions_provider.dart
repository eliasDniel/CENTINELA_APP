// RF-0309: Estado de suscripciones a barrios
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/barrio_membership.dart';
import '../../domain/constants/milagro_barrios.dart';

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

/// Barrio de registro + hasta 3 suscritos.
final monitoredBarriosProvider = Provider<List<String>>((ref) {
  final auth = ref.watch(authProvider);
  final subscribed = ref.watch(barriosSubscribedProvider);
  final own = auth.user?.barrio;
  if (own == null || own.isEmpty) return List.unmodifiable(subscribed);
  return List.unmodifiable([own, ...subscribed]);
});

final subscriptionSlotsUsedProvider = Provider<int>((ref) {
  return ref.watch(barriosSubscribedProvider).length;
});

final canSubscribeMoreProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionSlotsUsedProvider) < kMaxBarriosAdicionales;
});

/// Clasifica un barrio para pintar marcadores y chips en el mapa.
final barrioCategoryFnProvider = Provider<BarrioMapCategory Function(String)>((ref) {
  final auth = ref.watch(authProvider);
  final subscribed = ref.watch(barriosSubscribedProvider);
  final home = auth.user?.barrio;
  return (barrio) => categorizeBarrio(
        barrio,
        homeBarrio: home,
        subscribed: subscribed,
      );
});

final availableBarriosToSubscribeProvider = Provider<List<String>>((ref) {
  final auth = ref.watch(authProvider);
  final subscribed = ref.watch(barriosSubscribedProvider);
  final own = auth.user?.barrio ?? '';
  return kMilagroBarrios
      .where((b) => b != own && !subscribed.contains(b))
      .toList();
});
