import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

const _arrowBack =
    '<line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/>';
const _plus =
    '<line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>';
const _pencil =
    '<path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>';
const _camera =
    '<path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/>';
const _calendarSmall =
    '<rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>';
const _chevDown = '<polyline points="6 9 12 15 18 9"/>';
const _x = '<line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>';
const _calBox = '<rect x="3" y="4" width="18" height="18" rx="2"/>';
const _trash =
    '<polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6"/>';
const _heart =
    '<path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"/>';
const _calBig =
    '<rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/>';
const _pin =
    '<path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/>';
const _coupleUsers =
    '<circle cx="9" cy="7" r="4"/><path d="M3 21v-2a4 4 0 0 1 4-4h4a4 4 0 0 1 4 4v2"/><circle cx="17" cy="11" r="3"/>';
const _phone =
    '<path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/>';
const _clock = '<circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>';
const _bell = '<path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>';
const _fileNote =
    '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/>';

// ===== View models (populated from AppData.I.events via _ueToEv) =====
class _Fn {
  final String n, t, c;
  final List<String> reminders;
  final String notes;
  final String loc;
  const _Fn(this.n, this.t, this.c,
      {this.reminders = const [], this.notes = '', this.loc = ''});
}

class _Wedding {
  final String startDate, endDate;
  final int totalFunctions;
  final String nextFunction, nextTime;
  final List<_Fn> functions;
  const _Wedding(this.startDate, this.endDate, this.totalFunctions,
      this.nextFunction, this.nextTime, this.functions);
}

class _Ev {
  final String n, t, type, loc, c, icon, source, createdAt;
  final bool isWedding;
  final String bride, groom, family, host;
  final _Wedding? wedding;
  const _Ev({
    required this.n,
    required this.t,
    required this.type,
    this.loc = '',
    required this.c,
    required this.icon,
    this.source = 'manual',
    this.createdAt = '',
    this.isWedding = false,
    this.bride = '',
    this.groom = '',
    this.family = '',
    this.host = '',
    this.wedding,
  });
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

Color _hexColor(String h) {
  final s = h.replaceAll('#', '');
  return Color(int.parse('FF$s', radix: 16));
}

String _formatReminder(String min) {
  final m = int.tryParse(min) ?? 0;
  if (m == 0) return 'No reminder';
  if (m < 60) return '$m min before';
  if (m < 1440) return '${m ~/ 60} hour${m >= 120 ? 's' : ''} before';
  if (m < 10080) return '${m ~/ 1440} day${m >= 2880 ? 's' : ''} before';
  return '${m ~/ 10080} week${m >= 20160 ? 's' : ''} before';
}

class _Collected {
  final _Ev event;
  final int day;
  final String dateIso; // real event date 'YYYY-MM-DD' (falls back to createdAt)
  final int idx;
  final String? storeId; // non-null when the event came from AppData.I.events
  const _Collected(this.event, this.day, this.dateIso, this.idx, {this.storeId});
}

// The real store UserEvent behind a collected row (for the edit flow).
UserEvent? _storeEvent(String? id) {
  if (id == null) return null;
  for (final e in AppData.I.events) {
    if (e.id == id) return e;
  }
  return null;
}

// Resolve an event's real date: prefer dateIso, else the createdAt date.
String _eventIso(UserEvent e) {
  if (e.dateIso.isNotEmpty) return e.dateIso;
  if (e.createdAt.isNotEmpty) {
    final d = DateTime.tryParse(e.createdAt);
    if (d != null) return AppData.isoOf(d);
  }
  return '';
}

// 'YYYY-MM-DD' -> 'D Mon YYYY' (e.g. '3 Jul 2026'); '' -> '' .
String _isoToLabel(String iso) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(iso);
  if (m == null) return '';
  final mon = int.parse(m.group(2)!);
  final day = int.parse(m.group(3)!);
  return '$day ${_months[(mon - 1).clamp(0, 11)]} ${m.group(1)}';
}

/// Convert a store [UserEvent] into the screen's local [_Ev] model.
_Ev _ueToEv(UserEvent e) {
  return _Ev(
    n: e.name,
    t: e.time,
    type: e.type,
    loc: e.loc,
    c: e.colorHex,
    icon: e.icon,
    source: e.source,
    createdAt: e.createdAt,
    isWedding: e.isWedding,
    bride: e.bride,
    groom: e.groom,
    family: e.family,
    host: e.host,
    wedding: e.isWedding
        ? _Wedding(
            e.wedStart,
            e.wedEnd,
            e.functions.length,
            e.wedNextFn,
            e.wedNextTime,
            e.functions
                .map((f) => _Fn(
                      f.name,
                      f.dateLabel.isNotEmpty ? '${f.dateLabel}, ${f.time}' : f.time,
                      f.colorHex,
                      reminders: f.reminders,
                      notes: f.notes,
                      loc: f.loc,
                    ))
                .toList(),
          )
        : null,
  );
}

/// Rounded card with a colored left bar (mirrors CSS `border-left:4px solid c`).
/// Flutter disallows a non-uniform Border together with borderRadius, so the
/// bar is composed via ClipRRect + a Row.
Widget _leftBarCard({
  required Color color,
  required Widget child,
  EdgeInsets margin = EdgeInsets.zero,
  EdgeInsets padding = const EdgeInsets.all(12),
}) {
  return Container(
    width: double.infinity,
    margin: margin,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      boxShadow: K.sh,
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: color),
            Expanded(
              child: Container(
                color: K.white,
                padding: padding,
                child: child,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class S39 extends StatefulWidget {
  const S39({super.key});
  @override
  State<S39> createState() => _S39State();
}

// Sort options (value -> label), order matches the HTML <select>.
const List<List<String>> _sortOpts = [
  ['created-desc', 'Latest'],
  ['created-asc', 'Oldest'],
  ['date-asc', 'Date ↑'],
  ['date-desc', 'Date ↓'],
  ['type', 'Type'],
];

String _sortLabel(String key) {
  for (final o in _sortOpts) {
    if (o[0] == key) return o[1];
  }
  return 'Latest';
}

class _S39State extends State<S39> {
  String s39Filter = 'all'; // 'all' | 'manual' | 'ai'
  String s39Sort = 'created-desc';
  String? s39DateFrom; // 'YYYY-MM-DD' or null
  String? s39DateTo;
  bool s39DatePanelOpen = false;
  final _fromCtl = TextEditingController();
  final _toCtl = TextEditingController();

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
    _fromCtl.dispose();
    _toCtl.dispose();
    super.dispose();
  }

  List<_Collected> _collect() {
    // User-created events from the central store — the only source.
    final arr = <_Collected>[];
    for (final ue in AppData.I.events) {
      arr.add(_Collected(_ueToEv(ue), ue.day, _eventIso(ue), -1, storeId: ue.id));
    }
    return arr;
  }

  void _setFilter(String f) => setState(() => s39Filter = f);

  void _toggleDatePanel() => setState(() => s39DatePanelOpen = !s39DatePanelOpen);

  void _applyDateRange() {
    setState(() {
      s39DateFrom = _fromCtl.text.isEmpty ? null : _fromCtl.text;
      s39DateTo = _toCtl.text.isEmpty ? null : _toCtl.text;
    });
  }

  void _setQuickRange(String kind) {
    final today = AppData.todayDate;
    if (kind == 'today') {
      _fromCtl.text = AppData.isoOf(today);
      _toCtl.text = AppData.isoOf(today);
    } else if (kind == 'week') {
      // Current week (Mon–Sun) around today.
      final start = today.subtract(Duration(days: today.weekday - 1));
      _fromCtl.text = AppData.isoOf(start);
      _toCtl.text = AppData.isoOf(start.add(const Duration(days: 6)));
    } else if (kind == 'month') {
      final start = DateTime(today.year, today.month, 1);
      final end = DateTime(today.year, today.month + 1, 0);
      _fromCtl.text = AppData.isoOf(start);
      _toCtl.text = AppData.isoOf(end);
    }
    _applyDateRange();
  }

  void _clearDateRange() {
    _fromCtl.text = '';
    _toCtl.text = '';
    setState(() {
      s39DateFrom = null;
      s39DateTo = null;
    });
  }

  // Mirrors updateS39DateLabel: "Any date" or "D Mon" / "D Mon – D Mon".
  String _dateLabel() {
    if (s39DateFrom == null && s39DateTo == null) return 'Any date';
    String fmt(String? s) {
      if (s == null || s.isEmpty) return '…';
      final d = DateTime.parse(s);
      return '${d.day} ${_months[d.month - 1]}';
    }

    if (s39DateFrom == s39DateTo) return fmt(s39DateFrom);
    return '${fmt(s39DateFrom)} – ${fmt(s39DateTo)}';
  }

  // Native date picker that writes back into the given controller (YYYY-MM-DD).
  Future<void> _pickDate(TextEditingController ctl) async {
    DateTime initial = AppData.todayDate;
    if (ctl.text.isNotEmpty) {
      initial = DateTime.tryParse(ctl.text) ?? initial;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2030, 12, 31),
    );
    if (picked != null) {
      ctl.text =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      _applyDateRange();
    }
  }

  // Sort dropdown: a styled trigger opening a popup menu (matches renderS39).
  Future<void> _openSortMenu(BuildContext anchorCtx) async {
    final box = anchorCtx.findRenderObject() as RenderBox;
    final overlay =
        Overlay.of(anchorCtx).context.findRenderObject() as RenderBox;
    final pos = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final selected = await showMenu<String>(
      context: anchorCtx,
      position: pos,
      color: K.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      items: _sortOpts
          .map((o) => PopupMenuItem<String>(
                value: o[0],
                height: 38,
                child: Row(
                  children: [
                    Text(o[1],
                        style: ff(
                            size: rem(.66),
                            w: FontWeight.w700,
                            color: s39Sort == o[0] ? K.t7 : K.ink)),
                    if (s39Sort == o[0]) ...[
                      const Spacer(),
                      Ico(P.check, size: 12, stroke: K.t7, sw: 2.4),
                    ],
                  ],
                ),
              ))
          .toList(),
    );
    if (selected != null && selected != s39Sort) {
      setState(() => s39Sort = selected);
    }
  }

  void _delete(_Collected x) {
    // Remove from the central store (notifies + rebuilds).
    if (x.storeId == null) return;
    final name = x.event.n;
    AppData.I.removeEvent(x.storeId!);
    toast('"$name" deleted');
  }

  @override
  Widget build(BuildContext context) {
    final all = _collect();
    final total = all.length;
    final manualCount =
        all.where((x) => (x.event.source.isEmpty ? 'manual' : x.event.source) == 'manual').length;
    final aiCount = all.where((x) => x.event.source == 'ai').length;

    // Filter by source.
    var filtered = all;
    if (s39Filter == 'manual') {
      filtered = all.where((x) => (x.event.source.isEmpty ? 'manual' : x.event.source) == 'manual').toList();
    } else if (s39Filter == 'ai') {
      filtered = all.where((x) => x.event.source == 'ai').toList();
    }
    // Filter by date range (each event's real date, YYYY-MM-DD).
    if (s39DateFrom != null || s39DateTo != null) {
      filtered = filtered.where((x) {
        final evDate = x.dateIso;
        if (evDate.isEmpty) return false;
        if (s39DateFrom != null && evDate.compareTo(s39DateFrom!) < 0) return false;
        if (s39DateTo != null && evDate.compareTo(s39DateTo!) > 0) return false;
        return true;
      }).toList();
    }
    // Sort (matches renderS39).
    filtered = List.of(filtered)
      ..sort((a, b) {
        final ea = a.event, eb = b.event;
        switch (s39Sort) {
          case 'created-desc':
            return eb.createdAt.compareTo(ea.createdAt);
          case 'created-asc':
            return ea.createdAt.compareTo(eb.createdAt);
          case 'date-asc':
            return a.dateIso.compareTo(b.dateIso);
          case 'date-desc':
            return b.dateIso.compareTo(a.dateIso);
          case 'type':
            return ea.type.compareTo(eb.type);
          default:
            return 0;
        }
      });

    return Container(
      color: K.cream,
      child: Column(
        children: [
          _header(total, manualCount, aiCount),
          // Filter chips + count
          Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _chip('all', 'All', null),
                      const SizedBox(width: 6),
                      _chip('manual', 'Manual', _pencil),
                      const SizedBox(width: 6),
                      _chip('ai', 'AI Scan', _camera),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _dateTriggerRow(),
                if (s39DatePanelOpen) ...[
                  const SizedBox(height: 9),
                  _datePanel(),
                ],
                const SizedBox(height: 9),
                RichText(
                  text: TextSpan(
                    text: 'Showing ',
                    style: ff(size: rem(.58), w: FontWeight.w700, color: K.ink4),
                    children: [
                      TextSpan(
                          text: '${filtered.length}',
                          style: ff(size: rem(.58), w: FontWeight.w800, color: K.ink)),
                      const TextSpan(text: ' events'),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
              ],
            ),
          ),
          // List
          Sc(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
            cross: CrossAxisAlignment.stretch,
            [
              if (filtered.isEmpty) _emptyState() else ...filtered.map(_eventCard),
              const SizedBox(height: 14),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Header ----
  Widget _header(int total, int manual, int ai) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 13),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.7, -1),
          end: Alignment(0.7, 1),
          colors: [Color(0xFF1A0E3D), Color(0xFF3D2582), Color(0xFF7C5CBF)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Press(
                onTap: () => go('s03'),
                dx: -3,
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  child: Ico(_arrowBack, size: 18, stroke: Colors.white, sw: 2),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Event Logs',
                        style: fd(size: rem(1.05), w: FontWeight.w800, color: Colors.white, ls: -.2)),
                    Text("All events you've added",
                        style: ff(size: rem(.58), w: FontWeight.w600, color: Colors.white.withOpacity(.6))),
                  ],
                ),
              ),
              Press(
                onTap: () => go('s36'),
                scale: .9,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF5A623), Color(0xFFD97706)]),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFF5A623).withOpacity(.3), blurRadius: 10, offset: const Offset(0, 3)),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Ico(_plus, size: 16, stroke: Colors.white, sw: 2.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              _headerStat('$total', 'Total', Colors.white),
              const SizedBox(width: 7),
              _headerStat('$manual', 'Manual', const Color(0xFFFDE68A)),
              const SizedBox(width: 7),
              _headerStat('$ai', 'AI Scan', const Color(0xFFA07ED4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String num, String label, Color numC) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(.14)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(num, style: mono(size: rem(1), w: FontWeight.w800, color: numC)),
            const SizedBox(height: 3),
            Text(label.toUpperCase(),
                style: ff(size: rem(.46), w: FontWeight.w700, color: Colors.white.withOpacity(.6), ls: .3)),
          ],
        ),
      ),
    );
  }

  // ---- Filter chip ----
  Widget _chip(String key, String label, String? icon) {
    final on = s39Filter == key;
    return Press(
      onTap: () => _setFilter(key),
      scale: .96,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: on ? K.t7 : K.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: on ? Colors.transparent : K.bd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Ico(icon, size: 10, stroke: on ? Colors.white : K.ink3, sw: 2, round: false),
              const SizedBox(width: 5),
            ],
            Text(label,
                style: ff(size: rem(.62), w: FontWeight.w800, color: on ? Colors.white : K.ink3)),
          ],
        ),
      ),
    );
  }

  // ---- Date trigger + sort row ----
  Widget _dateTriggerRow() {
    final active = s39DateFrom != null || s39DateTo != null;
    return Row(
      children: [
        Expanded(
          child: Press(
            onTap: _toggleDatePanel,
            scale: .98,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: K.bd),
              ),
              child: Row(
                children: [
                  Ico(_calendarSmall, size: 13, stroke: K.t7, sw: 1.9),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(_dateLabel(),
                        style: ff(
                            size: rem(.6),
                            w: FontWeight.w700,
                            color: active ? K.t7 : K.ink2)),
                  ),
                  AnimatedRotation(
                    turns: s39DatePanelOpen ? .5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Ico(_chevDown, size: 11, stroke: K.ink4, sw: 2.2, round: false),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 7),
        Builder(
          builder: (sortCtx) => Press(
            onTap: () => _openSortMenu(sortCtx),
            scale: .97,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: K.bd),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_sortLabel(s39Sort),
                      style: ff(size: rem(.6), w: FontWeight.w700, color: K.ink)),
                  const SizedBox(width: 5),
                  Ico(_chevDown, size: 10, stroke: K.ink4, sw: 2.2, round: false),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---- Date range panel (mirrors #s39-date-panel) ----
  Widget _datePanel() {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.7, -1),
          end: Alignment(0.7, 1),
          colors: [Colors.white, K.cream2],
        ),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: K.t1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FILTER BY DATE RANGE',
              style: ff(size: rem(.54), w: FontWeight.w800, color: K.t7, ls: .4)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _dateField('From', _fromCtl)),
              const SizedBox(width: 8),
              Expanded(child: _dateField('To', _toCtl)),
            ],
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _quickChip('Today', () => _setQuickRange('today')),
              _quickChip('This Week', () => _setQuickRange('week')),
              _quickChip('This Month', () => _setQuickRange('month')),
              _quickChip('Clear', _clearDateRange, isClear: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateField(String label, TextEditingController ctl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: ff(size: rem(.48), w: FontWeight.w800, color: K.ink4, ls: .3)),
        const SizedBox(height: 3),
        Press(
          onTap: () => _pickDate(ctl),
          scale: .99,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: K.bd),
            ),
            child: Text(
              ctl.text.isEmpty ? 'Select…' : ctl.text,
              style: ff(
                  size: rem(.66),
                  w: FontWeight.w700,
                  color: ctl.text.isEmpty ? K.ink4 : K.ink),
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickChip(String label, VoidCallback onTap, {bool isClear = false}) {
    return Press(
      onTap: onTap,
      scale: .96,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isClear ? K.cream2 : Colors.white,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: K.bd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isClear) ...[
              Ico(_x, size: 8, stroke: K.ink3, sw: 2.4, round: false),
              const SizedBox(width: 3),
            ],
            Text(label,
                style: ff(
                    size: rem(.54),
                    w: FontWeight.w700,
                    color: isClear ? K.ink3 : K.ink2)),
          ],
        ),
      ),
    );
  }

  // ---- Empty state ----
  Widget _emptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      child: CustomPaint(
        // HTML: border:1.5px dashed var(--bd) — Flutter Border can't dash, so paint it.
        painter: _DashedBorderPainter(color: K.bd, radius: 14, strokeWidth: 1.5),
        child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      decoration: BoxDecoration(
        color: K.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(color: K.cream2, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Ico(_fileNote, size: 22, stroke: K.ink4, sw: 1.6, round: false),
          ),
          const SizedBox(height: 10),
          Text('No events logged',
              style: fd(size: rem(.86), w: FontWeight.w800, color: K.ink)),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 230),
            child: Text(
                s39Filter != 'all'
                    ? 'Try a different filter or add an event.'
                    : 'Add events manually or via AI scan to see them here.',
                style: ff(size: rem(.6), color: K.ink3, height: 1.5),
                textAlign: TextAlign.center),
          ),
        ],
      ),
        ),
      ),
    );
  }

  // ---- Event card ----
  Widget _eventCard(_Collected x) {
    final e = x.event;
    final source = e.source.isEmpty ? 'manual' : e.source;
    final color = _hexColor(e.c);

    String createdStr = '';
    if (e.createdAt.isNotEmpty) {
      final cd = DateTime.parse(e.createdAt);
      final h12 = cd.hour % 12 == 0 ? 12 : cd.hour % 12;
      final mm = cd.minute.toString().padLeft(2, '0');
      createdStr = 'Added ${cd.day} ${_months[cd.month - 1]}, $h12:$mm ${cd.hour >= 12 ? 'PM' : 'AM'}';
    }
    final dateLabel = _isoToLabel(x.dateIso).isNotEmpty ? _isoToLabel(x.dateIso) : 'No date';
    final subtitle = e.isWedding && e.wedding != null
        ? '${e.wedding!.totalFunctions} functions · ${e.wedding!.startDate} – ${e.wedding!.endDate}'
        : '${e.t} · ${e.loc.isEmpty ? 'No location' : e.loc}';

    return _leftBarCard(
      color: color,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Press(
            onTap: () => _openPopup(x),
            scale: .99,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(11)),
                  alignment: Alignment.center,
                  child: Ico(e.icon, size: 19, stroke: Colors.white, sw: 1.8),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 5,
                        runSpacing: 3,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _typeTag(e.type, color),
                          _sourcePill(source),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(e.n, style: fd(size: rem(.82), w: FontWeight.w800, color: K.ink, height: 1.22)),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Ico(_calBox, size: 9, stroke: K.ink4, sw: 1.8),
                          const SizedBox(width: 4),
                          Text(dateLabel, style: ff(size: rem(.54), w: FontWeight.w700, color: K.ink2)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: ff(size: rem(.52), w: FontWeight.w600, color: K.ink4)),
                      if (createdStr.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(createdStr,
                            style: ff(size: rem(.48), w: FontWeight.w600, color: K.ink4)
                                .copyWith(fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action row
          Container(
            margin: const EdgeInsets.only(top: 9),
            padding: const EdgeInsets.only(top: 9),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: K.bd))),
            child: Row(
              children: [
                Expanded(
                  child: Press(
                    onTap: () {
                      AppData.I.editingEvent = _storeEvent(x.storeId);
                      go('s37');
                    },
                    scale: .97,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: K.t0,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: K.t1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Ico(_pencil, size: 10, stroke: K.t7, sw: 2.2, round: false),
                          const SizedBox(width: 5),
                          Text('Edit', style: ff(size: rem(.6), w: FontWeight.w800, color: K.t7)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Press(
                    onTap: () => _delete(x),
                    scale: .97,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Ico(_trash, size: 10, stroke: const Color(0xFFDC2626), sw: 2.2, round: false),
                          const SizedBox(width: 5),
                          Text('Delete',
                              style: ff(size: rem(.6), w: FontWeight.w800, color: const Color(0xFFDC2626))),
                        ],
                      ),
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

  Widget _typeTag(String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Text(type.toUpperCase(),
          style: ff(size: rem(.46), w: FontWeight.w800, color: color, ls: .3)),
    );
  }

  Widget _sourcePill(String source) {
    final ai = source == 'ai';
    final c = ai ? const Color(0xFF7C5CBF) : const Color(0xFFD97706);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.withOpacity(.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.withOpacity(.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Ico(ai ? _camera : _pencil, size: 8, stroke: c, sw: 2.4, round: false),
          const SizedBox(width: 3),
          Text(ai ? 'AI SCAN' : 'MANUAL',
              style: ff(size: rem(.46), w: FontWeight.w800, color: c, ls: .3)),
        ],
      ),
    );
  }

  // ===== Event details popup =====
  void _openPopup(_Collected x) {
    showDialog(
      context: context,
      barrierColor: const Color(0xFF1A0E3D).withOpacity(.55),
      builder: (ctx) => _EventPopup(
        ev: x.event,
        dateIso: x.dateIso,
        onEdit: () {
          Navigator.of(ctx).pop();
          AppData.I.editingEvent = _storeEvent(x.storeId);
          go('s37');
        },
        onDelete: () {
          Navigator.of(ctx).pop();
          _delete(x);
        },
      ),
    );
  }
}

class _EventPopup extends StatelessWidget {
  final _Ev ev;
  final String dateIso;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _EventPopup(
      {required this.ev, required this.dateIso, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final source = ev.source.isEmpty ? 'manual' : ev.source;
    String createdStr = '';
    if (ev.createdAt.isNotEmpty) {
      final cd = DateTime.parse(ev.createdAt);
      final h12 = cd.hour % 12 == 0 ? 12 : cd.hour % 12;
      final mm = cd.minute.toString().padLeft(2, '0');
      createdStr =
          'Added ${cd.day} ${_months[cd.month - 1]} ${cd.year} · $h12:$mm ${cd.hour >= 12 ? 'PM' : 'AM'}';
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .92),
          decoration: const BoxDecoration(
            color: K.cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grip
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: K.ink4.withOpacity(.4), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header row
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('EVENT DETAILS',
                                style: ff(size: rem(.54), w: FontWeight.w700, color: K.ink4, ls: .4)),
                            Press(
                              onTap: () => Navigator.of(context).pop(),
                              scale: .9,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: K.cream2,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: K.bd),
                                ),
                                alignment: Alignment.center,
                                child: Ico(_x, size: 14, stroke: K.ink2, sw: 2.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (ev.isWedding && ev.wedding != null)
                        ..._weddingBody(context, source)
                      else
                        ..._simpleBody(source),
                      if (createdStr.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                          child: Text(createdStr,
                              style: ff(size: rem(.56), w: FontWeight.w600, color: K.ink4)
                                  .copyWith(fontStyle: FontStyle.italic),
                              textAlign: TextAlign.center),
                        ),
                    ],
                  ),
                ),
              ),
              // Sticky actions
              Container(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Press(
                        onTap: onEdit,
                        scale: .98,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF5B3E9E), Color(0xFF7C5CBF)]),
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF5B3E9E).withOpacity(.3), blurRadius: 14, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Ico(_pencil, size: 13, stroke: Colors.white, sw: 2.2, round: false),
                              const SizedBox(width: 6),
                              Text('Edit Event',
                                  style: ff(size: rem(.72), w: FontWeight.w800, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Press(
                      onTap: onDelete,
                      scale: .98,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Ico(_trash, size: 13, stroke: const Color(0xFFDC2626), sw: 2.2, round: false),
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
    );
  }

  Widget _srcPillLight(String source) {
    final ai = source == 'ai';
    final dot = ai ? const Color(0xFFC4AEE8) : const Color(0xFFFDE68A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.28),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Ico(ai ? _camera : _pencil, size: 9, stroke: Colors.white.withOpacity(.9), sw: 2.4, round: false),
          const SizedBox(width: 5),
          Text(ai ? 'AI SCAN' : 'MANUAL',
              style: ff(size: rem(.5), w: FontWeight.w800, color: Colors.white, ls: .4)),
        ],
      ),
    );
  }

  // ---- Wedding popup body ----
  List<Widget> _weddingBody(BuildContext context, String source) {
    final w = ev.wedding!;
    return [
      // Hero
      Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(-0.7, -1),
            end: Alignment(0.7, 1),
            colors: [Color(0xFF1A0E3D), Color(0xFF3D2582), Color(0xFF7C5CBF)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
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
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(.6)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.25), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Ico(_heart, size: 10, stroke: const Color(0xFFA21CAF), sw: 2),
                      const SizedBox(width: 4),
                      Text('WEDDING · ${w.totalFunctions} FUNCTIONS',
                          style: ff(size: rem(.5), w: FontWeight.w800, color: const Color(0xFFA21CAF), ls: .4)),
                    ],
                  ),
                ),
                _srcPillLight(source),
              ],
            ),
            const SizedBox(height: 9),
            Text(ev.n,
                style: fd(size: rem(1.32), w: FontWeight.w800, color: Colors.white, height: 1.15, ls: -.4)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 9,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Ico(_calBig, size: 11, stroke: Colors.white.withOpacity(.85), sw: 2),
                    const SizedBox(width: 4),
                    Text('${w.startDate} – ${w.endDate}',
                        style: ff(size: rem(.62), w: FontWeight.w600, color: Colors.white.withOpacity(.92))),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Ico(_pin, size: 11, stroke: Colors.white.withOpacity(.85), sw: 2),
                    const SizedBox(width: 4),
                    Text(ev.loc,
                        style: ff(size: rem(.62), w: FontWeight.w600, color: Colors.white.withOpacity(.92))),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      // Couple & Family
      if (ev.bride.isNotEmpty || ev.groom.isNotEmpty || ev.family.isNotEmpty || ev.host.isNotEmpty)
        _coupleCard(),
      // Next function
      Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [K.t0, K.t1]),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: K.t2),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF5B3E9E), Color(0xFF7C5CBF)]),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: const Color(0xFF5B3E9E).withOpacity(.3), blurRadius: 9, offset: const Offset(0, 3))],
              ),
              alignment: Alignment.center,
              child: Ico(_clock, size: 16, stroke: Colors.white, sw: 1.8),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NEXT FUNCTION',
                      style: ff(size: rem(.52), w: FontWeight.w800, color: K.t7.withOpacity(.7), ls: .4)),
                  const SizedBox(height: 2),
                  Text(w.nextFunction,
                      style: ff(size: rem(.78), w: FontWeight.w800, color: K.ink, height: 1.25)),
                  const SizedBox(height: 2),
                  Text(w.nextTime, style: ff(size: rem(.6), w: FontWeight.w700, color: K.t7)),
                ],
              ),
            ),
          ],
        ),
      ),
      // All functions
      Padding(
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
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFA21CAF), Color(0xFFE879F9)]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 7),
                Text('All Functions', style: fd(size: rem(.85), w: FontWeight.w800, color: K.ink)),
                const SizedBox(width: 7),
                Expanded(child: Container(height: 1, color: K.bd)),
                const SizedBox(width: 7),
                Text('${w.functions.length} total',
                    style: ff(size: rem(.54), w: FontWeight.w700, color: K.ink4)),
              ],
            ),
            const SizedBox(height: 10),
            ...List.generate(w.functions.length, (i) => _fnCard(w.functions[i], i)),
          ],
        ),
      ),
    ];
  }

  Widget _coupleCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: K.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: K.bd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Ico(_coupleUsers, size: 10, stroke: K.ink2, sw: 2.2, round: false),
              const SizedBox(width: 5),
              Text('COUPLE & FAMILY',
                  style: ff(size: rem(.5), w: FontWeight.w800, color: K.ink2, ls: .4)),
            ],
          ),
          if (ev.bride.isNotEmpty || ev.groom.isNotEmpty) ...[
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(child: _kv('Bride', ev.bride.isEmpty ? '—' : ev.bride)),
                const SizedBox(width: 10),
                Expanded(child: _kv('Groom', ev.groom.isEmpty ? '—' : ev.groom)),
              ],
            ),
          ],
          if (ev.family.isNotEmpty) ...[
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FAMILY', style: ff(size: rem(.46), w: FontWeight.w700, color: K.ink4, ls: .3)),
                const SizedBox(height: 2),
                Text(ev.family, style: ff(size: rem(.7), w: FontWeight.w700, color: K.ink2)),
              ],
            ),
          ],
          if (ev.host.isNotEmpty) ...[
            const SizedBox(height: 11),
            Container(
              padding: const EdgeInsets.only(top: 11),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: K.bd))),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HOST CONTACT',
                            style: ff(size: rem(.46), w: FontWeight.w700, color: K.ink4, ls: .3)),
                        const SizedBox(height: 2),
                        Text(ev.host, style: mono(size: rem(.78), w: FontWeight.w800, color: K.ink)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF16A34A), Color(0xFF15803D)]),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: const Color(0xFF16A34A).withOpacity(.3), blurRadius: 10, offset: const Offset(0, 3))],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Ico(_phone, size: 13, stroke: Colors.white, sw: 2.2),
                        const SizedBox(width: 6),
                        Text('Call', style: ff(size: rem(.68), w: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: ff(size: rem(.46), w: FontWeight.w700, color: K.ink4, ls: .3)),
        const SizedBox(height: 2),
        Text(value, style: fd(size: rem(.78), w: FontWeight.w800, color: K.ink, height: 1.2)),
      ],
    );
  }

  Widget _fnCard(_Fn f, int i) {
    final c = _hexColor(f.c);
    final reminders = f.reminders;
    final notes = f.notes;
    return _leftBarCard(
      color: c,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text('${i + 1}', style: mono(size: rem(.74), w: FontWeight.w800, color: Colors.white)),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.n, style: fd(size: rem(.82), w: FontWeight.w800, color: K.ink, height: 1.22)),
                    const SizedBox(height: 3),
                    Text(f.t, style: mono(size: rem(.6), w: FontWeight.w700, color: K.ink3)),
                  ],
                ),
              ),
            ],
          ),
          if (reminders.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: K.cream2, borderRadius: BorderRadius.circular(9)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Ico(_bell, size: 10, stroke: K.ink2, sw: 2.2, round: false),
                      const SizedBox(width: 5),
                      Text('REMINDERS (${reminders.length})',
                          style: ff(size: rem(.5), w: FontWeight.w800, color: K.ink2, ls: .4)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: reminders
                        .map((r) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: K.bd),
                              ),
                              child: Text(_formatReminder(r),
                                  style: ff(size: rem(.56), w: FontWeight.w700, color: K.ink)),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: K.cream2, borderRadius: BorderRadius.circular(9)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Ico(_fileNote, size: 10, stroke: K.ink2, sw: 2.2, round: false),
                      const SizedBox(width: 5),
                      Text('NOTE', style: ff(size: rem(.5), w: FontWeight.w800, color: K.ink2, ls: .4)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(notes, style: ff(size: rem(.62), w: FontWeight.w600, color: K.ink2, height: 1.45)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---- Simple event popup body ----
  List<Widget> _simpleBody(String source) {
    final color = _hexColor(ev.c);
    return [
      // Hero
      Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(.8),
          borderRadius: BorderRadius.circular(16),
        ),
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
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(.6)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.15), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Ico(ev.icon, size: 11, stroke: color, sw: 2),
                      const SizedBox(width: 4),
                      Text(ev.type.toUpperCase(),
                          style: ff(size: rem(.5), w: FontWeight.w800, color: color, ls: .4)),
                    ],
                  ),
                ),
                _srcPillLight(source),
              ],
            ),
            const SizedBox(height: 9),
            Text(ev.n,
                style: fd(size: rem(1.32), w: FontWeight.w800, color: Colors.white, height: 1.15, ls: -.4)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 9,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Ico(_clock, size: 11, stroke: Colors.white, sw: 2),
                    const SizedBox(width: 4),
                    Text(ev.t,
                        style: mono(size: rem(.66), w: FontWeight.w700, color: Colors.white.withOpacity(.95))),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Ico(_pin, size: 11, stroke: Colors.white, sw: 2),
                    const SizedBox(width: 4),
                    Text(ev.loc.isEmpty ? 'No location' : ev.loc,
                        style: ff(size: rem(.66), w: FontWeight.w700, color: Colors.white.withOpacity(.95))),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      // Event info card
      Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: K.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: K.bd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EVENT INFO', style: ff(size: rem(.5), w: FontWeight.w800, color: K.ink2, ls: .4)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _kvMono('Date', _isoToLabel(dateIso).isNotEmpty ? _isoToLabel(dateIso) : 'No date')),
                const SizedBox(width: 11),
                Expanded(child: _kvMono('Time', ev.t)),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  Widget _kvMono(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: ff(size: rem(.48), w: FontWeight.w700, color: K.ink4, ls: .3)),
        const SizedBox(height: 3),
        Text(value, style: mono(size: rem(.74), w: FontWeight.w800, color: K.ink)),
      ],
    );
  }
}

/// Paints a rounded-rect dashed border (mirrors CSS `border:Npx dashed color`).
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dash;
  final double gap;
  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 1.5,
    this.dash = 5,
    this.gap = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final inset = strokeWidth / 2;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(inset, inset, size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dash;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth ||
      old.dash != dash ||
      old.gap != gap;
}
