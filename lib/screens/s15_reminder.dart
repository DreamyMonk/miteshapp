import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

const _whatsapp =
    '<path d="M17.47 14.38c-.3-.15-1.74-.86-2-.96-.27-.1-.46-.15-.66.15-.19.3-.76.95-.93 1.15-.17.2-.34.22-.64.07-.3-.15-1.25-.46-2.38-1.47-.88-.78-1.47-1.75-1.64-2.05-.17-.3-.02-.46.13-.61.13-.13.3-.34.45-.51.15-.17.2-.3.3-.5.1-.2.05-.37-.02-.52-.08-.15-.66-1.6-.91-2.18-.24-.57-.48-.5-.66-.5-.17 0-.37-.02-.56-.02-.2 0-.52.07-.79.37-.27.3-1.04 1.01-1.04 2.47 0 1.46 1.06 2.87 1.21 3.07.15.2 2.1 3.2 5.08 4.49.71.31 1.26.49 1.69.63.71.23 1.36.19 1.87.12.57-.09 1.74-.71 1.99-1.4.24-.69.24-1.28.17-1.4-.07-.12-.27-.2-.56-.34zM12 2a10 10 0 0 0-8.6 15.06L2 22l5.06-1.33A10 10 0 1 0 12 2z"/>';
const _envelope = '<rect x="2" y="4" width="20" height="16" rx="2"/><path d="m22 7-10 5L2 7"/>';
const _infoCircle =
    '<circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/>';
const _bellSimple = '<path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>';

class _RemOpt {
  final String label, time, status;
  final bool finalPing;
  const _RemOpt(this.label, this.time, this.status, {this.finalPing = false});
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

// Parse a programme start from its ISO date + time string ('7:00 AM' | '19:00').
DateTime? _parseStart(String iso, String time) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(iso);
  if (m == null) return null;
  final y = int.parse(m.group(1)!), mo = int.parse(m.group(2)!), d = int.parse(m.group(3)!);
  final t = time.trim().toUpperCase();
  final ampm = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$').firstMatch(t);
  final h24 = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(t);
  if (ampm != null) {
    var hh = int.parse(ampm.group(1)!);
    final mm = int.parse(ampm.group(2)!);
    if (hh == 12) hh = 0;
    if (ampm.group(3) == 'PM') hh += 12;
    return DateTime(y, mo, d, hh, mm);
  }
  if (h24 != null) {
    return DateTime(y, mo, d, int.parse(h24.group(1)!), int.parse(h24.group(2)!));
  }
  return DateTime(y, mo, d); // date only, no parseable time
}

String _fmt12(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final ap = d.hour < 12 ? 'AM' : 'PM';
  return '$h:${d.minute.toString().padLeft(2, '0')} $ap';
}

// The 4 fixed auto-reminders, with absolute times computed off the real start.
List<_RemOpt> _buildReminders(DateTime? start) {
  const defs = [
    [120, '2 hours before', 'Active', 0],
    [60, '1 hour before', 'Active', 0],
    [30, '30 minutes before', 'Active', 0],
    [5, '5 minutes before', 'Final ping', 1],
  ];
  return defs.map((row) {
    final mins = row[0] as int;
    String label = '';
    if (start != null) {
      final t = start.subtract(Duration(minutes: mins));
      label = '${t.day} ${_months[t.month - 1]} · ${_fmt12(t)}';
    }
    return _RemOpt(row[1] as String, label, row[2] as String, finalPing: row[3] == 1);
  }).toList();
}

class S15 extends StatefulWidget {
  const S15({super.key});
  @override
  State<S15> createState() => _S15State();
}

class _S15State extends State<S15> {
  bool _push = true;
  bool _whats = false;
  bool _email = false;
  bool _loaded = false;

  String get _progId => '${AppData.I.selectedProgram?['id'] ?? ''}';

  @override
  void initState() {
    super.initState();
    final pref = AppData.I.reminderPrefFor(_progId);
    _push = pref['push'] ?? true;
    _whats = pref['whats'] ?? false;
    _email = pref['email'] ?? false;
    _loaded = true;
  }

  void _save({bool muted = false}) {
    AppData.I.setReminderPref(_progId, {
      'push': _push, 'whats': _whats, 'email': _email, 'muted': muted,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    final p = AppData.I.selectedProgram;
    final title = (p != null && '${p['title'] ?? ''}'.isNotEmpty) ? '${p['title']}' : 'Programme';
    final dateIso = p != null ? '${p['date'] ?? ''}' : '';
    final timeStr = p != null ? '${p['time'] ?? ''}' : '';
    final start = _parseStart(dateIso, timeStr);
    final subtitle = [
      title,
      if (start != null) '${start.day} ${_months[start.month - 1]}${timeStr.isNotEmpty ? ', ${_fmt12(start)}' : ''}',
    ].join(' · ');
    final reminders = _buildReminders(start);

    return Container(
      color: K.cream,
      child: Column(
        children: [
          // ── Header ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.7, -1),
                end: Alignment(0.7, 1),
                colors: [K.t9, K.t7],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Press(
                  dx: -3,
                  onTap: () => go('s12'),
                  child: Ico(P.arrowLeft, size: 18, stroke: Colors.white, sw: 2.2),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reminders',
                          style: fd(size: rem(1.05), w: FontWeight.w800, color: Colors.white)),
                      Text(subtitle,
                          style: ff(size: rem(.58), color: Colors.white.withOpacity(.55))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Body ──
          Sc(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            [
              // Auto-reminders status card
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF16A34A), Color(0xFF15803D)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Ico(P.check, size: 14, stroke: Colors.white, sw: 2.2),
                        const SizedBox(width: 7),
                        Text('Auto-Reminders Active',
                            style: ff(size: rem(.74), w: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                        'Once you subscribe to a programme, the app sends push notifications automatically at 4 fixed points before the event starts. No setup needed.',
                        style: ff(size: rem(.6), color: Colors.white.withOpacity(.9), height: 1.55)),
                  ],
                ),
              ),
              // Scheduled reminders
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('SCHEDULED REMINDERS FOR THIS PROGRAMME',
                    style: ff(size: rem(.56), w: FontWeight.w700, color: K.ink4, ls: 2)),
              ),
              Container(
                decoration: BoxDecoration(
                  color: K.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: K.bd),
                  boxShadow: K.sh,
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var i = 0; i < reminders.length; i++) _remRow(i, reminders[i], reminders.length),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Info about updates
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: K.in1,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1D4ED8).withOpacity(.18)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Ico(_infoCircle, size: 14, stroke: K.inC, sw: 1.8),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: ff(size: rem(.6), color: K.inC, height: 1.55),
                          children: [
                            TextSpan(
                                text: 'If the host updates the programme',
                                style: ff(size: rem(.6), w: FontWeight.w700, color: K.inC, height: 1.55)),
                            const TextSpan(
                                text:
                                    ' (time changes, cancellation, or new programme added), reminders adjust automatically. You\'ll also get an update notification.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Notification channels
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('NOTIFICATION CHANNELS',
                    style: ff(size: rem(.56), w: FontWeight.w700, color: K.ink4, ls: 2)),
              ),
              Container(
                decoration: BoxDecoration(
                  color: K.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: K.bd),
                  boxShadow: K.sh,
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _channelRow(
                      iconBg: K.t0,
                      iconWidget: Ico(_bellSimple, size: 14, stroke: K.t7, sw: 1.8),
                      title: 'Push notification',
                      sub: 'App alert on your phone',
                      on: _push,
                      onChanged: (v) => setState(() => _push = v),
                      border: true,
                    ),
                    _channelRow(
                      iconBg: const Color(0xFFF0FDF4),
                      iconWidget: Ico(_whatsapp, size: 14, stroke: const Color(0xFF25D366), fill: const Color(0xFF25D366), sw: 0, round: false),
                      title: 'WhatsApp message',
                      sub: 'For 30-min & 5-min reminders only',
                      on: _whats,
                      onChanged: (v) => setState(() => _whats = v),
                      border: true,
                    ),
                    _channelRow(
                      iconBg: K.g1,
                      iconWidget: Ico(_envelope, size: 14, stroke: K.g5, sw: 1.8),
                      title: 'Email digest',
                      sub: 'Daily morning summary',
                      on: _email,
                      onChanged: (v) => setState(() => _email = v),
                      border: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Btn('Save Preferences', kind: BtnKind.p, leading: P.check, onTap: () {
                _save();
                toast('Reminder settings saved');
                go('s12');
              }),
              Press(
                onTap: () {
                  setState(() => _push = false);
                  _save(muted: true);
                  toast('Reminders muted for this programme');
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Center(
                    child: Text('Mute reminders for this programme',
                        style: ff(size: rem(.66), w: FontWeight.w700, color: K.er)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ],
      ),
    );
  }

  // Reminder row — static (the prototype's s15 rows have no onclick).
  Widget _remRow(int i, _RemOpt r, int total) {
    final isLast = i == total - 1;
    final iconBg = r.finalPing ? const Color(0xFFF5A623).withOpacity(.15) : const Color(0xFF16A34A).withOpacity(.12);
    final iconStroke = r.finalPing ? K.g5 : K.ok;
    final iconInner = r.finalPing ? P.clock : P.check;

    Color badgeFg, badgeBg, badgeBd;
    if (r.finalPing) {
      badgeFg = K.g5;
      badgeBg = K.g1;
      badgeBd = K.g2;
    } else {
      badgeFg = const Color(0xFF15803D);
      badgeBg = const Color(0xFFDCFCE7);
      badgeBd = const Color(0xFFBBF7D0);
    }

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: K.white,
          border: Border(
            bottom: isLast ? BorderSide.none : BorderSide(color: K.bd),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(9)),
              child: Center(child: Ico(iconInner, size: 14, stroke: iconStroke, sw: 2.2)),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.label, style: ff(size: rem(.74), w: FontWeight.w700, color: K.ink)),
                  Text(r.time, style: mono(size: rem(.58), w: FontWeight.w400, color: K.ink3)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: badgeBd),
              ),
              child: Text(r.status,
                  style: ff(size: rem(.54), w: FontWeight.w700, color: badgeFg)),
            ),
          ],
        ),
    );
  }

  Widget _channelRow({
    required Color iconBg,
    required Widget iconWidget,
    required String title,
    required String sub,
    required bool on,
    required ValueChanged<bool> onChanged,
    required bool border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        border: border ? Border(bottom: BorderSide(color: K.bd)) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(9)),
            child: Center(child: iconWidget),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ff(size: rem(.72), w: FontWeight.w700, color: K.ink)),
                Text(sub, style: ff(size: rem(.56), color: K.ink3)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _MiniToggle(on: on, onChanged: onChanged),
        ],
      ),
    );
  }
}

// 34×20 toggle matching the prototype's inline tg-on switch.
class _MiniToggle extends StatelessWidget {
  final bool on;
  final ValueChanged<bool> onChanged;
  const _MiniToggle({required this.on, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!on),
      child: Container(
        width: 34,
        height: 20,
        decoration: BoxDecoration(
          color: on ? K.t6 : K.bd2,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 180),
              top: 2,
              left: on ? 16 : 2,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
