import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../session.dart';
import '../oem_notif.dart';
import '../widgets/common.dart';
import '../widgets/header.dart';
import '../widgets/svg.dart';

// ===== Icons (inner SVG markup copied from the HTML) =====
const _plus = '<line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>';
const _bell =
    '<path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/>';
const _search = '<circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>';
const _cal =
    '<rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>';
const _chevL = '<polyline points="15 18 9 12 15 6"/>';
const _chevR = '<polyline points="9 18 15 12 9 6"/>';
const _chevDown = '<polyline points="6 9 12 15 18 9"/>';
const _flower =
    '<circle cx="12" cy="12" r="2.5"/><path d="M12 9.5c0-2 1.5-3.5 0-5.5-1.5 2-1.5 3.5 0 5.5M12 14.5c0 2-1.5 3.5 0 5.5 1.5-2 1.5-3.5 0-5.5M9.5 12c-2 0-3.5 1.5-5.5 0 2-1.5 3.5-1.5 5.5 0M14.5 12c2 0 3.5-1.5 5.5 0-2 1.5-3.5 1.5-5.5 0"/>';
const _checkin =
    '<path d="M3 7V5a2 2 0 0 1 2-2h2M17 3h2a2 2 0 0 1 2 2v2M21 17v2a2 2 0 0 1-2 2h-2M7 21H5a2 2 0 0 1-2-2v-2"/><line x1="7" y1="12" x2="17" y2="12"/>';
const _grid =
    '<rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><line x1="14" y1="14" x2="14" y2="14.01"/><line x1="21" y1="14" x2="21" y2="14.01"/><line x1="14" y1="21" x2="14" y2="21.01"/><line x1="21" y1="21" x2="21" y2="21.01"/><line x1="17.5" y1="17.5" x2="17.5" y2="17.51"/>';
const _homeIco =
    '<path d="M19 21V5a2 2 0 0 0-2-2H7a2 2 0 0 0-2 2v16"/><polyline points="9 22 9 12 15 12 15 22"/>';
const _envelope = '<path d="M21 8v13H3V8M1 3h22v5H1zM10 12h4"/>';
const _check = '<polyline points="20 6 9 17 4 12"/>';
const _clock = '<circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>';
const _venue = '<path d="M3 21h18M5 21V7l8-4v18M19 21V11l-6-3"/>';
const _directions = '<polygon points="3 11 22 2 13 21 11 13 3 11"/>';
const _share =
    '<circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/><line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/>';

const _heart =
    '<path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"/>';

const _dShort = ['S', 'M', 'T', 'W', 'T', 'F', 'S']; // index by DateTime.weekday%7
const _mNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

// Dots come only from the user's own events + host-published programmes, keyed
// off the real calendar date (ISO 'YYYY-MM-DD').
List<Color> _dotsFor(DateTime d) {
  final iso = AppData.isoOf(d);
  final out = <Color>[];
  for (final e in AppData.I.eventsForIso(iso)) {
    out.add(_hexColor(e.colorHex));
  }
  for (final _ in AppData.I.liveProgramsForIso(iso)) {
    out.add(const Color(0xFF7C5CBF)); // host-published programme
  }
  return out;
}

// Parse a '#A21CAF' hex string into a Color (opaque).
Color _hexColor(String hex) {
  var h = hex.trim();
  if (h.startsWith('#')) h = h.substring(1);
  final v = int.tryParse(h, radix: 16) ?? 0x7C5CBF;
  return Color(v | 0xFF000000);
}

// Convert a central-store UserEvent into the Map<String,dynamic> shape the feed
// cards + event popup consume.
Map<String, dynamic> _ueToMap(UserEvent e) {
  final m = <String, dynamic>{
    'id': e.id,
    'n': e.name,
    't': e.time,
    'type': e.type,
    'loc': e.loc,
    'c': _hexColor(e.colorHex),
    'icon': e.icon,
    'source': e.source,
    'createdAt': e.createdAt,
    'isWedding': e.isWedding,
    'bride': e.bride,
    'groom': e.groom,
    'family': e.family,
    'host': e.host,
  };
  if (e.isWedding) {
    m['wedding'] = {
      'startDate': e.wedStart,
      'endDate': e.wedEnd,
      'totalFunctions': e.functions.length,
      'nextFunction': e.wedNextFn,
      'nextTime': e.wedNextTime,
      'functions': [
        for (final f in e.functions)
          {
            'n': f.name,
            't': f.dateLabel.isNotEmpty ? '${f.dateLabel}, ${f.time}' : f.time,
            'c': _hexColor(f.colorHex),
            'reminders': f.reminders,
            'notes': f.notes,
            'loc': f.loc,
          },
      ],
    };
  }
  return m;
}

int _parseTime12(String? s) {
  if (s == null) return 9999;
  final m = RegExp(r'(\d+):(\d+)\s*(AM|PM)?', caseSensitive: false).firstMatch(s);
  if (m == null) return 9999;
  var h = int.parse(m.group(1)!);
  final mm = int.parse(m.group(2)!);
  final ap = (m.group(3) ?? '').toUpperCase();
  if (ap == 'PM' && h != 12) h += 12;
  if (ap == 'AM' && h == 12) h = 0;
  return h * 60 + mm;
}

class S03 extends StatefulWidget {
  const S03({super.key});
  @override
  State<S03> createState() => _S03State();
}

class _S03State extends State<S03> {
  // The selected day and the first cell of the 8-day strip window, both real
  // DateTimes anchored to the device's current date.
  DateTime focus = AppData.todayDate;
  // Start the strip ~2 weeks before today so users can slide into the past.
  DateTime stripStart = AppData.todayDate.subtract(const Duration(days: 14));
  // local expand state for wedding cards
  final Set<String> _expanded = {};

  // Horizontal date-strip layout + scrolling.
  static const int _stripDays = 120; // total slidable range of days
  static const double _stripCellW = 42; // matches _dateCell width
  static const double _stripGap = 5; // gap between cells
  static const double _stripStride = _stripCellW + _stripGap;
  final ScrollController _stripCtrl = ScrollController();

  // Number of whole days from stripStart to [d].
  int _stripIndexOf(DateTime d) {
    final a = DateTime(stripStart.year, stripStart.month, stripStart.day);
    final b = DateTime(d.year, d.month, d.day);
    return b.difference(a).inDays;
  }

  // Scroll so the given day sits roughly centered in the strip viewport.
  void _stripScrollToDay(DateTime d, {bool animate = false}) {
    if (!_stripCtrl.hasClients) return;
    final idx = _stripIndexOf(d).clamp(0, _stripDays - 1);
    final viewport = _stripCtrl.position.viewportDimension;
    final raw = idx * _stripStride - (viewport - _stripCellW) / 2;
    final max = _stripCtrl.position.maxScrollExtent;
    final target = raw.clamp(0.0, max).toDouble();
    if (animate) {
      _stripCtrl.animateTo(target,
          duration: const Duration(milliseconds: 320), curve: Curves.easeOut);
    } else {
      _stripCtrl.jumpTo(target);
    }
  }

  // A stable per-day key (day-of-year within a century) used for RSVP entries
  // and wedding expand ids — unique across dates, independent of the month.
  int _dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  // RSVP is persisted in the central store (key '$day-$idx'); fall back to the
  // invite's own seed value when the store has no entry yet.
  String? _rsvpOf(int day, int idx, Map<String, dynamic> iv) =>
      AppData.I.rsvp.containsKey('$day-$idx')
          ? AppData.I.rsvp['$day-$idx']
          : iv['rsvp'] as String?;

  void _setRsvp(int day, int idx, String? status) =>
      AppData.I.setRsvp('$day-$idx', status);

  void _onData() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    AppData.I.addListener(_onData);
    // One-time nudge on aggressive-OEM phones so reminders survive battery savers.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      OemNotif.maybePrompt(context);
      // Center the strip on today on first load.
      _stripScrollToDay(AppData.todayDate);
    });
  }

  @override
  void dispose() {
    AppData.I.removeListener(_onData);
    _stripCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: K.cream,
      child: Column(
        children: [
          _buildHeader(),
          Sc(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
            [
              if (_bannerProg != null) ...[
                _liveBanner(_bannerProg!),
                const SizedBox(height: 12),
              ],
              ..._feed(),
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }

  // ============ Dark header ============
  Widget _buildHeader() {
    return DarkHeader(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // welcome + actions
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back,',
                        style: ff(size: rem(.6), color: Colors.white.withOpacity(.5))),
                    Text(Session.I.displayName,
                        style: fd(size: rem(1.15), w: FontWeight.w800, color: Colors.white)),
                  ],
                ),
              ),
              Press(
                onTap: () => go('s36'),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: K.gGold,
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFFF5A623).withOpacity(.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3)),
                    ],
                  ),
                  child: const Center(child: Ico(_plus, size: 16, stroke: Colors.white, sw: 2.4)),
                ),
              ),
              const SizedBox(width: 6),
              Press(
                onTap: () => go('s16'),
                child: SizedBox(
                  width: 34,
                  height: 34,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white.withOpacity(.12),
                        ),
                        child: const Center(child: Ico(_bell, size: 16, stroke: Colors.white, sw: 1.7)),
                      ),
                      if (AppData.I.unreadCount > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF3D2582), width: 2),
                            ),
                            constraints: const BoxConstraints(minWidth: 16),
                            child: Text(
                                AppData.I.unreadCount > 9 ? '9+' : '${AppData.I.unreadCount}',
                                textAlign: TextAlign.center,
                                style: ff(size: rem(.5), w: FontWeight.w800, color: Colors.white)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Press(
                onTap: () => go('s20'),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.15),
                    border: Border.all(color: Colors.white.withOpacity(.25), width: 2),
                  ),
                  child: Center(
                    child: Text(Session.I.initials,
                        style: fd(size: rem(.7), w: FontWeight.w800, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // search pill
          Press(
            onTap: () => go('s04'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.12),
                border: Border.all(color: Colors.white.withOpacity(.18)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Ico(_search, size: 16, stroke: Colors.white.withOpacity(.6), sw: 2),
                  const SizedBox(width: 9),
                  Text('Community, guru, event, area…',
                      style: ff(size: rem(.74), color: Colors.white.withOpacity(.55))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // month row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('${_mNames[focus.month - 1]} ${focus.year}',
                      style: fd(size: rem(.92), w: FontWeight.w700, color: Colors.white)),
                  const SizedBox(width: 8),
                  Press(
                    onTap: () => go('s24'),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white.withOpacity(.14),
                        border: Border.all(color: Colors.white.withOpacity(.14)),
                      ),
                      child: const Center(child: Ico(_cal, size: 13, stroke: Colors.white, sw: 1.9)),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // "Today" pill — visible only when the strip no longer includes
                  // the real current date. Tapping jumps back to today.
                  if (!_stripIncludesToday()) ...[
                    Press(
                      scale: .9,
                      onTap: _homeJumpToday,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white.withOpacity(.18),
                          border: Border.all(color: Colors.white.withOpacity(.25)),
                        ),
                        child: Text('Today',
                            style: ff(size: rem(.54), w: FontWeight.w800, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  _chevBtn(_chevL, () => _shiftStrip(-1)),
                  const SizedBox(width: 6),
                  _chevBtn(_chevR, () => _shiftStrip(1)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 9),
          // date strip — a long, continuously slidable horizontal list.
          SizedBox(
            height: 64,
            child: ListView.builder(
              controller: _stripCtrl,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 2),
              itemCount: _stripDays,
              itemBuilder: (context, i) => Padding(
                padding: EdgeInsets.only(right: i == _stripDays - 1 ? 0 : _stripGap),
                child: _dateCell(_stripDate(i)),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // The actual calendar DateTime for cell `i`: stripStart + i days.
  DateTime _stripDate(int i) => stripStart.add(Duration(days: i));

  // True when today lies within the slidable range (it always does now, since
  // stripStart is before today and the range spans _stripDays).
  bool _stripIncludesToday() {
    final today = AppData.todayDate;
    final end = stripStart.add(const Duration(days: _stripDays - 1));
    return !today.isBefore(stripStart) && !today.isAfter(end);
  }

  // Slide the strip by roughly a week in the given direction.
  void _shiftStrip(int dir) {
    if (!_stripCtrl.hasClients) return;
    final max = _stripCtrl.position.maxScrollExtent;
    final target =
        (_stripCtrl.offset + dir * 7 * _stripStride).clamp(0.0, max).toDouble();
    _stripCtrl.animateTo(target,
        duration: const Duration(milliseconds: 320), curve: Curves.easeOut);
  }

  void _homeJumpToday() {
    setState(() {
      focus = AppData.todayDate;
    });
    _stripScrollToDay(AppData.todayDate, animate: true);
  }

  Widget _chevBtn(String path, VoidCallback onTap) {
    return Press(
      scale: .9,
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white.withOpacity(.12),
        ),
        child: Center(child: Ico(path, size: 13, stroke: Colors.white, sw: 2.2)),
      ),
    );
  }

  Widget _dateCell(DateTime dt) {
    final d = dt.day;
    final today = AppData.todayDate;
    final isToday = dt.year == today.year && dt.month == today.month && dt.day == today.day;
    // Selection compares the full calendar date.
    final isSelected = dt.year == focus.year && dt.month == focus.month && dt.day == focus.day;
    final dn = _dShort[dt.weekday % 7];
    final dots = _dotsFor(dt);
    final color = isToday ? K.t7 : Colors.white;
    final bg = isToday
        ? Colors.white
        : (isSelected ? Colors.white.withOpacity(.22) : Colors.white.withOpacity(.08));
    final borderColor = isSelected
        ? Colors.white.withOpacity(.4)
        : (isToday ? Colors.transparent : Colors.white.withOpacity(.08));
    return Press(
      onTap: () => setState(() => focus = DateTime(dt.year, dt.month, dt.day)),
      child: Container(
        width: 42,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Text(dn,
                style: ff(
                    size: rem(.5),
                    w: FontWeight.w700,
                    color: isToday ? const Color(0xFF7C5CBF).withOpacity(.7) : Colors.white.withOpacity(.55),
                    ls: .4)),
            const SizedBox(height: 3),
            Text('$d', style: fd(size: rem(.95), w: FontWeight.w800, color: color, height: 1)),
            const SizedBox(height: 4),
            SizedBox(
              height: 4,
              child: dots.isEmpty
                  ? const SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final c in dots.take(3)) ...[
                          Container(width: 4, height: 4, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                          const SizedBox(width: 2),
                        ],
                        if (dots.length > 3)
                          Text('+',
                              style: ff(size: rem(.4), w: FontWeight.w800, color: color)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ Live now banner ============
  // Featured programme: the first live one, else the next scheduled one.
  // Null (banner hidden) when Firestore has no usable programmes.
  Map<String, dynamic>? get _bannerProg {
    // Only surface "Up next" from communities the user actually subscribed to.
    bool mine(Map<String, dynamic> p) =>
        AppData.I.isSubscribed('${p['communityName'] ?? ''}');
    for (final p in AppData.I.livePrograms) {
      if (mine(p) && '${p['status']}'.toLowerCase() == 'live') return p;
    }
    for (final p in AppData.I.livePrograms) {
      if (mine(p) && '${p['status']}'.toLowerCase() == 'scheduled') return p;
    }
    return null;
  }

  // 'YYYY-MM-DD' → 'D Mon' (e.g. '28 May') for the "till …" strip.
  static String _fmtShortDate(String iso) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(iso);
    if (m == null) return iso;
    return '${int.parse(m.group(3)!)} ${_mNames[(int.parse(m.group(2)!) - 1).clamp(0, 11)]}';
  }

  Widget _liveBanner(Map<String, dynamic> prog) {
    final isLive = '${prog['status']}'.toLowerCase() == 'live';
    // Resolve the programme's actual hosting community (not just the first one).
    final progComm = '${prog['communityName'] ?? ''}';
    final hostComm = AppData.I.communityByName(progComm) ??
        (AppData.I.liveCommunities.isNotEmpty ? AppData.I.liveCommunities.first : null);
    final hostName = progComm.isNotEmpty
        ? progComm
        : (hostComm == null ? '' : '${hostComm['name'] ?? ''}');
    final editionEnd = hostComm == null ? '' : '${hostComm['editionEnd'] ?? ''}';
    // Check-in is only for subscribers of the hosting community.
    final canCheckIn = hostName.isNotEmpty && AppData.I.isSubscribed(hostName);
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0E3D), Color(0xFF3D2582)],
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withOpacity(.12),
                ),
                child: const Center(child: Ico(_grid, size: 17, stroke: Colors.white, sw: 1.8)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Press(
                  onTap: () => go('s13'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                  color: Color(0xFF86EFAC), shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(isLive ? 'Live now · tap to watch' : 'Up next · tap to view',
                              style: ff(
                                  size: rem(.48),
                                  w: FontWeight.w800,
                                  color: const Color(0xFF86EFAC),
                                  ls: .5)),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text('${prog['title'] ?? ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ff(size: rem(.74), w: FontWeight.w700, color: Colors.white)),
                      Text('${prog['venue'] ?? ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ff(size: rem(.52), color: Colors.white.withOpacity(.55))),
                    ],
                  ),
                ),
              ),
              // Check In shows only for subscribers of the hosting community.
              if (canCheckIn) ...[
                const SizedBox(width: 8),
                Press(
                  onTap: () => go('s31'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: K.gGold,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFFF5A623).withOpacity(.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Ico(_checkin, size: 14, stroke: Colors.white, sw: 2.2),
                        const SizedBox(width: 5),
                        Text('Check In',
                            style: ff(size: rem(.62), w: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          // dashed sub-row (hidden when no community profile has been published)
          if (hostName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 9),
              child: Container(
                padding: const EdgeInsets.only(top: 9),
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(.13))),
                ),
                child: Press(
                  onTap: () => go('s34'),
                  child: Row(
                    children: [
                      Ico(_flower, size: 11, stroke: const Color(0xFFFDE68A), sw: 2),
                      const SizedBox(width: 8),
                      Text('Hosted by',
                          style: ff(
                              size: rem(.48),
                              w: FontWeight.w800,
                              color: const Color(0xFFFDE68A).withOpacity(.65),
                              ls: .5)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(hostName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ff(
                                size: rem(.62), w: FontWeight.w700, color: const Color(0xFFFDE68A))),
                      ),
                      if (editionEnd.isNotEmpty) ...[
                        const SizedBox(width: 5),
                        Text('till ${_fmtShortDate(editionEnd)}',
                            style: mono(
                                size: rem(.52),
                                w: FontWeight.w700,
                                color: const Color(0xFFFDE68A).withOpacity(.75))),
                      ],
                      const SizedBox(width: 6),
                      Ico(_chevR, size: 9, stroke: const Color(0xFFFDE68A).withOpacity(.5), sw: 2.2),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============ Feed (focus-day timeline) ============
  // Convert a host-published programme (Firestore `programs`) into the
  // community-event map shape the feed cards consume.
  static Map<String, dynamic> _lpToCommunity(Map<String, dynamic> p) {
    final status = '${p['status'] ?? 'scheduled'}'.toLowerCase();
    final s = status == 'live'
        ? 'Live'
        : (status == 'done' || status == 'ended' || status == 'cancelled' ? 'Ended' : 'Scheduled');
    final area = '${p['area'] ?? ''}';
    return {
      'p': p, // raw Firestore programme (for selectedProgram on tap)
      'n': '${p['title'] ?? 'Programme'}',
      't': '${p['time'] ?? ''}',
      'v': '${p['venue'] ?? ''}${area.isNotEmpty ? ', $area' : ''}',
      'community': '${p['communityName'] ?? ''}',
      'c': const Color(0xFF7C5CBF),
      's': s,
      'cd': s == 'Live' ? 'Live now' : '--',
      'im': const [
        {'a': Color(0xFF3D2582), 'b': Color(0xFF7C5CBF), 'k': 'logo'},
        {'a': Color(0xFF1A0E3D), 'b': Color(0xFF5B3E9E), 'k': 'cover'},
      ],
    };
  }

  List<Widget> _feed() {
    final iso = AppData.isoOf(focus);
    // Host-published programmes (Firestore) for the focused date.
    final comm = AppData.I.liveProgramsForIso(iso).map(_lpToCommunity).toList();
    // User-created events from the central store.
    final mine = AppData.I.eventsForIso(iso).map(_ueToMap).toList();
    // Invites: no data source yet — the rendering path stays, it just renders nothing.
    const inv = <Map<String, dynamic>>[];

    // Build interleaved items by time.
    final items = <Map<String, dynamic>>[];
    for (int i = 0; i < comm.length; i++) {
      items.add({'cat': 'community', 't': _parseTime12(comm[i]['t'] as String?), 'idx': i, 'raw': comm[i]});
    }
    for (int i = 0; i < mine.length; i++) {
      final e = mine[i];
      final tStr = (e['isWedding'] == true && e['wedding'] != null)
          ? (e['wedding']['nextTime'] as String?)
          : (e['t'] as String?);
      items.add({'cat': 'mine', 't': _parseTime12(tStr), 'idx': i, 'raw': e});
    }
    for (int i = 0; i < inv.length; i++) {
      items.add({'cat': 'invites', 't': _parseTime12(inv[i]['t'] as String?), 'idx': i, 'raw': inv[i]});
    }
    items.sort((a, b) => (a['t'] as int).compareTo(b['t'] as int));

    final total = items.length;
    final dt = focus;
    final dayName = _weekdayLong(dt.weekday);
    final monShort = _mNames[dt.month - 1];

    final out = <Widget>[];
    out.add(_dateHeaderCard(monShort, dt.day, dayName, comm.length, mine.length, inv.length, total));

    if (total == 0) {
      out.add(_emptyState(dt));
      return out;
    }

    for (final it in items) {
      out.add(_timelineRow(it));
    }
    return out;
  }

  Widget _dateHeaderCard(String mon, int day, String dayName, int comm, int mine, int inv, int total) {
    final pills = <Widget>[];
    if (comm > 0) {
      pills.add(_breakdownPill('$comm Community', const Color(0xFF7C5CBF), const Color(0xFFEDE6F7), const Color(0xFFC4AEE8)));
    }
    if (mine > 0) {
      pills.add(_breakdownPill('$mine Personal', const Color(0xFFD97706), const Color(0xFFFEF3D5), const Color(0xFFFDE68A)));
    }
    if (inv > 0) {
      pills.add(_breakdownPill('$inv Invite${inv > 1 ? 's' : ''}', const Color(0xFFA21CAF), const Color(0xFFFAE8FF), const Color(0xFFF0ABFC)));
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Colors.white, K.cream2]),
        border: Border.all(color: K.bd),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: const Color(0xFF5B3E9E).withOpacity(.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFF5B3E9E), Color(0xFF7C5CBF)]),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: const Color(0xFF5B3E9E).withOpacity(.3), blurRadius: 10, offset: const Offset(0, 3)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(mon.toUpperCase(),
                    style: ff(size: rem(.42), w: FontWeight.w800, color: Colors.white.withOpacity(.8), ls: .5, height: 1)),
                const SizedBox(height: 2),
                Text('$day', style: mono(size: rem(1.35), w: FontWeight.w800, color: Colors.white, height: 1)),
              ],
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dayName, style: fd(size: rem(.92), w: FontWeight.w800, color: K.ink, height: 1.1)),
                const SizedBox(height: 6),
                Wrap(spacing: 7, runSpacing: 6, children: pills),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$total', style: mono(size: rem(1.1), w: FontWeight.w800, color: K.t7, height: 1)),
              const SizedBox(height: 3),
              Text('TOTAL', style: ff(size: rem(.44), w: FontWeight.w800, color: K.ink4, ls: .4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _breakdownPill(String label, Color color, Color bg, Color border) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 5, height: 5, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 3),
          Text(label, style: ff(size: rem(.5), w: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _emptyState(DateTime dt) {
    final ds = '${_weekdayLong(dt.weekday)}, ${_monthLong(dt.month)} ${dt.day}';
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: K.white,
        border: Border.all(color: K.bd, width: 1.5, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(color: K.cream2, shape: BoxShape.circle),
            child: const Center(child: Ico(_cal, size: 22, stroke: K.ink4, sw: 1.6)),
          ),
          const SizedBox(height: 9),
          Text('Nothing on $ds',
              textAlign: TextAlign.center,
              style: fd(size: rem(.84), w: FontWeight.w800, color: K.ink)),
          const SizedBox(height: 4),
          Text('Tap another day with a dot, or add an event.',
              textAlign: TextAlign.center,
              style: ff(size: rem(.6), color: K.ink3, height: 1.5)),
        ],
      ),
    );
  }

  // ── one timeline row: time block + dot on left, category badge + card on right ──
  Widget _timelineRow(Map<String, dynamic> it) {
    final cat = it['cat'] as String;
    final raw = it['raw'] as Map<String, dynamic>;
    final today = AppData.todayDate;
    final now = DateTime.now();
    final nowMins = now.hour * 60 + now.minute;
    final isToday = focus.year == today.year && focus.month == today.month && focus.day == today.day;

    // Display time
    String rawTime;
    if (raw['isWedding'] == true && raw['wedding'] != null) {
      rawTime = (raw['wedding']['nextTime'] as String?) ?? (raw['t'] as String? ?? '');
    } else {
      rawTime = raw['t'] as String? ?? '';
    }
    final shortTime = rawTime.split(',').last.trim();
    final isAllDay = RegExp(r'all\s*day', caseSensitive: false).hasMatch(shortTime);

    // Status
    final catCfg = _catCfg(cat);
    Color statusColor = catCfg.color;
    String statusLabel = '';
    bool isLive = false, isEnded = false;
    final t = it['t'] as int;
    if (isToday) {
      if (raw['isWedding'] == true && raw['wedding'] != null) {
        final sd = int.tryParse(RegExp(r'(\d+)').firstMatch(raw['wedding']['startDate'] as String)?.group(1) ?? '0') ?? 0;
        final ed = int.tryParse(RegExp(r'(\d+)').firstMatch(raw['wedding']['endDate'] as String)?.group(1) ?? '0') ?? 0;
        final fd = focus.day;
        if (sd <= fd && fd <= ed) isLive = true;
      }
      if (!isLive && t < 9999) {
        final diff = t - nowMins;
        if (diff < -30) {
          isEnded = true;
        } else if (diff <= 0) {
          isLive = true;
        } else if (diff <= 90) {
          statusLabel = 'UPNEXT';
          statusColor = const Color(0xFF16A34A);
        } else {
          statusLabel = 'LATER';
        }
      } else if (!isLive && !isEnded && t >= 9999) {
        statusLabel = 'LATER';
      }
      if (isLive) {
        statusLabel = 'LIVE';
        statusColor = const Color(0xFFDC2626);
      } else if (isEnded) {
        statusLabel = 'ENDED';
        statusColor = const Color(0xFF64748B);
      }
    }

    // Parse time parts
    String hh = '', mn = '', ampm = '';
    if (!isAllDay) {
      final tm = RegExp(r'(\d+):(\d+)\s*(AM|PM)?', caseSensitive: false).firstMatch(shortTime);
      if (tm != null) {
        hh = tm.group(1)!;
        mn = tm.group(2)!;
        ampm = (tm.group(3) ?? '').toUpperCase();
      }
    }

    final borderColor = isEnded
        ? const Color(0xFFCBD5E1)
        : (isLive ? const Color(0xFFDC2626) : catCfg.color.withOpacity(.4));
    final timeColor = isEnded ? const Color(0xFF94A3B8) : K.ink;
    final ampmColor = isEnded ? const Color(0xFF94A3B8) : (isLive ? const Color(0xFFDC2626) : catCfg.color);

    Widget card;
    if (cat == 'community') {
      String s = raw['s'] as String? ?? 'Scheduled';
      if (isEnded) {
        s = 'Ended';
      } else if (isLive) {
        s = 'Live';
      } else if (statusLabel == 'UPNEXT') {
        s = 'UpNext';
      }
      card = _evtCard(raw, s);
    } else if (cat == 'mine') {
      card = _myEventCard(raw, it['idx'] as int, _dayKey(focus));
    } else {
      card = _inviteCard(raw, it['idx'] as int, _dayKey(focus));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // left: time block + dot
          SizedBox(
            width: 62,
            child: Column(
              children: [
                Container(
                  constraints: const BoxConstraints(minWidth: 54),
                  margin: const EdgeInsets.only(bottom: 7),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: borderColor, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isLive
                        ? [BoxShadow(color: const Color(0xFFDC2626).withOpacity(.35), blurRadius: 10, offset: const Offset(0, 2))]
                        : (isEnded ? null : [BoxShadow(color: catCfg.color.withOpacity(.13), blurRadius: 6, offset: const Offset(0, 2))]),
                  ),
                  child: Column(
                    children: [
                      if (isAllDay)
                        Text('ALL\nDAY',
                            textAlign: TextAlign.center,
                            style: fd(size: rem(.66), w: FontWeight.w800, color: timeColor, height: 1.1))
                      else ...[
                        Text('$hh:$mn',
                            style: mono(size: rem(.86), w: FontWeight.w800, color: timeColor, height: 1)),
                        if (ampm.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(ampm,
                                style: ff(size: rem(.5), w: FontWeight.w800, color: ampmColor, ls: .4, height: 1)),
                          ),
                      ],
                      if (statusLabel.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          padding: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: isEnded ? const Color(0xFFE2E8F0) : statusColor.withOpacity(.2))),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (statusLabel == 'LIVE' || statusLabel == 'UPNEXT') ...[
                                Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                        color: statusLabel == 'LIVE' ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                                        shape: BoxShape.circle)),
                                const SizedBox(width: 3),
                              ],
                              Text(statusLabel,
                                  style: ff(size: rem(.42), w: FontWeight.w800, color: statusColor, ls: .4)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isEnded ? const Color(0xFF94A3B8) : (isLive ? const Color(0xFFDC2626) : catCfg.color),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(child: Ico(catCfg.icon, size: 7, stroke: Colors.white, sw: 2.4)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 11),
          // right: badge + card
          Expanded(
            child: Opacity(
              opacity: isEnded ? .7 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: catCfg.bg,
                      border: Border.all(color: catCfg.color.withOpacity(.2)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 5, height: 5, decoration: BoxDecoration(color: catCfg.color, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text(catCfg.label,
                            style: ff(size: rem(.46), w: FontWeight.w800, color: catCfg.color, ls: .4)),
                      ],
                    ),
                  ),
                  card,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _CatCfg _catCfg(String cat) {
    switch (cat) {
      case 'mine':
        return const _CatCfg('MY EVENT', Color(0xFFD97706), Color(0xFFFEF3D5), _homeIco);
      case 'invites':
        return const _CatCfg('INVITE', Color(0xFFA21CAF), Color(0xFFFAE8FF), _envelope);
      default:
        return const _CatCfg('COMMUNITY', Color(0xFF7C5CBF), Color(0xFFEDE6F7), _flower);
    }
  }

  // ============ Community event card (evtCard) ============
  Widget _evtCard(Map<String, dynamic> e, String s) {
    final c = e['c'] as Color;
    return Container(
      decoration: BoxDecoration(
        color: K.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: K.bd, width: 1.5),
        boxShadow: K.sh,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: c, width: 4)),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // thumbnail — first carousel slide (logo on the event gradient)
                _evtThumb(e),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(e['n'] as String,
                                style: ff(size: rem(.8), w: FontWeight.w700, color: K.ink, height: 1.25)),
                          ),
                          const SizedBox(width: 6),
                          _statusChip(s),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Ico(_venue, size: 9, stroke: K.ink4, sw: 1.8),
                              const SizedBox(width: 4),
                              Text(e['v'] as String, style: ff(size: rem(.6), color: K.ink3)),
                            ],
                          ),
                          if (e['community'] != null)
                            Press(
                              onTap: () {
                                AppData.I.selectedCommunity =
                                    AppData.I.communityByName('${e['community']}');
                                go('s35');
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('· ', style: ff(size: rem(.6), color: K.ink4)),
                                  Ico(_flower, size: 8, stroke: K.g5, sw: 2),
                                  const SizedBox(width: 3),
                                  Text(e['community'] as String,
                                      style: ff(size: rem(.6), w: FontWeight.w700, color: K.g5)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Ico(_clock, size: 10, stroke: K.t6, sw: 1.9),
                          const SizedBox(width: 3),
                          Text(e['t'] as String, style: ff(size: rem(.6), color: K.ink3)),
                          const SizedBox(width: 6),
                          _countdownChip(e['cd'] as String? ?? '--'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(top: 7),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: K.bd))),
              child: Row(
                children: [
                  Press(
                    onTap: () => gmaps(e['v'] as String? ?? '', ''),
                    child: Row(
                      children: [
                        Ico(_directions, size: 13, stroke: K.t7, sw: 2),
                        const SizedBox(width: 4),
                        Text('Directions', style: ff(size: rem(.62), w: FontWeight.w600, color: K.t7)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Press(
                    onTap: () => toast('Share'),
                    child: Row(
                      children: [
                        Ico(_share, size: 13, stroke: K.t7, sw: 2),
                        const SizedBox(width: 4),
                        Text('Share', style: ff(size: rem(.62), w: FontWeight.w600, color: K.t7)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Press(
                    onTap: () {
                      final p = e['p'];
                      if (p is Map<String, dynamic>) AppData.I.selectedProgram = p;
                      go('s12');
                    },
                    child: Text('Details ›', style: ff(size: rem(.62), w: FontWeight.w600, color: K.t7)),
                  ),
                ],
              ),
            ),
            // RSVP row
            _CommRsvp(program: e['p'] is Map<String, dynamic> ? e['p'] as Map<String, dynamic> : null),
          ],
        ),
      ),
    );
  }

  // Carousel-style thumbnail showing the first slide (a "logo" slide on the
  // event's gradient) plus dot indicators when there are multiple slides.
  Widget _evtThumb(Map<String, dynamic> e) {
    final im = (e['im'] as List?) ?? const [];
    final Color a, b;
    final bool isLogo;
    if (im.isNotEmpty) {
      final first = im.first as Map<String, dynamic>;
      a = first['a'] as Color;
      b = first['b'] as Color;
      isLogo = first['k'] == 'logo';
    } else {
      a = const Color(0xFF3D2582);
      b = const Color(0xFF7C5CBF);
      isLogo = true;
    }
    // The carousel "logo" slide uses this larger centered heart outline.
    const carouselHeart =
        '<path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>';
    return SizedBox(
      width: 74,
      height: 74,
      child: Stack(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [a, b]),
              borderRadius: BorderRadius.circular(11),
            ),
            child: isLogo
                ? Center(
                    child: Ico(carouselHeart, size: 22, stroke: Colors.white.withOpacity(.5), sw: 1.5))
                : Align(
                    alignment: const Alignment(.55, -.55),
                    child: Ico(
                        '<rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/>',
                        size: 20,
                        stroke: Colors.white.withOpacity(.3),
                        sw: 1.5),
                  ),
          ),
          if (im.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < im.length; i++) ...[
                    if (i > 0) const SizedBox(width: 3),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(i == 0 ? .9 : .4),
                        shape: BoxShape.circle,
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

  Widget _statusChip(String s) {
    late Color bg, fg, dot;
    switch (s) {
      case 'Live':
        bg = const Color(0xFFFEE2E2);
        fg = dot = const Color(0xFFDC2626);
        break;
      case 'Ended':
        bg = const Color(0xFFF1F5F9);
        fg = dot = const Color(0xFF64748B);
        break;
      case 'UpNext':
        bg = const Color(0xFFDCFCE7);
        fg = dot = const Color(0xFF16A34A);
        break;
      case 'Today':
        bg = K.g1;
        fg = K.g5;
        dot = K.g4;
        break;
      default:
        bg = K.in1;
        fg = dot = K.inC;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 4, height: 4, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 3),
          Text(s, style: ff(size: rem(.52), w: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }

  Widget _countdownChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: K.t0,
        border: Border.all(color: K.t1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Ico('<circle cx="12" cy="12" r="9"/><polyline points="12 7 12 12 15 14"/>',
              size: 9, stroke: K.t6, sw: 2.2),
          const SizedBox(width: 4),
          Text(text, style: mono(size: rem(.56), w: FontWeight.w700, color: K.t7)),
        ],
      ),
    );
  }

  // ============ My event card ============
  Widget _myEventCard(Map<String, dynamic> e, int idx, int day) {
    if (e['isWedding'] == true) {
      final fnId = 'home-wed-$day-$idx';
      final open = _expanded.contains(fnId);
      final w = e['wedding'] as Map<String, dynamic>;
      final fns = w['functions'] as List;
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: K.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: K.bd),
          boxShadow: K.sh,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Press(
              onTap: () => _openEventDialog(e),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                            colors: [Color(0xFFA21CAF), Color(0xFFE879F9)]),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Center(child: Ico(e['icon'] as String, size: 19, stroke: Colors.white, sw: 1.8)),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _tag('Wedding', const Color(0xFFA21CAF), const Color(0xFFFAE8FF), const Color(0xFFF0ABFC)),
                              const SizedBox(width: 5),
                              Text('${w['totalFunctions']} fns',
                                  style: ff(size: rem(.46), w: FontWeight.w700, color: K.ink4)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(e['n'] as String,
                              style: fd(size: rem(.84), w: FontWeight.w800, color: K.ink, height: 1.22)),
                          const SizedBox(height: 3),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: (w['nextTime'] as String?) ?? 'TBA',
                                  style: mono(size: rem(.54), w: FontWeight.w700, color: K.ink2)),
                              TextSpan(text: ' · ${e['loc']}', style: ff(size: rem(.54), color: K.ink3)),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Ico(_chevR, size: 12, stroke: K.ink4, sw: 2.2),
                  ],
                ),
              ),
            ),
            // toggle row
            Press(
              onTap: () => setState(() => open ? _expanded.remove(fnId) : _expanded.add(fnId)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                decoration: const BoxDecoration(
                  color: K.cream2,
                  border: Border(top: BorderSide(color: K.bd)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(text: 'Next: ', style: ff(size: rem(.58), color: K.ink4)),
                          TextSpan(
                              text: w['nextFunction'] as String,
                              style: ff(size: rem(.58), w: FontWeight.w700, color: K.ink2)),
                        ]),
                      ),
                    ),
                    AnimatedRotation(
                      turns: open ? .5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: const Ico(_chevDown, size: 11, stroke: K.ink3, sw: 2.4),
                    ),
                  ],
                ),
              ),
            ),
            if (open)
              Container(
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: K.bd))),
                child: Column(
                  children: [
                    for (int i = 0; i < fns.length; i++)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                        decoration: BoxDecoration(
                          border: i < fns.length - 1
                              ? const Border(bottom: BorderSide(color: K.bd))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(width: 7, height: 7, decoration: BoxDecoration(color: fns[i]['c'] as Color, shape: BoxShape.circle)),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(fns[i]['n'] as String,
                                  style: ff(size: rem(.64), w: FontWeight.w600, color: K.ink)),
                            ),
                            Text(fns[i]['t'] as String,
                                style: mono(size: rem(.52), w: FontWeight.w700, color: K.ink4)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      );
    }
    // regular card
    final c = e['c'] as Color;
    return Press(
      onTap: () => _openEventDialog(e),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: K.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: K.bd),
          boxShadow: K.sh,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(11)),
              child: Center(child: Ico(e['icon'] as String, size: 19, stroke: Colors.white, sw: 1.8)),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tag(e['type'] as String, c, c.withOpacity(.08), c.withOpacity(.25)),
                  const SizedBox(height: 2),
                  Text(e['n'] as String,
                      style: fd(size: rem(.84), w: FontWeight.w800, color: K.ink, height: 1.22)),
                  const SizedBox(height: 3),
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(text: e['t'] as String, style: mono(size: rem(.54), w: FontWeight.w700, color: K.ink2)),
                      TextSpan(text: ' · ${e['loc']}', style: ff(size: rem(.54), color: K.ink3)),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Ico(_chevR, size: 12, stroke: K.ink4, sw: 2.2),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color color, Color bg, Color border) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text.toUpperCase(),
          style: ff(size: rem(.46), w: FontWeight.w800, color: color, ls: .3)),
    );
  }

  // ============ Invite card ============
  Widget _inviteCard(Map<String, dynamic> iv, int idx, int day) {
    final st = _rsvpOf(day, idx, iv);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: K.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: K.bd),
        boxShadow: K.sh,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: st != null ? 9 : 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [Color(0xFFA21CAF), Color(0xFFE879F9)]),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(child: Ico(iv['icon'] as String, size: 19, stroke: Colors.white, sw: 1.8)),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _tag(iv['type'] as String, const Color(0xFFA21CAF), const Color(0xFFFAE8FF), const Color(0xFFF0ABFC)),
                      const SizedBox(height: 2),
                      Text(iv['n'] as String,
                          style: fd(size: rem(.84), w: FontWeight.w800, color: K.ink, height: 1.22)),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(text: 'By ${iv['host']} · ', style: ff(size: rem(.52), color: K.ink3)),
                          TextSpan(text: iv['t'] as String, style: mono(size: rem(.52), w: FontWeight.w700, color: K.ink3)),
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (st != null)
            Container(
              padding: const EdgeInsets.only(top: 9),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: K.bd))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (st == 'going')
                    Row(
                      children: [
                        const Ico(_check, size: 10, stroke: Color(0xFF16A34A), sw: 2.6),
                        const SizedBox(width: 5),
                        Text("You're going",
                            style: ff(size: rem(.56), w: FontWeight.w700, color: const Color(0xFF16A34A))),
                      ],
                    )
                  else
                    Text('Declined', style: ff(size: rem(.56), w: FontWeight.w700, color: K.ink4)),
                  Press(
                    onTap: () => _setRsvp(day, idx, null),
                    child: Text('Change', style: ff(size: rem(.56), w: FontWeight.w700, color: K.t7)),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Press(
                    onTap: () => _setRsvp(day, idx, 'going'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                            colors: [Color(0xFF16A34A), Color(0xFF15803D)]),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Center(
                        child: Text('Going',
                            style: ff(size: rem(.64), w: FontWeight.w800, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Press(
                    onTap: () => _setRsvp(day, idx, 'not_going'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: K.cream2,
                        border: Border.all(color: K.bd),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Center(
                        child: Text('Decline',
                            style: ff(size: rem(.62), w: FontWeight.w700, color: K.ink3)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ============ Event details popup (openEventPopup / _buildEventPopupHtml) ============
  void _openEventDialog(Map<String, dynamic> e) {
    final day = focus;
    showDialog(
      context: context,
      barrierColor: const Color(0xFF1A0E3D).withOpacity(.55),
      builder: (ctx) => Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * .92),
            decoration: const BoxDecoration(
              color: K.cream,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 2),
                      child: Center(
                        child: Container(
                          width: 38,
                          height: 4,
                          decoration: BoxDecoration(
                              color: K.cream2, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                    ),
                    // Header row with close
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Event Details'.toUpperCase(),
                              style: ff(size: rem(.54), w: FontWeight.w700, color: K.ink4, ls: .4)),
                          Press(
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: K.cream2,
                                shape: BoxShape.circle,
                                border: Border.all(color: K.bd),
                              ),
                              child: const Center(
                                  child: Ico('<line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>',
                                      size: 14, stroke: K.ink2, sw: 2.4)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ..._popupBody(e, day),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Btn('Edit Event', kind: BtnKind.p, margin: 0, onTap: () {
                              Navigator.pop(ctx);
                              go('s37');
                            }),
                          ),
                          const SizedBox(width: 9),
                          Press(
                            onTap: () {
                              Navigator.pop(ctx);
                              final id = '${e['id'] ?? ''}';
                              if (id.isNotEmpty) AppData.I.removeEvent(id);
                              toast('"${e['n']}" deleted');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                border: Border.all(color: const Color(0xFFFCA5A5)),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Ico('<polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6"/>',
                                      size: 13, stroke: Color(0xFFDC2626), sw: 2.2),
                                  const SizedBox(width: 6),
                                  Text('Delete',
                                      style: ff(size: rem(.72), w: FontWeight.w800, color: const Color(0xFFDC2626))),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }

  List<Widget> _popupBody(Map<String, dynamic> e, DateTime day) {
    final isWedding = e['isWedding'] == true && e['wedding'] != null;
    final createdStr = _formatCreated(e['createdAt'] as String?);
    final out = <Widget>[];

    if (isWedding) {
      final w = e['wedding'] as Map<String, dynamic>;
      final fns = w['functions'] as List;
      // Wedding hero
      out.add(Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: K.gHeader, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 5,
              runSpacing: 5,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.white.withOpacity(.6)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Ico(_heart, size: 10, stroke: Color(0xFFA21CAF), sw: 2),
                      const SizedBox(width: 4),
                      Text('Wedding · ${w['totalFunctions']} Functions'.toUpperCase(),
                          style: ff(size: rem(.5), w: FontWeight.w800, color: const Color(0xFFA21CAF), ls: .4)),
                    ],
                  ),
                ),
                _srcPill(e['source'] as String?),
              ],
            ),
            const SizedBox(height: 9),
            Text(e['n'] as String,
                style: fd(size: rem(1.32), w: FontWeight.w800, color: Colors.white, height: 1.15)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 9,
              runSpacing: 4,
              children: [
                _heroMeta(_cal, '${w['startDate']} – ${w['endDate']}'),
                _heroMeta('<path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/>', e['loc'] as String),
              ],
            ),
          ],
        ),
      ));

      // Couple & Family card
      if (e['bride'] != null || e['groom'] != null || e['family'] != null || e['host'] != null) {
        out.add(_coupleCard(e));
      }

      // Next function callout
      out.add(Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [K.t0, K.t1]),
          border: Border.all(color: K.t2),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFF5B3E9E), Color(0xFF7C5CBF)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(child: Ico(_clock, size: 16, stroke: Colors.white, sw: 1.8)),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NEXT FUNCTION',
                      style: ff(size: rem(.52), w: FontWeight.w800, color: K.t7.withOpacity(.7), ls: .4)),
                  const SizedBox(height: 2),
                  Text(w['nextFunction'] as String,
                      style: ff(size: rem(.78), w: FontWeight.w800, color: K.ink, height: 1.25)),
                  const SizedBox(height: 2),
                  Text(w['nextTime'] as String,
                      style: ff(size: rem(.6), w: FontWeight.w700, color: K.t7)),
                ],
              ),
            ),
          ],
        ),
      ));

      // All functions list (with reminders + notes)
      out.add(Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Color(0xFFA21CAF), Color(0xFFE879F9)]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 7),
                Text('All Functions', style: fd(size: rem(.85), w: FontWeight.w800, color: K.ink)),
                const SizedBox(width: 7),
                Expanded(child: Container(height: 1, color: K.bd)),
                const SizedBox(width: 7),
                Text('${fns.length} total', style: ff(size: rem(.54), w: FontWeight.w700, color: K.ink4)),
              ],
            ),
            const SizedBox(height: 10),
            for (int i = 0; i < fns.length; i++) _functionCard(fns[i] as Map<String, dynamic>, i),
          ],
        ),
      ));
    } else {
      final c = e['c'] as Color;
      // Simple event hero
      out.add(Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 5,
              runSpacing: 5,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.white.withOpacity(.6)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Ico(e['icon'] as String, size: 11, stroke: c, sw: 2),
                      const SizedBox(width: 4),
                      Text((e['type'] as String).toUpperCase(),
                          style: ff(size: rem(.5), w: FontWeight.w800, color: c, ls: .4)),
                    ],
                  ),
                ),
                _srcPill(e['source'] as String?),
              ],
            ),
            const SizedBox(height: 9),
            Text(e['n'] as String,
                style: fd(size: rem(1.32), w: FontWeight.w800, color: Colors.white, height: 1.15)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 9,
              runSpacing: 4,
              children: [
                _heroMeta(_clock, e['t'] as String, mono_: true),
                _heroMeta('<path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/>',
                    (e['loc'] as String?) ?? 'No location'),
              ],
            ),
          ],
        ),
      ));

      // Event info card
      out.add(Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: K.white,
          border: Border.all(color: K.bd),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EVENT INFO', style: ff(size: rem(.5), w: FontWeight.w800, color: K.ink2, ls: .4)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _infoCell('DATE', '${day.day} ${_mNames[day.month - 1]} ${day.year}')),
                const SizedBox(width: 11),
                Expanded(child: _infoCell('TIME', e['t'] as String)),
              ],
            ),
          ],
        ),
      ));
    }

    if (createdStr.isNotEmpty) {
      out.add(Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        child: Text(createdStr,
            textAlign: TextAlign.center,
            style: ff(size: rem(.56), color: K.ink4).copyWith(fontStyle: FontStyle.italic)),
      ));
    }
    return out;
  }

  Widget _heroMeta(String icon, String text, {bool mono_ = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Ico(icon, size: 11, stroke: Colors.white.withOpacity(.85), sw: 2),
        const SizedBox(width: 4),
        Text(text,
            style: mono_
                ? mono(size: rem(.62), w: FontWeight.w600, color: Colors.white.withOpacity(.92))
                : ff(size: rem(.62), w: FontWeight.w600, color: Colors.white.withOpacity(.92))),
      ],
    );
  }

  Widget _srcPill(String? source) {
    final isAi = source == 'ai';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.28),
        border: Border.all(color: Colors.white.withOpacity(.25)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isAi ? const Color(0xFFC4AEE8) : const Color(0xFFFDE68A),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Ico(
              isAi
                  ? '<path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/>'
                  : '<path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>',
              size: 9,
              stroke: Colors.white,
              sw: 2.4),
          const SizedBox(width: 4),
          Text((isAi ? 'AI Scan' : 'Manual').toUpperCase(),
              style: ff(size: rem(.5), w: FontWeight.w800, color: Colors.white, ls: .4)),
        ],
      ),
    );
  }

  Widget _coupleCard(Map<String, dynamic> e) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: K.white,
        border: Border.all(color: K.bd),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Ico('<circle cx="9" cy="7" r="4"/><path d="M3 21v-2a4 4 0 0 1 4-4h4a4 4 0 0 1 4 4v2"/><circle cx="17" cy="11" r="3"/>',
                  size: 10, stroke: K.ink2, sw: 2.2),
              const SizedBox(width: 5),
              Text('COUPLE & FAMILY',
                  style: ff(size: rem(.5), w: FontWeight.w800, color: K.ink2, ls: .4)),
            ],
          ),
          const SizedBox(height: 9),
          if (e['bride'] != null || e['groom'] != null)
            Padding(
              padding: EdgeInsets.only(bottom: e['family'] != null ? 8 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _coupleField('BRIDE', (e['bride'] as String?) ?? '—', display: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _coupleField('GROOM', (e['groom'] as String?) ?? '—', display: true)),
                ],
              ),
            ),
          if (e['family'] != null) _coupleField('FAMILY', e['family'] as String),
          if (e['host'] != null)
            Container(
              margin: const EdgeInsets.only(top: 11),
              padding: const EdgeInsets.only(top: 11),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: K.bd))),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HOST CONTACT',
                            style: ff(size: rem(.46), w: FontWeight.w700, color: K.ink4, ls: .3)),
                        const SizedBox(height: 2),
                        Text(e['host'] as String,
                            style: mono(size: rem(.78), w: FontWeight.w800, color: K.ink)),
                      ],
                    ),
                  ),
                  Press(
                    onTap: () => toast('Calling ${e['host']}'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                            colors: [Color(0xFF16A34A), Color(0xFF15803D)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Ico('<path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/>',
                              size: 13, stroke: Colors.white, sw: 2.2),
                          const SizedBox(width: 6),
                          Text('Call',
                              style: ff(size: rem(.68), w: FontWeight.w800, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _coupleField(String label, String value, {bool display = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ff(size: rem(.46), w: FontWeight.w700, color: K.ink4, ls: .3)),
        const SizedBox(height: 2),
        Text(value,
            style: display
                ? fd(size: rem(.78), w: FontWeight.w800, color: K.ink, height: 1.2)
                : ff(size: rem(.7), w: FontWeight.w700, color: K.ink2)),
      ],
    );
  }

  Widget _infoCell(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ff(size: rem(.48), w: FontWeight.w700, color: K.ink4, ls: .3)),
        const SizedBox(height: 3),
        Text(value, style: mono(size: rem(.74), w: FontWeight.w800, color: K.ink)),
      ],
    );
  }

  Widget _functionCard(Map<String, dynamic> f, int i) {
    final c = f['c'] as Color;
    final reminders = (f['reminders'] as List?) ?? const [];
    final notes = (f['notes'] as String?) ?? '';
    final hasExtra = reminders.isNotEmpty || notes.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: K.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: K.bd, width: 1.5),
        boxShadow: K.sh,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: c, width: 4)),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: hasExtra ? 10 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                    child: Center(
                      child: Text('${i + 1}',
                          style: mono(size: rem(.74), w: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f['n'] as String,
                            style: fd(size: rem(.82), w: FontWeight.w800, color: K.ink, height: 1.22)),
                        const SizedBox(height: 3),
                        Text(f['t'] as String,
                            style: mono(size: rem(.6), w: FontWeight.w700, color: K.ink3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (reminders.isNotEmpty)
              Container(
                margin: EdgeInsets.only(bottom: notes.isNotEmpty ? 7 : 0),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(color: K.cream2, borderRadius: BorderRadius.circular(9)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Ico('<path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>',
                            size: 10, stroke: K.ink2, sw: 2.2),
                        const SizedBox(width: 5),
                        Text('REMINDERS (${reminders.length})',
                            style: ff(size: rem(.5), w: FontWeight.w800, color: K.ink2, ls: .4)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        for (final r in reminders)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: K.white,
                              border: Border.all(color: K.bd),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(_formatReminder(r as String),
                                style: ff(size: rem(.56), w: FontWeight.w700, color: K.ink)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            if (notes.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(color: K.cream2, borderRadius: BorderRadius.circular(9)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Ico('<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/>',
                            size: 10, stroke: K.ink2, sw: 2.2),
                        const SizedBox(width: 5),
                        Text('NOTE', style: ff(size: rem(.5), w: FontWeight.w800, color: K.ink2, ls: .4)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notes,
                        style: ff(size: rem(.62), w: FontWeight.w600, color: K.ink2, height: 1.45)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _formatReminder(String min) {
  final m = int.tryParse(min) ?? 0;
  if (m == 0) return 'No reminder';
  if (m < 60) return '$m min before';
  if (m < 1440) return '${m ~/ 60} hour${m >= 120 ? 's' : ''} before';
  if (m < 10080) return '${m ~/ 1440} day${m >= 2880 ? 's' : ''} before';
  return '${m ~/ 10080} week${m >= 20160 ? 's' : ''} before';
}

String _formatCreated(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final cd = DateTime.tryParse(iso);
  if (cd == null) return '';
  var h = cd.hour % 12;
  if (h == 0) h = 12;
  final mm = cd.minute.toString().padLeft(2, '0');
  final ap = cd.hour >= 12 ? 'PM' : 'AM';
  return 'Added ${cd.day} ${_mNames[cd.month - 1]} ${cd.year} · $h:$mm $ap';
}

class _CatCfg {
  final String label;
  final Color color;
  final Color bg;
  final String icon;
  const _CatCfg(this.label, this.color, this.bg, this.icon);
}

// Community card RSVP block (Attending? Going / Can't go + guest stepper).
class _CommRsvp extends StatefulWidget {
  final Map<String, dynamic>? program;
  const _CommRsvp({this.program});
  @override
  State<_CommRsvp> createState() => _CommRsvpState();
}

class _CommRsvpState extends State<_CommRsvp> {
  bool? going;
  int guests = 1;

  @override
  void initState() {
    super.initState();
    // Reflect any previously-saved RSVP for this programme.
    final p = widget.program;
    if (p != null) {
      final st = AppData.I.programRsvp(p);
      if (st == 'going') going = true;
      if (st == 'not_going') going = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: K.bd))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Attending?', style: ff(size: rem(.6), w: FontWeight.w700, color: K.ink3)),
              const SizedBox(width: 7),
              _rsvpBtn('Going', going == true, const Color(0xFF16A34A), () => setState(() {
                    going = true;
                    guests = 1;
                  }), leadingCheck: true),
              const SizedBox(width: 7),
              _rsvpBtn("Can't go", going == false, const Color(0xFFDC2626), () => setState(() => going = false)),
            ],
          ),
          if (going == true) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
              decoration: BoxDecoration(
                color: K.t0,
                border: Border.all(color: K.t1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Ico(
                          '<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>',
                          size: 14, stroke: K.t7, sw: 1.9),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text('How many of you?',
                            style: ff(size: rem(.66), w: FontWeight.w700, color: K.ink)),
                      ),
                      _stepBtn('<line x1="5" y1="12" x2="19" y2="12"/>', K.white, K.t7,
                          () => setState(() => guests = (guests - 1).clamp(1, 20))),
                      const SizedBox(width: 9),
                      Text('$guests',
                          style: mono(size: rem(.95), w: FontWeight.w800, color: K.t7)),
                      const SizedBox(width: 9),
                      _stepBtn(_plus, K.t6, Colors.white,
                          () => setState(() => guests = (guests + 1).clamp(1, 20))),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    padding: const EdgeInsets.only(top: 7),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: K.t2))),
                    width: double.infinity,
                    child: Text(
                        guests == 1
                            ? 'Just you · helps the venue plan food & seating'
                            : 'You + ${guests - 1} other${guests > 2 ? 's' : ''} · total $guests people',
                        style: ff(size: rem(.55), color: K.ink3, height: 1.5)),
                  ),
                ],
              ),
            ),
          ],
          if (going != null) ...[
            const SizedBox(height: 8),
            Press(
              onTap: () {
                final p = widget.program;
                if (p != null) {
                  AppData.I.rsvpToProgram(p, going: going == true, guests: guests);
                }
                toast(going == true
                    ? 'RSVP sent · $guests ${guests > 1 ? 'people' : 'person'}'
                    : 'RSVP sent · Not attending');
              },
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFF7C5CBF), Color(0xFF3D2582)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Ico('<line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/>',
                        size: 11, stroke: Colors.white, sw: 2),
                    const SizedBox(width: 5),
                    Text('Confirm RSVP to Host',
                        style: ff(size: rem(.62), w: FontWeight.w700, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _rsvpBtn(String label, bool on, Color onColor, VoidCallback onTap, {bool leadingCheck = false}) {
    return Press(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: on ? null : K.white,
          gradient: on
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: label == 'Going'
                      ? const [Color(0xFF16A34A), Color(0xFF15803D)]
                      : const [Color(0xFFDC2626), Color(0xFF991B1B)])
              : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: on ? Colors.transparent : K.bd, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingCheck) ...[
              Ico(_check, size: 11, stroke: on ? Colors.white : K.ink3, sw: 2.4),
              const SizedBox(width: 3),
            ],
            Text(label, style: ff(size: rem(.62), w: FontWeight.w700, color: on ? Colors.white : K.ink3)),
          ],
        ),
      ),
    );
  }

  Widget _stepBtn(String icon, Color bg, Color stroke, VoidCallback onTap) {
    return Press(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: bg == K.white ? Border.all(color: K.bd2) : null,
        ),
        child: Center(child: Ico(icon, size: 12, stroke: stroke, sw: 2.6)),
      ),
    );
  }
}

String _weekdayLong(int wd) {
  const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  return names[wd - 1];
}

String _monthLong(int m) {
  const names = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return names[m - 1];
}
