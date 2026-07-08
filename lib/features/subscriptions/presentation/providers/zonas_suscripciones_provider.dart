import 'package:centinela_milagro/features/auth/domain/entities/zona_entity.dart';
import 'package:centinela_milagro/features/map/domain/entities/user_zona_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/constants/zona_suscripcion_limits.dart';
import '../../domain/repository/suscripciones_repository.dart';
import 'suscripciones_repository_provider.dart';

class ZonasSuscripcionesState {
  const ZonasSuscripcionesState({
    this.catalog = const [],
    this.myZonas = const [],
    this.isLoading = false,
    this.isMutating = false,
    this.errorMessage,
  });

  final List<ZonaEntity> catalog;
  final List<UserZonaEntity> myZonas;
  final bool isLoading;
  final bool isMutating;
  final String? errorMessage;

  factory ZonasSuscripcionesState.initial() => const ZonasSuscripcionesState(
    isLoading: true,
  );

  ZonasSuscripcionesState copyWith({
    List<ZonaEntity>? catalog,
    List<UserZonaEntity>? myZonas,
    bool? isLoading,
    bool? isMutating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ZonasSuscripcionesState(
      catalog: catalog ?? this.catalog,
      myZonas: myZonas ?? this.myZonas,
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  UserZonaEntity? get principalZona {
    for (final zona in myZonas) {
      if (zona.isPrincipal) return zona;
    }
    return myZonas.isNotEmpty ? myZonas.first : null;
  }

  List<UserZonaEntity> get subscribedZonas =>
      myZonas.where((zona) => !zona.isPrincipal).toList();

  int get subscribedCount => subscribedZonas.length;

  bool get canSubscribeMore => subscribedCount < kMaxZonasSuscritas;

  Set<String> get subscribedIds => myZonas.map((zona) => zona.zonaId).toSet();

  List<ZonaEntity> get availableZonas =>
      catalog.where((zona) => !subscribedIds.contains(zona.id)).toList();
}

class ZonasSuscripcionesNotifier extends Notifier<ZonasSuscripcionesState> {
  @override
  ZonasSuscripcionesState build() {
    Future.microtask(load);
    return ZonasSuscripcionesState.initial();
  }

  SuscripcionesRepository get _repository =>
      ref.read(suscripcionesRepositoryProvider);

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _repository.getAllZonas(),
        _repository.getMyZonas(),
      ]);
      state = state.copyWith(
        catalog: results[0] as List<ZonaEntity>,
        myZonas: results[1] as List<UserZonaEntity>,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<bool> subscribe(String zonaId) async {
    if (!state.canSubscribeMore) return false;
    state = state.copyWith(isMutating: true, clearError: true);
    try {
      final ok = await _repository.subscribeToZona(zonaId);
      if (ok) await load();
      state = state.copyWith(isMutating: false);
      return ok;
    } catch (error) {
      state = state.copyWith(
        isMutating: false,
        errorMessage: error.toString(),
      );
      return false;
    }
  }

  Future<bool> unsubscribe(String zonaId) async {
    state = state.copyWith(isMutating: true, clearError: true);
    try {
      final ok = await _repository.unsubscribeFromZona(zonaId);
      if (ok) await load();
      state = state.copyWith(isMutating: false);
      return ok;
    } catch (error) {
      state = state.copyWith(
        isMutating: false,
        errorMessage: error.toString(),
      );
      return false;
    }
  }

  Future<bool> setPrincipal(String zonaId) async {
    state = state.copyWith(isMutating: true, clearError: true);
    try {
      final ok = await _repository.setPrincipalZona(zonaId);
      if (ok) await load();
      state = state.copyWith(isMutating: false);
      return ok;
    } catch (error) {
      state = state.copyWith(
        isMutating: false,
        errorMessage: error.toString(),
      );
      return false;
    }
  }
}

final zonasSuscripcionesProvider =
    NotifierProvider<ZonasSuscripcionesNotifier, ZonasSuscripcionesState>(
      ZonasSuscripcionesNotifier.new,
    );

final misZonasProvider = Provider<List<UserZonaEntity>>((ref) {
  return ref.watch(zonasSuscripcionesProvider).myZonas;
});

final zonasDisponiblesProvider = Provider<List<ZonaEntity>>((ref) {
  return ref.watch(zonasSuscripcionesProvider).availableZonas;
});

final puedeSuscribirMasZonasProvider = Provider<bool>((ref) {
  return ref.watch(zonasSuscripcionesProvider).canSubscribeMore;
});

final zonasSuscritasCountProvider = Provider<int>((ref) {
  return ref.watch(zonasSuscripcionesProvider).subscribedCount;
});

final subscriptionCatalogZonesProvider = Provider<List<ZonaEntity>>((ref) {
  final state = ref.watch(zonasSuscripcionesProvider);
  final principalId = state.principalZona?.zonaId;
  final zones = state.catalog.where((z) => z.id != principalId).toList();
  zones.sort((a, b) {
    final aSub = state.subscribedIds.contains(a.id);
    final bSub = state.subscribedIds.contains(b.id);
    if (aSub != bSub) return aSub ? -1 : 1;
    return a.nombre.compareTo(b.nombre);
  });
  return zones;
});
