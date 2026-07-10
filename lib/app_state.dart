import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Global navigation + toast controller — mirrors the prototype's `G()` / `T()`.
/// Screens are switched by id (e.g. 's03'); there is no back-stack — back
/// buttons navigate explicitly, exactly like the original.
class AppController extends ChangeNotifier {
  AppController._();
  static final AppController I = AppController._();

  String current = 's01';
  // Direction for the page transition (+1 forward feel). Always slide-in-right
  // like the prototype's pgIn keyframe.
  int _seq = 0;
  int get seq => _seq;

  // Back-history stack so the Android back button / swipe navigates within the
  // app instead of closing it. Root screens (splash/login/home) reset it.
  final List<String> _history = [];
  static const _roots = {'s01', 's02', 's03'};
  bool get canGoBack => _history.isNotEmpty;
  DateTime? _lastBackPress;

  void go(String id) {
    if (id == current) return;
    if (_roots.contains(id)) {
      _history.clear(); // home/auth are the base of the stack
    } else if (_history.isNotEmpty && _history.last == id) {
      _history.removeLast(); // navigating back to the previous screen
    } else {
      _history.add(current);
    }
    current = id;
    _seq++;
    notifyListeners();
  }

  /// Pop one screen. Returns true if it navigated, false if there's nothing to
  /// go back to.
  bool back() {
    if (_history.isEmpty) return false;
    current = _history.removeLast();
    _seq++;
    notifyListeners();
    return true;
  }

  /// Handle a system back press. Returns true if the app should EXIT (nothing
  /// left to pop and the user pressed back twice within 2s), false if handled.
  bool onSystemBack() {
    if (back()) return false;
    final now = DateTime.now();
    if (_lastBackPress != null && now.difference(_lastBackPress!) < const Duration(seconds: 2)) {
      return true; // exit the app
    }
    _lastBackPress = now;
    showToast('Press back again to exit');
    return false;
  }

  // Toast
  final ValueNotifier<String?> toast = ValueNotifier<String?>(null);
  void showToast(String msg) {
    toast.value = msg;
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (toast.value == msg) toast.value = null;
    });
  }
}

void go(String id) => AppController.I.go(id);
void toast(String msg) => AppController.I.showToast(msg);

/// Open Google Maps for an address (matches the prototype's gmaps()).
Future<void> gmaps(String venue, String address) async {
  final q = Uri.encodeComponent('$venue, $address');
  final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');
  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) toast('Opening Maps: $venue');
  } catch (_) {
    toast('Opening Maps: $venue');
  }
}
