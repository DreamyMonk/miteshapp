import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

// ── Date helpers ────────────────────────────────────────────────────────────
const _MONTHS_S = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _MONTHS_L = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];
const _DAYS_S = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

DateTime? _isoToDate(String iso) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(iso);
  if (m == null) return null;
  return DateTime(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
}

String _fmtDayShort(String iso) {
  final d = _isoToDate(iso);
  if (d == null) return iso;
  return '${d.day} ${_MONTHS_S[d.month - 1]}';
}

String _fmtDayLong(String iso) {
  final d = _isoToDate(iso);
  if (d == null) return iso;
  return '${_DAYS_S[d.weekday % 7]}, ${d.day} ${_MONTHS_L[d.month - 1]} ${d.year}';
}

class S11 extends StatefulWidget {
  const S11({super.key});
  @override
  State<S11> createState() => _S11State();
}

class _S11State extends State<S11> {
  String? _curComm; // selected community name
  String? _curDate; // selected ISO date

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

  List<String> _communities() {
    final seen = <String>[];
    for (final p in AppData.I.livePrograms) {
      final c = '${p['communityName'] ?? ''}'.trim();
      if (c.isNotEmpty && !seen.contains(c)) seen.add(c);
    }
    return seen;
  }

  List<String> _datesOf(String community) {
    final dates = <String>{};
    for (final p in AppData.I.programsOfCommunity(community)) {
      final d = '${p['date'] ?? ''}';
      if (d.isNotEmpty) dates.add(d);
    }
    final list = dates.toList()..sort();
    return list;
  }

  void _selComm(String c) {
    setState(() {
      _curComm = c;
      _curDate = null; // re-resolve for the new community
    });
  }

  void _selDay(String iso) => setState(() => _curDate = iso);

  @override
  Widget build(BuildContext context) {
    final comms = _communities();

    // resolve selected community
    var comm = _curComm;
    if (comm == null || !comms.contains(comm)) {
      comm = comms.isEmpty ? null : comms.first;
    }

    // resolve selected date
    final today = AppData.todayIso;
    final dates = comm == null ? const <String>[] : _datesOf(comm);
    var date = _curDate;
    if (date == null || !dates.contains(date)) {
      if (dates.contains(today)) {
        date = today; // community has programmes today
      } else {
        // earliest upcoming (>= today), else the first date
        String? upcoming;
        for (final d in dates) {
          if (d.compareTo(today) >= 0) {
            upcoming = d;
            break;
          }
        }
        date = upcoming ?? (dates.isEmpty ? null : dates.first);
      }
    }

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
                colors: [K.t9, K.t7, K.t5],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Press(
                      dx: -3,
                      onTap: () => go('s03'),
                      child: Ico(P.arrowLeft, size: 18, stroke: Colors.white, sw: 2.2),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Programme Schedule',
                              style: fd(size: rem(1.05), w: FontWeight.w800, color: Colors.white)),
                          Text('Day-wise plan from your communities',
                              style: ff(size: rem(.58), color: Colors.white.withOpacity(.5))),
                        ],
                      ),
                    ),
                    Press(
                      scale: .9,
                      onTap: () => go('s10'),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.14),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Center(child: Ico(P.calendar, size: 14, stroke: Colors.white, sw: 1.9)),
                      ),
                    ),
                  ],
                ),
                if (comms.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  // community tabs (distinct communities from live programmes)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        for (var i = 0; i < comms.length; i++) ...[
                          if (i > 0) const SizedBox(width: 7),
                          _VenTab(comms[i], on: comms[i] == comm, onTap: () => _selComm(comms[i])),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (comm == null)
            // ── Empty state (no published programmes) ──
            Sc(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              [_emptyCard()],
            )
          else ...[
            // ── Community context strip ──
            _commStrip(comm),
            // ── Day strip ──
            Container(
              decoration: BoxDecoration(
                color: K.white,
                border: Border(bottom: BorderSide(color: K.bd)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 2),
                child: Row(children: _buildDayStrip(dates, date)),
              ),
            ),
            // ── Day content ──
            Sc(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              _buildDayContent(comm, dates, date),
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 36),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: K.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: K.bd, width: 1.5),
      ),
      child: Column(
        children: [
          Ico(P.calendar, size: 38, stroke: K.ink4, sw: 1.5),
          const SizedBox(height: 10),
          Text('No programmes published yet',
              style: ff(size: rem(.78), w: FontWeight.w700, color: K.ink2)),
          const SizedBox(height: 4),
          Text('Programmes published by community hosts will appear here.',
              textAlign: TextAlign.center,
              style: ff(size: rem(.62), color: K.ink4, height: 1.5)),
        ],
      ),
    );
  }

  Widget _commStrip(String comm) {
    final c = AppData.I.communityByName(comm);
    final edition = '${c?['editionLabel'] ?? ''}';
    final venue = '${c?['venue'] ?? ''}';
    final start = '${c?['editionStart'] ?? ''}';
    final end = '${c?['editionEnd'] ?? ''}';
    final span = (start.isNotEmpty && end.isNotEmpty)
        ? '${_fmtDayShort(start)} – ${_fmtDayShort(end)}'
        : '';
    // Festival duration (e.g. "9-day festival") derived from the edition span.
    final sd = _isoToDate(start), ed = _isoToDate(end);
    final dur = (sd != null && ed != null)
        ? '${ed.difference(sd).inDays + 1}-day festival'
        : '';
    // Top (bold) line = venue; falls back to the community name if no venue.
    final title = venue.isNotEmpty ? venue : comm;
    // Second line = edition · date span · festival duration (matches HTML `ven-win`).
    final subParts = <String>[
      if (edition.isNotEmpty) edition,
      if (span.isNotEmpty) span,
      if (dur.isNotEmpty) dur,
    ];
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [K.g1, K.g2],
        ),
        border: Border(bottom: BorderSide(color: K.g3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      child: Row(
        children: [
          Ico(P.venue, size: 14, stroke: K.g5, sw: 1.8),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ff(size: rem(.66), w: FontWeight.w800, color: K.g5)),
                if (subParts.isNotEmpty)
                  Text(subParts.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ff(size: rem(.54), color: K.g5.withOpacity(.85))),
              ],
            ),
          ),
          const SizedBox(width: 9),
          Press(
            scale: .95,
            onTap: () => go('s34'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5A623).withOpacity(.18),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: K.g3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Ico(P.flower, size: 9, stroke: K.g5, sw: 2),
                  const SizedBox(width: 3),
                  Text('Community',
                      style: ff(size: rem(.54), w: FontWeight.w800, color: K.g5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDayStrip(List<String> dates, String? cur) {
    final today = AppData.todayIso;
    final chips = <Widget>[];
    for (var i = 0; i < dates.length; i++) {
      final iso = dates[i];
      if (chips.isNotEmpty) chips.add(const SizedBox(width: 6));
      chips.add(_DayChip(
        num: i + 1,
        date: _fmtDayShort(iso),
        past: iso.compareTo(today) < 0,
        today: iso == today,
        on: iso == cur,
        onTap: () => _selDay(iso),
      ));
    }
    if (chips.isEmpty) {
      chips.add(Padding(
        padding: const EdgeInsets.all(10),
        child: Text('No days scheduled yet.', style: ff(size: rem(.6), color: K.ink4)),
      ));
    }
    return chips;
  }

  List<Widget> _buildDayContent(String comm, List<String> dates, String? date) {
    final widgets = <Widget>[];
    if (date == null) {
      widgets.add(_emptyCard());
      return widgets;
    }

    final progs = AppData.I
        .programsOfCommunity(comm)
        .where((p) => '${p['date']}' == date)
        .toList()
      ..sort((a, b) => '${a['time'] ?? ''}'.compareTo('${b['time'] ?? ''}'));

    final today = AppData.todayIso;
    final status =
        date.compareTo(today) < 0 ? 'past' : (date == today ? 'today' : 'future');
    final dayNum = dates.indexOf(date) + 1;

    // header
    widgets.add(Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Day $dayNum of ${dates.length}',
                    style: fd(size: rem(1.05), w: FontWeight.w800, color: K.ink)),
                Text('${_fmtDayLong(date)} · ${progs.length} programme${progs.length == 1 ? '' : 's'}',
                    style: ff(size: rem(.62), color: K.ink3)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _headerBadge(status),
        ],
      ),
    ));

    // live bridge banner
    if (progs.any((p) => '${p['status']}' == 'live')) {
      widgets.add(_liveBanner());
    }

    if (progs.isEmpty) {
      widgets.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 32),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: K.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: K.bd, width: 1.5),
        ),
        child: Column(
          children: [
            Ico(P.calendar, size: 38, stroke: K.ink4, sw: 1.5),
            const SizedBox(height: 10),
            Text('No schedule yet',
                style: ff(size: rem(.78), w: FontWeight.w700, color: K.ink2)),
            const SizedBox(height: 4),
            Text("The host will publish this day's programmes one day prior.",
                textAlign: TextAlign.center,
                style: ff(size: rem(.62), color: K.ink4, height: 1.5)),
          ],
        ),
      ));
      widgets.add(const SizedBox(height: 20));
      return widgets;
    }

    // auto reminders banner
    if (status == 'future' || status == 'today') {
      widgets.add(Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: K.t0,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: K.t1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Ico(P.bell, size: 14, stroke: K.t7, sw: 1.8),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Auto-reminders active',
                      style: ff(size: rem(.64), w: FontWeight.w800, color: K.t7)),
                  const SizedBox(height: 2),
                  Text('Push notifications 2 hrs, 1 hr, 30 min & 5 min before each programme.',
                      style: ff(size: rem(.54), color: K.t6, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ));
    }

    for (final p in progs) {
      widgets.add(_progCard(p));
    }
    widgets.add(const SizedBox(height: 20));
    return widgets;
  }

  Widget _headerBadge(String status) {
    if (status == 'past') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Ico(P.check, size: 9, stroke: const Color(0xFF6B7280), sw: 2.5),
            const SizedBox(width: 5),
            Text('COMPLETED',
                style: ff(size: rem(.56), w: FontWeight.w800, color: const Color(0xFF6B7280), ls: .4)),
          ],
        ),
      );
    } else if (status == 'today') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF16A34A).withOpacity(.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(color: K.ok, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text('TODAY',
                style: ff(size: rem(.56), w: FontWeight.w800, color: const Color(0xFF15803D), ls: .4)),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: K.t0,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: K.t2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Ico(P.clock, size: 9, stroke: K.t7, sw: 2),
          const SizedBox(width: 5),
          Text('UPCOMING',
              style: ff(size: rem(.56), w: FontWeight.w800, color: K.t7, ls: .4)),
        ],
      ),
    );
  }

  Widget _liveBanner() {
    return Press(
      scale: .98,
      onTap: () => go('s13'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
          ),
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(color: const Color(0xFFDC2626).withOpacity(.3), blurRadius: 14, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(.25)),
              ),
              child: Center(child: Ico('<polygon points="5 3 19 12 5 21 5 3"/>', size: 16, stroke: Colors.white, sw: 2)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LIVE NOW · STREAMING',
                      style: ff(size: rem(.5), w: FontWeight.w800, color: Colors.white.withOpacity(.95), ls: .5)),
                  const SizedBox(height: 2),
                  Text('Watch Live Stream',
                      style: ff(size: rem(.78), w: FontWeight.w800, color: Colors.white, height: 1.2)),
                  const SizedBox(height: 1),
                  Text('Tap to join the live broadcast',
                      style: ff(size: rem(.56), color: Colors.white.withOpacity(.8))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Ico(P.chevR, size: 14, stroke: Colors.white, sw: 2.4),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    switch (status) {
      case 'live':
        return Chip2('● Live', kind: ChipKind.g, fontSize: rem(.52));
      case 'done':
      case 'ended':
        return Chip2('Done', kind: ChipKind.p, fontSize: rem(.52));
      case 'postponed':
        return Chip2('Postponed', kind: ChipKind.a, fontSize: rem(.52));
      case 'cancelled':
        return Chip2('Cancelled', kind: ChipKind.e, fontSize: rem(.52));
      default: // scheduled
        return Chip2('Scheduled', kind: ChipKind.i, fontSize: rem(.52));
    }
  }

  Widget _progCard(Map<String, dynamic> p) {
    final status = '${p['status'] ?? 'scheduled'}'.toLowerCase();
    final isPast = status == 'done' || status == 'ended';
    final Color edge = status == 'live'
        ? K.ok
        : (status == 'cancelled' ? K.er : (status == 'postponed' ? K.g4 : K.t5));
    final venue = '${p['venue'] ?? ''}';
    final area = '${p['area'] ?? ''}';
    final venueLine = [venue, area].where((s) => s.isNotEmpty).join(', ');

    return Press(
      scale: .98,
      onTap: () {
        AppData.I.selectedProgram = p;
        go('s12');
      },
      child: Opacity(
        opacity: isPast ? .7 : 1,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: K.white,
            borderRadius: BorderRadius.circular(13),
            border: Border(
              top: BorderSide(color: K.bd, width: 1.5),
              right: BorderSide(color: K.bd, width: 1.5),
              bottom: BorderSide(color: K.bd, width: 1.5),
              left: BorderSide(color: edge, width: 4),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: K.t0,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Ico(P.calendar, size: 16, stroke: K.t6, sw: 1.8)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text('${p['title'] ?? 'Programme'}',
                              style: ff(size: rem(.78), w: FontWeight.w700, color: K.ink, height: 1.3)),
                        ),
                        const SizedBox(width: 6),
                        _statusChip(status),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Ico(P.clock, size: 10, stroke: K.ink4, sw: 1.9),
                        const SizedBox(width: 3),
                        Text('${p['time'] ?? ''}', style: ff(size: rem(.6), color: K.ink3)),
                      ],
                    ),
                    if (venueLine.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Ico(P.pin, size: 9, stroke: K.ink4, sw: 1.9),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(venueLine,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: ff(size: rem(.58), color: K.ink3)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VenTab extends StatelessWidget {
  final String label;
  final bool on;
  final VoidCallback onTap;
  const _VenTab(this.label, {required this.on, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Press(
      scale: .96,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: on ? Colors.white : Colors.white.withOpacity(.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: on ? Colors.white : Colors.white.withOpacity(.2)),
        ),
        child: Text(label,
            style: ff(
                size: rem(.62),
                w: FontWeight.w700,
                color: on ? K.t7 : Colors.white.withOpacity(.7))),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final int num;
  final String date;
  final bool past, today, on;
  final VoidCallback onTap;
  const _DayChip({
    required this.num,
    required this.date,
    required this.past,
    required this.today,
    required this.on,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    Gradient? grad;
    Color? bg;
    Color border;
    Color numColor, lblColor, dateColor;

    if (today) {
      grad = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [K.t5, K.t7],
      );
      border = Colors.transparent;
      numColor = Colors.white;
      lblColor = Colors.white.withOpacity(.85);
      dateColor = Colors.white.withOpacity(.7);
    } else if (on) {
      bg = K.t6;
      border = K.t6;
      numColor = Colors.white;
      lblColor = Colors.white;
      dateColor = Colors.white.withOpacity(.7);
    } else {
      bg = K.cream;
      border = K.bd;
      numColor = K.ink;
      lblColor = K.ink3;
      dateColor = K.ink4;
    }

    return Opacity(
      opacity: past && !on && !today ? .55 : 1,
      child: Press(
        scale: .96,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 54),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: grad,
            color: bg,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$num',
                  style: mono(size: rem(.95), w: FontWeight.w800, color: numColor)),
              const SizedBox(height: 2),
              Text('DAY',
                  style: ff(size: rem(.5), w: FontWeight.w700, color: lblColor, ls: .4)),
              const SizedBox(height: 1),
              Text(date, style: ff(size: rem(.52), color: dateColor)),
            ],
          ),
        ),
      ),
    );
  }
}
