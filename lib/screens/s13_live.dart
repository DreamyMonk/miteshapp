import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

const _mon = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

DateTime? _d(String iso) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(iso);
  if (m == null) return null;
  return DateTime(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
}

String _dmy(DateTime? d) => d == null ? '' : '${d.day} ${_mon[d.month - 1]} ${d.year}';

class S13 extends StatefulWidget {
  const S13({super.key});
  @override
  State<S13> createState() => _S13State();
}

class _S13State extends State<S13> {
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

  // Programmes currently live (status == live).
  List<Map<String, dynamic>> get _liveNow => AppData.I.livePrograms
      .where((p) => '${p['status'] ?? ''}'.toLowerCase() == 'live')
      .toList();

  // Scheduled programmes still to come today.
  List<Map<String, dynamic>> get _comingUp {
    final today = AppData.todayIso;
    return AppData.I.livePrograms.where((p) {
      final s = '${p['status'] ?? ''}'.toLowerCase();
      return '${p['date'] ?? ''}' == today && (s == 'scheduled' || s == '' || s == 'upcoming');
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final liveNow = _liveNow;
    final comingUp = _comingUp;
    final Map<String, dynamic>? lead = liveNow.isNotEmpty ? liveNow.first : null;

    final venue = lead == null ? '' : '${lead['venue'] ?? ''}';
    final time = lead == null ? '' : '${lead['time'] ?? ''}';
    final headerSub = [
      if (venue.isNotEmpty) venue,
      if (time.isNotEmpty) time,
    ].join(' · ');

    return Container(
      color: K.cream,
      child: Column(
        children: [
          // ── Header ──
          Container(
            decoration: const BoxDecoration(gradient: K.gHeader),
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Press(
                  dx: -3,
                  onTap: () => go('s34'),
                  child: Ico(P.arrowLeft, size: 18, stroke: Colors.white.withOpacity(.85), sw: 2.2),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _PulseDot(active: lead != null),
                    const SizedBox(width: 6),
                    Text('LIVE NOW',
                        style: ff(
                            size: rem(.6),
                            w: FontWeight.w700,
                            color: Colors.white.withOpacity(.6),
                            ls: 1)),
                  ],
                ),
                Text('Happening Now',
                    style: fd(size: rem(1.25), w: FontWeight.w800, color: Colors.white)),
                if (headerSub.isNotEmpty)
                  Text(headerSub, style: ff(size: rem(.64), color: Colors.white.withOpacity(.5))),
              ],
            ),
          ),
          // ── Body ──
          Sc(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            (liveNow.isEmpty && comingUp.isEmpty)
                ? [_emptyCard()]
                : _content(liveNow, comingUp, lead),
          ),
        ],
      ),
    );
  }

  List<Widget> _content(
      List<Map<String, dynamic>> liveNow, List<Map<String, dynamic>> comingUp, Map<String, dynamic>? lead) {
    final out = <Widget>[];

    // Day-of-festival context card (derived from the live programme's community edition).
    final ctx = _festivalCard(lead);
    if (ctx != null) out.add(ctx);

    if (liveNow.isNotEmpty) {
      out.add(_sec('Running Now', const EdgeInsets.only(bottom: 8)));
      for (final p in liveNow) {
        out.add(_progCard(p, edge: K.ok, chip: Chip2('● Live', kind: ChipKind.g, fontSize: rem(.52))));
      }
    }

    if (comingUp.isNotEmpty) {
      out.add(_sec('Coming Up', const EdgeInsets.symmetric(vertical: 8)));
      for (final p in comingUp) {
        out.add(_progCard(p, edge: K.ink4, chip: Chip2('Upcoming', kind: ChipKind.a, fontSize: rem(.52))));
      }
    }

    out.add(const SizedBox(height: 20));
    return out;
  }

  // ── Gold "day of festival" context card ──
  Widget? _festivalCard(Map<String, dynamic>? lead) {
    if (lead == null) return null;
    final comm = '${lead['communityName'] ?? ''}';
    if (comm.isEmpty) return null;
    final c = AppData.I.communityByName(comm);

    final label = (c == null ? '' : '${c['editionLabel'] ?? ''}').trim();
    final start = _d(c == null ? '' : '${c['editionStart'] ?? ''}');
    final end = _d(c == null ? '' : '${c['editionEnd'] ?? ''}');
    final totalDays = int.tryParse(c == null ? '' : '${c['editionDays'] ?? ''}') ??
        ((start != null && end != null) ? end.difference(start).inDays + 1 : 0);

    // Which day of the edition is today?
    int dayNo = 0;
    if (start != null) {
      dayNo = AppData.todayDate.difference(start).inDays + 1;
      if (dayNo < 1) dayNo = 1;
      if (totalDays > 0 && dayNo > totalDays) dayNo = totalDays;
    }

    final title = label.isNotEmpty ? label : comm;
    final range = (start != null && end != null) ? '${_dmy(start)} – ${_dmy(end)}' : '';

    return Press(
      scale: .98,
      onTap: () {
        AppData.I.selectedCommunity = c;
        go('s34');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [K.g1, K.g2],
          ),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: K.g3),
        ),
        child: Row(
          children: [
            // Day badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: K.gGold,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(dayNo > 0 ? '$dayNo' : '·',
                      style: mono(size: rem(.85), w: FontWeight.w800, color: Colors.white, height: 1)),
                  Text('DAY',
                      style: ff(
                          size: rem(.4),
                          w: FontWeight.w700,
                          color: Colors.white.withOpacity(.85),
                          ls: .5)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      dayNo > 0 ? 'Day $dayNo · $title' : title,
                      style: ff(size: rem(.68), w: FontWeight.w700, color: K.g5)),
                  if (range.isNotEmpty)
                    Text(range, style: ff(size: rem(.56), color: K.g5.withOpacity(.85))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sec(String text, EdgeInsets padding) => Padding(
        padding: padding,
        child: Text(text.toUpperCase(),
            style: ff(size: rem(.56), w: FontWeight.w700, color: K.ink4, ls: 2)),
      );

  // ── Programme card (.prog-card) ──
  Widget _progCard(Map<String, dynamic> p, {required Color edge, required Widget chip}) {
    final title = '${p['title'] ?? 'Programme'}';
    final time = '${p['time'] ?? ''}';
    final venue = '${p['venue'] ?? ''}';
    final area = '${p['area'] ?? ''}';
    final comm = '${p['communityName'] ?? ''}';
    // Secondary line: prefer venue/time context (no end-time field on live data).
    final subParts = <String>[
      if (comm.isNotEmpty) comm,
      if (venue.isNotEmpty) [venue, if (area.isNotEmpty) area].join(', '),
      if (time.isNotEmpty) time,
    ];
    final sub = subParts.join(' · ');

    return Press(
      scale: .98,
      onTap: () {
        AppData.I.selectedProgram = p;
        go('s12');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: K.white,
          borderRadius: BorderRadius.circular(13),
          border: Border(
            top: BorderSide(color: K.bd),
            right: BorderSide(color: K.bd),
            bottom: BorderSide(color: K.bd),
            left: BorderSide(color: edge, width: 4),
          ),
          boxShadow: K.sh,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: ff(size: rem(.8), w: FontWeight.w700, color: K.ink)),
                  if (sub.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(sub, style: ff(size: rem(.62), color: K.ink3)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            chip,
          ],
        ),
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: K.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: K.bd, width: 1.5),
      ),
      child: Column(
        children: [
          Ico('<polygon points="5 3 19 12 5 21 5 3"/>', size: 36, stroke: K.ink4, sw: 1.5),
          const SizedBox(height: 10),
          Text('Nothing live right now',
              style: ff(size: rem(.78), w: FontWeight.w700, color: K.ink2)),
          const SizedBox(height: 4),
          Text('When a host goes live, the programme will appear here.',
              textAlign: TextAlign.center,
              style: ff(size: rem(.62), color: K.ink4, height: 1.5)),
        ],
      ),
    );
  }
}

/// Pulsing status dot (mirrors CSS `animation:pulse 1.2s infinite`).
class _PulseDot extends StatefulWidget {
  final bool active;
  const _PulseDot({required this.active});
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.active ? const Color(0xFF86EFAC) : Colors.white.withOpacity(.4);
    if (!widget.active) {
      return Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
    }
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: .3).animate(_c),
      child: Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    );
  }
}
