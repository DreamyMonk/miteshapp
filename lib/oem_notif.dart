import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'widgets/svg.dart';

/// Helps notifications survive aggressive-OEM battery managers: requests the
/// "ignore battery optimizations" exemption and deep-links to the OEM autostart
/// manager. Since Invite Karoo's whole value is "get notified → attend the
/// event", we ask once, up front, on the phones that need it.
class OemNotif {
  static const _ch = MethodChannel('ik/oem');
  static const _kCount = 'ik_notif_reliability_count';
  static const _maxPrompts = 3;
  static bool _shownThisSession = false;

  // Manufacturers whose battery managers routinely kill background delivery.
  static const _aggressive = {
    'xiaomi', 'redmi', 'poco', 'oppo', 'vivo', 'iqoo', 'realme',
    'oneplus', 'huawei', 'honor', 'letv', 'meizu', 'samsung', 'tecno', 'infinix'
  };

  static Future<String> manufacturer() async {
    try {
      return (await _ch.invokeMethod<String>('manufacturer')) ?? '';
    } catch (_) {
      return '';
    }
  }

  static Future<bool> isAggressiveOem() async {
    final m = (await manufacturer()).toLowerCase();
    return _aggressive.any((b) => m.contains(b));
  }

  static Future<bool> isIgnoringBattery() async {
    try {
      return (await _ch.invokeMethod<bool>('isIgnoringBattery')) ?? true;
    } catch (_) {
      return true;
    }
  }

  static Future<void> requestIgnoreBattery() async {
    try {
      await _ch.invokeMethod('requestIgnoreBattery');
    } catch (_) {}
  }

  static Future<void> openAutoStart() async {
    try {
      await _ch.invokeMethod('openAutoStart');
    } catch (_) {}
  }

  /// Show the reliability sheet at most once per app launch, on aggressive OEMs
  /// that aren't already battery-exempt, capped at a few launches total. Once
  /// the user grants the exemption it never shows again. Safe to call on every
  /// home load.
  static Future<void> maybePrompt(BuildContext context) async {
    if (_shownThisSession) return;
    if (await isIgnoringBattery()) return; // already exempt → nothing to nag
    if (!await isAggressiveOem()) return;
    int count = 0;
    try {
      final p = await SharedPreferences.getInstance();
      count = p.getInt(_kCount) ?? 0;
      if (count >= _maxPrompts) return;
      await p.setInt(_kCount, count + 1);
    } catch (_) {}
    _shownThisSession = true;
    if (!context.mounted) return;
    showNotifReliabilitySheet(context);
  }
}

/// Bottom sheet explaining + triggering the battery-optimization exemption and
/// autostart. Reusable from Settings too.
void showNotifReliabilitySheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => const _ReliabilitySheet(),
  );
}

const _bell =
    '<path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/>';
const _bolt = '<polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>';
const _rocket =
    '<path d="M4.5 16.5c-1.5 1.26-2 5-2 5s3.74-.5 5-2c.71-.84.7-2.13-.09-2.91a2.18 2.18 0 0 0-2.91-.09z"/><path d="M12 15l-3-3a22 22 0 0 1 2-3.95A12.88 12.88 0 0 1 22 2c0 2.72-.78 7.5-6 11a22.35 22.35 0 0 1-4 2z"/>';
const _check = '<polyline points="20 6 9 17 4 12"/>';

class _ReliabilitySheet extends StatelessWidget {
  const _ReliabilitySheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: K.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: K.bd2, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [K.t7, K.t5]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Ico(_bell, size: 20, stroke: Colors.white, sw: 1.8)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Never miss an event',
                  style: fd(size: rem(1.15), w: FontWeight.w800, color: K.ink)),
            ),
          ]),
          const SizedBox(height: 10),
          Text(
            "Your phone's battery saver can silence reminders when the app is closed. Two quick taps keep them coming through on time.",
            style: ff(size: rem(.78), color: K.ink3, height: 1.55),
          ),
          const SizedBox(height: 16),
          _Step(
            icon: _bolt,
            title: 'Allow background delivery',
            sub: "Turn off battery optimization for Invite Karoo.",
            onTap: () => OemNotif.requestIgnoreBattery(),
          ),
          const SizedBox(height: 10),
          _Step(
            icon: _rocket,
            title: 'Enable Autostart',
            sub: "Let the app receive alerts after a restart. Find “Invite Karoo” and turn it on.",
            onTap: () => OemNotif.openAutoStart(),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: TextButton.styleFrom(
                backgroundColor: K.t7,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Ico(_check, size: 16, stroke: Colors.white, sw: 2.4),
                  const SizedBox(width: 7),
                  Text('Done', style: ff(size: rem(.82), w: FontWeight.w800, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String icon, title, sub;
  final VoidCallback onTap;
  const _Step({required this.icon, required this.title, required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: K.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: K.bd),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: K.t1, borderRadius: BorderRadius.circular(10)),
              child: Center(child: Ico(icon, size: 17, stroke: K.t7, sw: 1.8)),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: ff(size: rem(.8), w: FontWeight.w700, color: K.ink)),
                  const SizedBox(height: 2),
                  Text(sub, style: ff(size: rem(.64), color: K.ink3, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Ico('<polyline points="9 18 15 12 9 6"/>', size: 15, stroke: K.ink4, sw: 2),
          ],
        ),
      ),
    );
  }
}
