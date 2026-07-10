import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight on-device auth/session store, persisted with SharedPreferences.
class Session extends ChangeNotifier {
  Session._();
  static final Session I = Session._();

  String fullName = '';
  String familyName = '';
  String mobile = '';
  String city = '';
  bool loggedIn = false;

  // Last scanned QR value (for the attendance-recorded screen).
  String lastScan = '';

  static const _kLogged = 'ik_logged';
  static const _kName = 'ik_name';
  static const _kFamily = 'ik_family';
  static const _kMobile = 'ik_mobile';
  static const _kCity = 'ik_city';

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      loggedIn = p.getBool(_kLogged) ?? false;
      fullName = p.getString(_kName) ?? '';
      familyName = p.getString(_kFamily) ?? '';
      mobile = p.getString(_kMobile) ?? '';
      city = p.getString(_kCity) ?? '';
    } catch (_) {/* first run / web fallback */}
  }

  Future<void> signIn({
    required String name,
    required String family,
    required String mobile,
    required String city,
  }) async {
    fullName = name.trim();
    familyName = family.trim();
    this.mobile = mobile.trim();
    this.city = city.trim();
    loggedIn = true;
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kLogged, true);
      await p.setString(_kName, fullName);
      await p.setString(_kFamily, familyName);
      await p.setString(_kMobile, this.mobile);
      await p.setString(_kCity, this.city);
    } catch (_) {}
  }

  Future<void> signOut() async {
    loggedIn = false;
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kLogged, false);
    } catch (_) {}
  }

  String get displayName => fullName.trim().isEmpty ? 'Guest' : fullName.trim();

  String get initials {
    final parts = '$fullName $familyName'
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'IK';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
