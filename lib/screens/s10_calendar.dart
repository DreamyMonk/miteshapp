import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

const List<String> _mNames = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July',
  'August', 'September', 'October', 'November', 'December'
];
const List<String> _dNames = [
  'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
];
// DSHORT — single-letter weekday labels.
const List<String> _dShort = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

// ── Icons ────────────────────────────────────────────────────────────────────
const _calIcon =
    '<rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>';
const _todayIcon =
    '<circle cx="12" cy="12" r="9"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/>';
const _clockIcon =
    '<circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>';
const _cdClockIcon =
    '<circle cx="12" cy="12" r="9"/><polyline points="12 7 12 12 15 14"/>';
const _heartIcon =
    '<path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>';
const _venueIcon = '<path d="M3 21h18M5 21V7l8-4v18M19 21V11l-6-3"/>';
const _flowerIcon =
    '<circle cx="12" cy="12" r="2.5"/><path d="M12 9.5c0-2 1.5-3.5 0-5.5-1.5 2-1.5 3.5 0 5.5M12 14.5c0 2-1.5 3.5 0 5.5 1.5-2 1.5-3.5 0-5.5M9.5 12c-2 0-3.5 1.5-5.5 0 2-1.5 3.5-1.5 5.5 0M14.5 12c2 0 3.5-1.5 5.5 0-2 1.5-3.5 1.5-5.5 0"/>';
const _directionsIcon = '<polygon points="3 11 22 2 13 21 11 13 3 11"/>';
const _shareIcon =
    '<circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/><line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/>';
const _usersIcon =
    '<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>';
const _checkIcon = '<polyline points="20 6 9 17 4 12"/>';
const _minusIcon = '<line x1="5" y1="12" x2="19" y2="12"/>';
const _plusIcon =
    '<line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>';
const _sendIcon =
    '<line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/>';
const _emptyCal =
    '$_calIcon<line x1="8" y1="14" x2="8" y2="14.01"/><line x1="12" y1="14" x2="12" y2="14.01"/><line x1="16" y1="14" x2="16" y2="14.01"/><line x1="8" y1="18" x2="8" y2="18.01"/><line x1="12" y1="18" x2="12" y2="18.01"/>';

// ── Helpers over store data ──────────────────────────────────────────────────
Color _hex(String h, [Color fallback = const Color(0xFF7C5CBF)]) {
  final s = h.replaceAll('#', '');
  if (s.length != 6) return fallback;
  final v = int.tryParse(s, radix: 16);
  return v == null ? fallback : Color(0xFF000000 | v);
}

/// Display label for a programme status coming from Firestore.
String _statusLabel(String s) {
  switch (s.toLowerCase()) {
    case 'live':
      return 'Live';
    case 'done':
    case 'ended':
      return 'Ended';
    case 'scheduled':
      return 'Scheduled';
    default:
      return s.isEmpty
          ? 'Scheduled'
          : '${s[0].toUpperCase()}${s.substring(1)}';
  }
}

/// Parse the programme's start moment from its ISO date + '7:00 AM' time.
DateTime? _startOf(Map<String, dynamic> p) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch('${p['date'] ?? ''}');
  if (m == null) return null;
  var h = 0, min = 0;
  final t = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)?', caseSensitive: false)
      .firstMatch('${p['time'] ?? ''}');
  if (t != null) {
    h = int.parse(t.group(1)!);
    min = int.parse(t.group(2)!);
    final ap = t.group(3)?.toUpperCase();
    if (ap == 'PM' && h != 12) h += 12;
    if (ap == 'AM' && h == 12) h = 0;
  }
  return DateTime(int.parse(m.group(1)!), int.parse(m.group(2)!),
      int.parse(m.group(3)!), h, min);
}

class S10 extends StatefulWidget {
  const S10({super.key});
  @override
  State<S10> createState() => _S10State();
}

class _S10State extends State<S10> {
  // Visible month/year and selected day — initialised from the real device date.
  late int _year;
  late int _month; // 0-indexed
  late int _day;

  DateTime get _today0 => AppData.todayDate;

  int get _daysInMonth => DateTime(_year, _month + 2, 0).day;

  @override
  void initState() {
    super.initState();
    final t = AppData.todayDate;
    _year = t.year;
    _month = t.month - 1;
    _day = t.day;
    AppData.I.addListener(_onData);
  }

  @override
  void dispose() {
    AppData.I.removeListener(_onData);
    super.dispose();
  }

  void _onData() {
    if (mounted) setState(() {});
  }

  // Change month by a real DateTime step, reset to day 1, rebuild.
  void _stripShift(int dir) {
    setState(() {
      final d = DateTime(_year, _month + 1 + dir, 1);
      _year = d.year;
      _month = d.month - 1;
      _day = 1;
    });
  }

  // Reset to the real current date.
  void _today() {
    setState(() {
      final t = AppData.todayDate;
      _year = t.year;
      _month = t.month - 1;
      _day = t.day;
    });
  }

  // s10Pick — select a day.
  void _pick(int d) => setState(() => _day = d);

  String get _selectedIso => AppData.isoOf(DateTime(_year, _month + 1, _day));

  /// Strip dots — purple for host programmes, event colorHex for user events.
  Map<int, List<Color>> _dotsForMonth() {
    final map = <int, List<Color>>{};
    final dim = _daysInMonth;
    for (var d = 1; d <= dim; d++) {
      final iso = AppData.isoOf(DateTime(_year, _month + 1, d));
      final colors = <Color>[];
      if (AppData.I.liveProgramsForIso(iso).isNotEmpty) colors.add(K.t5);
      for (final e in AppData.I.eventsForIso(iso)) {
        colors.add(_hex(e.colorHex));
      }
      if (colors.isNotEmpty) map[d] = colors;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final dim = _daysInMonth;
    if (_day > dim) _day = dim;

    final iso = _selectedIso;
    final programs = AppData.I.liveProgramsForIso(iso);
    final userEvents = AppData.I.eventsForIso(iso);

    // Selected-day label.
    final dateObj = DateTime(_year, _month + 1, _day);
    final dayName = _dNames[dateObj.weekday % 7];
    final dLabel = '$dayName, $_day ${_mNames[_month]} $_year';

    // Meta text — real counts.
    String meta;
    if (programs.isNotEmpty) {
      final comms = <String>{};
      for (final p in programs) {
        comms.add('${p['communityName'] ?? ''}');
      }
      final n = comms.length;
      meta =
          '${programs.length} programme${programs.length > 1 ? 's' : ''} across $n ${n == 1 ? 'community' : 'communities'}';
      if (userEvents.isNotEmpty) {
        meta +=
            ' · ${userEvents.length} personal event${userEvents.length > 1 ? 's' : ''}';
      }
    } else if (userEvents.isNotEmpty) {
      meta =
          '${userEvents.length} personal event${userEvents.length > 1 ? 's' : ''}';
    } else {
      meta = 'No programmes scheduled';
    }

    return Container(
      color: K.cream,
      child: Column(
        children: [
          // ── Dark header ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            decoration: const BoxDecoration(gradient: K.gHeader),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  BackBtn(onTap: () => go('s03'), dark: false),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Multi-Community Calendar',
                            style: fd(
                                size: rem(1.05),
                                w: FontWeight.w800,
                                color: Colors.white)),
                        Text('All your subscribed communities',
                            style: ff(
                                size: rem(.58),
                                color: Colors.white.withOpacity(.55))),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                // Month label + prev/next
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Press(
                      scale: .9,
                      onTap: () => _stripShift(-1),
                      child: _navBox('<polyline points="15 18 9 12 15 6"/>'),
                    ),
                    Row(children: [
                      Text('${_mNames[_month]} $_year',
                          style: fd(
                              size: rem(.95),
                              w: FontWeight.w800,
                              color: Colors.white)),
                      const SizedBox(width: 8),
                      Press(
                        scale: .9,
                        onTap: () => go('s24'),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.14),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.white.withOpacity(.14)),
                          ),
                          child: Center(
                              child: Ico(_calIcon,
                                  size: 13, stroke: Colors.white, sw: 1.9)),
                        ),
                      ),
                    ]),
                    Press(
                      scale: .9,
                      onTap: () => _stripShift(1),
                      child: _navBox('<polyline points="9 18 15 12 9 6"/>'),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                // Horizontal date strip (s10-strip)
                _DateStrip(
                  daysInMonth: dim,
                  year: _year,
                  month: _month,
                  selected: _day,
                  todayDay: (_year == _today0.year && _month == _today0.month - 1)
                      ? _today0.day
                      : -1,
                  dots: _dotsForMonth(),
                  onPick: _pick,
                ),
              ],
            ),
          ),
          // ── Selected day section ─────────────────────────────────────
          Sc(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dLabel,
                            style: fd(
                                size: rem(.95),
                                w: FontWeight.w800,
                                color: K.ink)),
                        const SizedBox(height: 2),
                        Text(meta, style: ff(size: rem(.58), color: K.ink3)),
                      ],
                    ),
                  ),
                  Press(
                    scale: .95,
                    onTap: _today,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: K.t0,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: K.t1),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Ico(_todayIcon, size: 10, stroke: K.t7, sw: 2),
                        const SizedBox(width: 4),
                        Text('Today',
                            style: ff(
                                size: rem(.58),
                                w: FontWeight.w700,
                                color: K.t7)),
                      ]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              if (programs.isEmpty && userEvents.isEmpty)
                const _EmptyDay()
              else ...[
                ...programs.map((p) => _ProgramCard(p)),
                ...userEvents.map((e) => _UserEventRow(e)),
              ],
              const SizedBox(height: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navBox(String inner) => Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.1),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: Colors.white.withOpacity(.15)),
        ),
        child: Center(child: Ico(inner, size: 13, stroke: Colors.white, sw: 2.2)),
      );
}

// ── Horizontal date strip (port of buildS10 strip) ───────────────────────────
class _DateStrip extends StatelessWidget {
  final int daysInMonth;
  final int year;
  final int month;
  final int selected;
  final int todayDay; // real day-of-month if the visible month is this month, else -1
  final Map<int, List<Color>> dots;
  final void Function(int) onPick;
  const _DateStrip({
    required this.daysInMonth,
    required this.year,
    required this.month,
    required this.selected,
    required this.todayDay,
    required this.dots,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final cells = <Widget>[];
    for (var d = 1; d <= daysInMonth; d++) {
      final dt = DateTime(year, month + 1, d);
      final dn = _dShort[dt.weekday % 7];
      final isToday = d == todayDay;
      final isSelected = d == selected;
      final hasEvent = dots[d];

      final Color bg = isSelected
          ? (isToday ? Colors.white : Colors.white.withOpacity(.25))
          : (hasEvent != null
              ? Colors.white.withOpacity(.1)
              : Colors.white.withOpacity(.06));
      final Color color =
          isSelected ? (isToday ? K.t7 : Colors.white) : Colors.white;
      final FontWeight weight = (isSelected || isToday || hasEvent != null)
          ? FontWeight.w800
          : FontWeight.w600;
      final Border border = isSelected
          ? (isToday
              ? Border.all(color: Colors.transparent)
              : Border.all(color: Colors.white.withOpacity(.4)))
          : Border.all(color: Colors.white.withOpacity(.08));

      cells.add(Padding(
        padding: const EdgeInsets.only(right: 5),
        child: Press(
          scale: .92,
          onTap: () => onPick(d),
          child: Container(
            width: 42,
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: border,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dn,
                  style: ff(
                    size: rem(.5),
                    w: FontWeight.w700,
                    color: (isSelected && isToday)
                        ? const Color(0xFF7C5CBF).withOpacity(.7)
                        : Colors.white.withOpacity(.55),
                    ls: .4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$d',
                  style: fd(
                      size: rem(.95), w: weight, color: color, height: 1),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 4,
                  child: hasEvent != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...hasEvent.take(3).map((c) => Container(
                                  width: 4,
                                  height: 4,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 1),
                                  decoration: BoxDecoration(
                                      color: c, shape: BoxShape.circle),
                                )),
                            if (hasEvent.length > 3)
                              Padding(
                                padding: const EdgeInsets.only(left: 1),
                                child: Text('+',
                                    style: ff(
                                        size: rem(.4),
                                        w: FontWeight.w800,
                                        color:
                                            Colors.white.withOpacity(.7))),
                              ),
                          ],
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(children: cells),
    );
  }
}

// ── Programme card (host-published programme, existing evtCard style) ────────
class _ProgramCard extends StatefulWidget {
  final Map<String, dynamic> p;
  const _ProgramCard(this.p);
  @override
  State<_ProgramCard> createState() => _ProgramCardState();
}

class _ProgramCardState extends State<_ProgramCard> {
  bool? _going; // null | true | false
  int _guests = 1;

  @override
  void initState() {
    super.initState();
    final st = AppData.I.programRsvp(widget.p);
    if (st == 'going') _going = true;
    if (st == 'not_going') _going = false;
  }

  void _setGoing(bool v) => setState(() {
        _going = v;
        _guests = 1;
      });

  void _guest(int delta) => setState(() {
        _guests = (_guests + delta).clamp(1, 20);
      });

  String get _title => '${widget.p['title'] ?? 'Programme'}';
  String get _venue => '${widget.p['venue'] ?? ''}';
  String get _community => '${widget.p['communityName'] ?? ''}';
  String get _time => '${widget.p['time'] ?? ''}';

  void _submit() {
    // Persist locally + to the user's cloud doc, AND write into
    // communities/{cid}/rsvps so the host dashboard sees the RSVP.
    AppData.I.rsvpToProgram(widget.p, going: _going == true, guests: _guests);
    if (_going == true) {
      final total = _guests;
      toast(
          'RSVP sent · $total${total > 1 ? ' people' : ' person'} for $_title');
    } else {
      toast("RSVP sent · Not attending $_title");
    }
  }

  void _open() {
    AppData.I.selectedProgram = widget.p;
    go('s12');
  }

  @override
  Widget build(BuildContext context) {
    final ghint = _guests == 1
        ? 'Just you · helps the venue plan food & seating'
        : 'You + ${_guests - 1} other${_guests > 2 ? 's' : ''} · total $_guests people';
    final start = _startOf(widget.p);

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: K.white,
        borderRadius: BorderRadius.circular(14),
        border: const Border(
          top: BorderSide(color: K.bd, width: 1.5),
          right: BorderSide(color: K.bd, width: 1.5),
          bottom: BorderSide(color: K.bd, width: 1.5),
          left: BorderSide(color: K.t5, width: 4),
        ),
        boxShadow: K.sh,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail (74×74)
              const _Thumb(),
              const SizedBox(width: 10),
              Expanded(
                child: Press(
                  scale: 1,
                  onTap: _open,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(_title,
                                style: ff(
                                    size: rem(.8),
                                    w: FontWeight.w700,
                                    color: K.ink,
                                    height: 1.25)),
                          ),
                          const SizedBox(width: 6),
                          _statusChip(
                              _statusLabel('${widget.p['status'] ?? ''}')),
                        ],
                      ),
                      const SizedBox(height: 3),
                      // venue + community tag
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Ico(_venueIcon,
                                  size: 9, stroke: K.ink4, sw: 1.8),
                              const SizedBox(width: 4),
                              Text(_venue,
                                  style:
                                      ff(size: rem(.6), color: K.ink3)),
                            ],
                          ),
                          if (_community.isNotEmpty)
                            Press(
                              scale: .96,
                              onTap: () {
                                AppData.I.selectedCommunity =
                                    AppData.I.communityByName(_community);
                                go('s35');
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('·',
                                      style:
                                          ff(size: rem(.6), color: K.ink4)),
                                  const SizedBox(width: 4),
                                  Ico(_flowerIcon,
                                      size: 8, stroke: K.g5, sw: 2),
                                  const SizedBox(width: 3),
                                  Text(_community,
                                      style: ff(
                                          size: rem(.6),
                                          w: FontWeight.w700,
                                          color: K.g5)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // time + countdown
                      Row(
                        children: [
                          Ico(_clockIcon, size: 10, stroke: K.t6, sw: 1.9),
                          const SizedBox(width: 3),
                          Text(_time,
                              style: ff(size: rem(.6), color: K.ink3)),
                          if (start != null) ...[
                            const SizedBox(width: 6),
                            _Countdown(start: start),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // footer actions
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.only(top: 7),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: K.bd)),
            ),
            child: Row(
              children: [
                _footerAction(_directionsIcon, 'Directions',
                    () => gmaps(_venue, '${widget.p['area'] ?? ''}')),
                const SizedBox(width: 14),
                _footerAction(_shareIcon, 'Share',
                    () => toast('Share $_title at $_venue')),
                const Spacer(),
                Press(
                  scale: .96,
                  onTap: _open,
                  child: Text('Details ›',
                      style: ff(
                          size: rem(.62),
                          w: FontWeight.w600,
                          color: K.t7)),
                ),
              ],
            ),
          ),
          // RSVP block
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: K.bd)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text('Attending?',
                        style: ff(
                            size: rem(.6),
                            w: FontWeight.w700,
                            color: K.ink3)),
                    const SizedBox(width: 7),
                    _rsvpBtn(
                      label: 'Going',
                      leading: _checkIcon,
                      active: _going == true,
                      activeGradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF16A34A), Color(0xFF15803D)]),
                      onTap: () => _setGoing(true),
                    ),
                    const SizedBox(width: 7),
                    _rsvpBtn(
                      label: "Can't go",
                      active: _going == false,
                      activeGradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFDC2626), Color(0xFF991B1B)]),
                      onTap: () => _setGoing(false),
                    ),
                  ],
                ),
                // guest stepper — only when Going
                if (_going == true) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
                    decoration: BoxDecoration(
                      color: K.t0,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: K.t1),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Ico(_usersIcon,
                                      size: 14, stroke: K.t7, sw: 1.9),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text('How many of you?',
                                        style: ff(
                                            size: rem(.66),
                                            w: FontWeight.w700,
                                            color: K.ink)),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Press(
                                  scale: .9,
                                  onTap: () => _guest(-1),
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: K.white,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      border: Border.all(color: K.bd2),
                                    ),
                                    child: Center(
                                        child: Ico(_minusIcon,
                                            size: 12,
                                            stroke: K.t7,
                                            sw: 2.6)),
                                  ),
                                ),
                                const SizedBox(width: 9),
                                SizedBox(
                                  width: 18,
                                  child: Text('$_guests',
                                      textAlign: TextAlign.center,
                                      style: mono(
                                          size: rem(.95),
                                          w: FontWeight.w800,
                                          color: K.t7)),
                                ),
                                const SizedBox(width: 9),
                                Press(
                                  scale: .9,
                                  onTap: () => _guest(1),
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: K.t6,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                        child: Ico(_plusIcon,
                                            size: 12,
                                            stroke: Colors.white,
                                            sw: 2.6)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 7),
                          padding: const EdgeInsets.only(top: 7),
                          decoration: const BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: K.t2,
                                    style: BorderStyle.solid)),
                          ),
                          width: double.infinity,
                          child: Text(ghint,
                              style: ff(
                                  size: rem(.55),
                                  color: K.ink3,
                                  height: 1.5)),
                        ),
                      ],
                    ),
                  ),
                ],
                // submit — shown once a choice is made
                if (_going != null) ...[
                  const SizedBox(height: 8),
                  Press(
                    scale: .98,
                    onTap: _submit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF7C5CBF), Color(0xFF3D2582)]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Ico(_sendIcon,
                              size: 11, stroke: Colors.white, sw: 2),
                          const SizedBox(width: 5),
                          Text('Confirm RSVP to Host',
                              style: ff(
                                  size: rem(.62),
                                  w: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerAction(String icon, String label, VoidCallback onTap) {
    return Press(
      scale: .96,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Ico(icon, size: 13, stroke: K.t7, sw: 2),
          const SizedBox(width: 4),
          Text(label,
              style: ff(size: rem(.62), w: FontWeight.w600, color: K.t7)),
        ],
      ),
    );
  }

  Widget _rsvpBtn({
    required String label,
    String? leading,
    required bool active,
    required Gradient activeGradient,
    required VoidCallback onTap,
  }) {
    return Press(
      scale: .96,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? null : K.white,
          gradient: active ? activeGradient : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: active ? Colors.transparent : K.bd, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              Ico(leading,
                  size: 11,
                  stroke: active ? Colors.white : K.ink3,
                  sw: 2.4),
              const SizedBox(width: 3),
            ],
            Text(label,
                style: ff(
                    size: rem(.62),
                    w: FontWeight.w700,
                    color: active ? Colors.white : K.ink3)),
          ],
        ),
      ),
    );
  }
}

// ── User event row (simple: name, time, type) ────────────────────────────────
class _UserEventRow extends StatelessWidget {
  final UserEvent e;
  const _UserEventRow(this.e);

  @override
  Widget build(BuildContext context) {
    final c = _hex(e.colorHex);
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: K.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          top: const BorderSide(color: K.bd, width: 1.5),
          right: const BorderSide(color: K.bd, width: 1.5),
          bottom: const BorderSide(color: K.bd, width: 1.5),
          left: BorderSide(color: c, width: 4),
        ),
        boxShadow: K.sh,
      ),
      child: Row(
        children: [
          GBox(
            size: 38,
            radius: 10,
            color: c.withOpacity(.12),
            child: Center(
                child: Ico(e.icon.isNotEmpty ? e.icon : _calIcon,
                    size: 16, stroke: c, sw: 1.9)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.name,
                    style: ff(
                        size: rem(.78), w: FontWeight.w700, color: K.ink)),
                const SizedBox(height: 2),
                Row(children: [
                  Ico(_clockIcon, size: 10, stroke: K.t6, sw: 1.9),
                  const SizedBox(width: 3),
                  Text(e.time, style: ff(size: rem(.6), color: K.ink3)),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: c.withOpacity(.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(e.type,
                style: ff(size: rem(.52), w: FontWeight.w700, color: c)),
          ),
        ],
      ),
    );
  }
}

// ── Programme thumbnail (74×74 purple gradient; replaces demo carousel) ──────
class _Thumb extends StatelessWidget {
  const _Thumb();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      height: 74,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3D2582), Color(0xFF7C5CBF)],
            ),
          ),
          child: Center(
            child: Ico(_heartIcon,
                size: 22, stroke: Colors.white.withOpacity(.5), sw: 1.5),
          ),
        ),
      ),
    );
  }
}

// ── Countdown badge (counts down to the real programme start) ────────────────
class _Countdown extends StatefulWidget {
  final DateTime start;
  const _Countdown({required this.start});
  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _p(int n) => n < 10 ? '0$n' : '$n';

  @override
  Widget build(BuildContext context) {
    final diff = widget.start.difference(DateTime.now());
    final ms = diff.inMilliseconds;

    String text;
    Color bg, border, fg;
    if (ms <= 0) {
      text = 'Live now';
      bg = const Color(0xFF16A34A).withOpacity(.12);
      border = const Color(0xFF86EFAC);
      fg = const Color(0xFF15803D);
    } else {
      var s = diff.inSeconds;
      final d = s ~/ 86400;
      s -= d * 86400;
      final hh = s ~/ 3600;
      s -= hh * 3600;
      final mm = s ~/ 60;
      final ss = s - mm * 60;
      if (d > 0) {
        text = '${d}d ${_p(hh)}:${_p(mm)}:${_p(ss)}';
      } else if (hh > 0) {
        text = '$hh:${_p(mm)}:${_p(ss)}';
      } else {
        text = '$mm:${_p(ss)}';
      }
      // soon emphasis under 30 min
      if (ms <= 1800000) {
        bg = const Color(0xFFB45309).withOpacity(.1);
        border = K.g3;
        fg = K.g5;
      } else {
        bg = K.t0;
        border = K.t1;
        fg = K.t7;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Ico(_cdClockIcon, size: 9, stroke: K.t6, sw: 2.2),
          const SizedBox(width: 4),
          Text(text,
              style: mono(size: rem(.56), w: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}

// ── Status chip (port of sChip + sDot) ───────────────────────────────────────
Widget _statusChip(String s) {
  // sChip
  Color bg, fg, dot;
  switch (s) {
    case 'Live':
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFDC2626);
      dot = const Color(0xFFDC2626);
      break;
    case 'Ended':
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF64748B);
      dot = const Color(0xFF64748B);
      break;
    case 'UpNext':
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF16A34A);
      dot = const Color(0xFF16A34A);
      break;
    case 'Today':
      bg = K.g1;
      fg = K.g5;
      dot = K.g4;
      break;
    default: // Scheduled etc.
      bg = K.in1;
      fg = K.inC;
      dot = K.inC;
  }
  final label = s == 'UpNext' ? 'Up Next' : s;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(label,
            style: ff(size: rem(.52), w: FontWeight.w700, color: fg)),
      ],
    ),
  );
}

// ── Empty day state ──────────────────────────────────────────────────────────
class _EmptyDay extends StatelessWidget {
  const _EmptyDay();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 36),
      decoration: BoxDecoration(
        color: K.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: K.bd, width: 1.5),
      ),
      child: Column(
        children: [
          Ico(_emptyCal, size: 42, stroke: K.ink4, sw: 1.4),
          const SizedBox(height: 11),
          Text('No events today',
              style: ff(size: rem(.82), w: FontWeight.w700, color: K.ink2)),
          const SizedBox(height: 5),
          SizedBox(
            width: 240,
            child: Text(
              'No programmes from your subscribed communities on this date. Tap another day in the strip above to see events.',
              textAlign: TextAlign.center,
              style: ff(size: rem(.62), color: K.ink4, height: 1.55),
            ),
          ),
        ],
      ),
    );
  }
}
