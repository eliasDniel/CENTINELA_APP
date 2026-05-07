// RF-0309: Profile provider
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BarriosSubscribedNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void setBarrios(List<String> barrios) {
    state = barrios;
  }

  void toggleBarrio(String barrio, String userBarrio) {
    if (state.contains(barrio)) {
      state = state.where((b) => b != barrio).toList();
    } else {
      if (state.length < 3 && barrio != userBarrio) {
        state = [...state, barrio];
      }
    }
  }
}

final barriosSubscribedProvider =
    NotifierProvider<BarriosSubscribedNotifier, List<String>>(() {
  return BarriosSubscribedNotifier();
});
