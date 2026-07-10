import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

const _bell = '<path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>';
const _satsang =
    '<path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83"/>';
const _music = '<path d="M9 18V5l12-2v13"/><circle cx="6" cy="18" r="3"/><circle cx="18" cy="16" r="3"/>';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

DateTime? _d(String iso) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(iso);
  if (m == null) return null;
  return DateTime(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
}

// 'YYYY-MM-DD' → 'D Mon' (e.g. '28 May').
String _dm(DateTime? d) => d == null ? '' : '${d.day} ${_months[d.month - 1]}';

// 'YYYY-MM-DD' → 'Mon YYYY' (e.g. 'Aug 2026').
String _my(DateTime? d) => d == null ? '' : '${_months[d.month - 1]} ${d.year}';

// Rotating icon looks (visual variety, matches the prototype's per-card styles:
// gold flower, green sun, purple music note).
const _icons = [P.flower, _satsang, _music];
const _iconGrads = <Gradient>[
  K.gGold,
  LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF16A34A), Color(0xFF15803D)]),
  LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF5B3E9E), Color(0xFF3D2582)]),
];

class S21 extends StatefulWidget {
  const S21({super.key});
  @override
  State<S21> createState() => _S21State();
}

class _S21State extends State<S21> {
  // Per-community notification toggle state (local UI state, keyed by name).
  final Map<String, List<bool>> _toggles = {};

  List<bool> _rowsFor(String name) => _toggles.putIfAbsent(name, () => [true, true, true]);

  void _onData() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    AppData.I.addListener(_onData);
  }

  @override
  void dispose() {
    AppData.I.removeListener(_onData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Live communities the user is subscribed to.
    final subs = AppData.I.liveCommunities
        .where((c) => AppData.I.isSubscribed('${c['name'] ?? ''}'))
        .toList();

    return Container(
      color: K.cream,
      child: Column(
        children: [
          AppBarX(
            title: 'Manage Subscriptions',
            sub: 'Notifications per community',
            back: 's23',
            onBack: () => go('s23'),
          ),
          Sc(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            [
              const Sec('Active Subscriptions', padding: EdgeInsets.only(bottom: 8)),
              if (subs.isEmpty)
                _emptyState()
              else
                for (var i = 0; i < subs.length; i++) _subCard(subs[i], i),
              const SizedBox(height: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 40),
      child: Column(
        children: [
          Ico(_bell, size: 36, stroke: K.ink4, sw: 1.5),
          const SizedBox(height: 10),
          Text('No subscriptions yet', style: ff(size: rem(.82), w: FontWeight.w700, color: K.ink2)),
          const SizedBox(height: 4),
          Text('Subscribe to a community to manage its notifications here.',
              textAlign: TextAlign.center,
              style: ff(size: rem(.66), color: K.ink4, height: 1.5)),
        ],
      ),
    );
  }

  Widget _subCard(Map<String, dynamic> c, int i) {
    final name = '${c['name'] ?? ''}';
    final status = '${c['editionStatus'] ?? ''}';
    final active = status.isEmpty || status.toLowerCase() == 'active';
    final end = _d('${c['editionEnd'] ?? ''}');
    final next = _my(_d('${c['nextEditionDate'] ?? ''}'));

    // Subtitle mirrors the prototype copy:
    //  active   → "Currently active · till 28 May"
    //  dormant  → "Between editions · next: Aug 2026"
    final meta = active
        ? ['Currently active', if (end != null) 'till ${_dm(end)}'].join(' · ')
        : ['Between editions', if (next.isNotEmpty) 'next: $next'].join(' · ');

    final rows = _rowsFor(name);

    return CardX(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GBox(
                size: 38,
                radius: 11,
                gradient: _iconGrads[i % _iconGrads.length],
                child: Ico(_icons[i % _icons.length], size: 18, stroke: Colors.white, sw: 1.8),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(name, style: ff(size: rem(.82), w: FontWeight.w700, color: K.ink)),
                    Text(meta, style: ff(size: rem(.56), color: K.ink3)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          if (active) ...[
            // Active edition: full notification controls + unsubscribe.
            _toggleRow('Push notifications', rows[0], (v) => setState(() => rows[0] = v)),
            _toggleRow('New edition alert', rows[1], (v) => setState(() => rows[1] = v)),
            _toggleRow('Auto-add to calendar', rows[2], (v) => setState(() => rows[2] = v)),
            const SizedBox(height: 7),
            Press(
              scale: .98,
              onTap: () {
                AppData.I.setSubscribed(name, false);
                toast('Unsubscribed from $name');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Text('Unsubscribe from this community',
                    textAlign: TextAlign.center,
                    style: ff(size: rem(.62), w: FontWeight.w700, color: K.er)),
              ),
            ),
          ] else
            // Between editions: single "notify when next edition starts" row.
            _toggleRow('Notify when next edition starts', rows[0], (v) => setState(() => rows[0] = v)),
        ],
      ),
    );
  }

  Widget _toggleRow(String label, bool on, ValueChanged<bool> onChanged) {
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: K.bd))),
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(child: Text(label, style: ff(size: rem(.66), color: K.ink))),
          _SmallToggle(on: on, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// 32×18 toggle matching the inline `.tg-on` markup in S21.
class _SmallToggle extends StatelessWidget {
  final bool on;
  final ValueChanged<bool> onChanged;
  const _SmallToggle({required this.on, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!on),
      child: Container(
        width: 32,
        height: 18,
        decoration: BoxDecoration(
          color: on ? K.t6 : K.cream2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: 2,
            left: on ? 16 : 2,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
          ),
        ]),
      ),
    );
  }
}
