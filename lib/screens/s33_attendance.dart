import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

// ===== Icon inner-markup (verbatim from HTML svg bodies) =====
const _icSearch = '<circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>';
const _icX = '<line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>';
const _icCal =
    '<rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>';
const _icFlower =
    '<circle cx="12" cy="12" r="2.5"/><path d="M12 9.5c0-2 1.5-3.5 0-5.5-1.5 2-1.5 3.5 0 5.5M12 14.5c0 2-1.5 3.5 0 5.5 1.5-2 1.5-3.5 0-5.5M9.5 12c-2 0-3.5 1.5-5.5 0 2-1.5 3.5-1.5 5.5 0M14.5 12c2 0 3.5-1.5 5.5 0-2 1.5-3.5 1.5-5.5 0"/>';
const _icVenue = '<path d="M3 21h18M5 21V7l8-4v18M19 21V11l-6-3"/>';
const _icCheck = '<polyline points="20 6 9 17 4 12"/>';
const _icXCircle = '<circle cx="12" cy="12" r="9"/><line x1="9" y1="9" x2="15" y2="15"/><line x1="15" y1="9" x2="9" y2="15"/>';
const _icClock = '<circle cx="12" cy="12" r="9"/><polyline points="12 7 12 12 15 14"/>';
const _icFileText =
    '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/>';
const _icRefresh = '<polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 2.13-9.36L1 10"/>';
const _icArrowLeft = '<line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/>';

// ===== Row model (populated from AppData.I.checkIns at runtime) =====
class _Att {
  final String ev, venue, date, iso, time, status, c, community, edition, window;
  const _Att(this.ev, this.venue, this.date, this.iso, this.time, this.status, this.c, this.community, this.edition,
      this.window);
}

class S33 extends StatefulWidget {
  const S33({super.key});
  @override
  State<S33> createState() => _S33State();
}

class _S33State extends State<S33> {
  String _filter = 'all'; // all|done|miss
  String _rangeKey = 'all'; // all|7d|30d|3mo|yr|custom
  bool _customShown = false;
  String _search = '';
  DateTime? _customFrom;
  DateTime? _customTo;
  final TextEditingController _searchCtl = TextEditingController();

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
    _searchCtl.dispose();
    super.dispose();
  }

  // Date-range filter is relative to the real current date.
  bool _inRange(String iso) {
    if (iso.isEmpty || _rangeKey == 'all') return true;
    final d = DateTime.parse(iso);
    final now = AppData.todayDate;
    if (_rangeKey == '7d') return !d.isBefore(now.subtract(const Duration(days: 7)));
    if (_rangeKey == '30d') return !d.isBefore(now.subtract(const Duration(days: 30)));
    if (_rangeKey == '3mo') {
      final c = DateTime(now.year, now.month - 3, now.day);
      return !d.isBefore(c);
    }
    if (_rangeKey == 'yr') return d.year == now.year;
    if (_rangeKey == 'custom') {
      if (_customFrom != null && d.isBefore(_customFrom!)) return false;
      if (_customTo != null) {
        final t = DateTime(_customTo!.year, _customTo!.month, _customTo!.day, 23, 59, 59);
        if (d.isAfter(t)) return false;
      }
      return true;
    }
    return true;
  }

  // Real check-ins (from the QR scanner / manual code), newest first.
  List<_Att> get _allRecords {
    final community = AppData.I.liveCommunities.isNotEmpty
        ? '${AppData.I.liveCommunities.first['name'] ?? ''}'
        : '';
    return AppData.I.checkIns
        .map((r) => _Att(r.event, r.venue, r.dateLabel, r.dateIso, r.time, 'done', '#7C5CBF', community, '', ''))
        .toList();
  }

  List<_Att> _filtered() {
    final sv = _search.toLowerCase().trim();
    return _allRecords.where((a) {
      if (_filter != 'all' && a.status != _filter) return false;
      if (!_inRange(a.iso)) return false;
      if (sv.isNotEmpty) {
        final blob = '${a.ev} ${a.community} ${a.venue} ${a.edition}'.toLowerCase();
        if (!blob.contains(sv)) return false;
      }
      return true;
    }).toList();
  }

  void _resetAll() {
    setState(() {
      _search = '';
      _searchCtl.clear();
      _filter = 'all';
      _rangeKey = 'all';
      _customShown = false;
      _customFrom = null;
      _customTo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = _filtered();
    final totalDone = data.where((x) => x.status == 'done').length;
    final totalMiss = data.where((x) => x.status == 'miss').length;
    final rate = (totalDone + totalMiss) > 0 ? (100 * totalDone / (totalDone + totalMiss)).round() : 0;

    return Container(
      color: K.cream,
      child: Column(
        children: [
          // ===== Dark header =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.7, -1),
                end: Alignment(0.7, 1),
                colors: [K.t9, K.t7, K.t5],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Press(
                    dx: -3,
                    onTap: () => go('s03'),
                    child: Ico(_icArrowLeft, size: 18, stroke: Colors.white.withOpacity(.85), sw: 2.2),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Attendance History', style: fd(size: rem(1.05), w: FontWeight.w800, color: Colors.white)),
                        Text('Your event check-in record',
                            style: ff(size: rem(.58), color: Colors.white.withOpacity(.5))),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.96),
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.15), blurRadius: 10, offset: const Offset(0, 3))],
                  ),
                  child: Row(children: [
                    const SizedBox(width: 13),
                    Ico(_icSearch, size: 14, stroke: K.t6, sw: 2.2),
                    const SizedBox(width: 9),
                    Expanded(
                      child: TextField(
                        controller: _searchCtl,
                        onChanged: (v) => setState(() => _search = v),
                        style: ff(size: rem(.74), color: K.ink),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Search event, community, or venue...',
                          hintStyle: ff(size: rem(.74), color: K.ink4),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    if (_search.isNotEmpty)
                      Press(
                        scale: .9,
                        onTap: () => setState(() {
                          _search = '';
                          _searchCtl.clear();
                        }),
                        child: Container(
                          margin: const EdgeInsets.only(right: 11),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(color: K.bd2, shape: BoxShape.circle),
                          child: Center(child: Ico(_icX, size: 9, stroke: Colors.white, sw: 2.6)),
                        ),
                      )
                    else
                      const SizedBox(width: 11),
                  ]),
                ),
                const SizedBox(height: 11),
                // Summary pills
                Row(children: [
                  _StatPill(
                    value: '$totalDone',
                    label: 'Attended',
                    bg: const Color(0xFF16A34A).withOpacity(.2),
                    border: const Color(0xFF86EFAC).withOpacity(.3),
                    valColor: const Color(0xFF86EFAC),
                    labelColor: Colors.white.withOpacity(.55),
                  ),
                  const SizedBox(width: 8),
                  _StatPill(
                    value: '$totalMiss',
                    label: 'Missed',
                    bg: Colors.white.withOpacity(.08),
                    border: Colors.white.withOpacity(.12),
                    valColor: Colors.white.withOpacity(.7),
                    labelColor: Colors.white.withOpacity(.4),
                  ),
                  const SizedBox(width: 8),
                  _StatPill(
                    value: '$rate%',
                    label: 'Rate',
                    bg: const Color(0xFFF5A623).withOpacity(.15),
                    border: const Color(0xFFF5A623).withOpacity(.3),
                    valColor: K.g3,
                    labelColor: Colors.white.withOpacity(.55),
                  ),
                ]),
              ],
            ),
          ),
          // ===== Date range chips =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: K.white,
              border: Border(bottom: BorderSide(color: K.bd)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: Text('RANGE:',
                          style: ff(size: rem(.54), w: FontWeight.w700, color: K.ink4, ls: .4)),
                    ),
                    _rangeChip('All time', 'all'),
                    _rangeChip('Last 7 days', '7d'),
                    _rangeChip('Last 30 days', '30d'),
                    _rangeChip('Last 3 months', '3mo'),
                    _rangeChip('This year', 'yr'),
                    _customChip(),
                  ]),
                ),
                if (_customShown) ...[
                  const SizedBox(height: 9),
                  Container(
                    padding: const EdgeInsets.only(top: 9),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: K.bd)),
                    ),
                    child: Row(children: [
                      Text('From', style: ff(size: rem(.56), w: FontWeight.w600, color: K.ink4)),
                      const SizedBox(width: 7),
                      Expanded(child: _dateField(_customFrom, (d) => setState(() => _customFrom = d))),
                      const SizedBox(width: 7),
                      Text('To', style: ff(size: rem(.56), w: FontWeight.w600, color: K.ink4)),
                      const SizedBox(width: 7),
                      Expanded(child: _dateField(_customTo, (d) => setState(() => _customTo = d))),
                    ]),
                  ),
                ],
              ],
            ),
          ),
          // ===== Status filter tabs =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: K.white,
              border: Border(bottom: BorderSide(color: K.bd)),
            ),
            child: Row(children: [
              _filterTab('All', 'all'),
              const SizedBox(width: 7),
              _filterTab('Attended', 'done'),
              const SizedBox(width: 7),
              _filterTab('Missed', 'miss'),
              const Spacer(),
              Text('${data.length} result${data.length == 1 ? '' : 's'}',
                  style: ff(size: rem(.56), w: FontWeight.w700, color: K.ink4)),
            ]),
          ),
          // ===== List =====
          Sc(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            data.isEmpty ? [_emptyState()] : _buildGroups(data),
          ),
        ],
      ),
    );
  }

  // Range chip (.att-range-chip)
  Widget _rangeChip(String label, String key) {
    final on = _rangeKey == key;
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Press(
        scale: .95,
        onTap: () => setState(() {
          _rangeKey = key;
          _customShown = false;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: on ? K.t6 : K.cream,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: on ? Colors.transparent : K.bd),
          ),
          child: Text(label,
              style: ff(size: rem(.6), w: FontWeight.w700, color: on ? Colors.white : K.ink3)),
        ),
      ),
    );
  }

  Widget _customChip() {
    final on = _rangeKey == 'custom';
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Press(
        scale: .95,
        onTap: () => setState(() {
          if (_customShown) {
            _customShown = false;
            _rangeKey = 'all';
          } else {
            _customShown = true;
            _rangeKey = 'custom';
          }
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: on ? K.t6 : K.cream,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: on ? Colors.transparent : K.bd),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Ico(_icCal, size: 10, stroke: on ? Colors.white : K.ink3, sw: 2),
            const SizedBox(width: 4),
            Text('Custom', style: ff(size: rem(.6), w: FontWeight.w700, color: on ? Colors.white : K.ink3)),
          ]),
        ),
      ),
    );
  }

  Widget _dateField(DateTime? value, ValueChanged<DateTime?> onPick) {
    final label = value == null
        ? 'Pick date'
        : '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? AppData.todayDate,
          firstDate: DateTime(2024),
          lastDate: DateTime(AppData.todayDate.year + 1),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: K.bd2),
        ),
        child: Text(label, style: mono(size: rem(.66), w: FontWeight.w500, color: value == null ? K.ink4 : K.ink)),
      ),
    );
  }

  // Status filter tab
  Widget _filterTab(String label, String key) {
    final on = _filter == key;
    return Press(
      scale: .95,
      onTap: () => setState(() => _filter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: on ? K.t6 : K.cream,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: on ? Colors.transparent : K.bd),
        ),
        child: Text(label, style: ff(size: rem(.6), w: FontWeight.w700, color: on ? Colors.white : K.ink3)),
      ),
    );
  }

  Widget _emptyState() {
    // No check-ins at all → first-run empty state.
    if (_allRecords.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 34),
          child: Column(
            children: [
              Ico(_icFileText, size: 40, stroke: K.ink4, sw: 1.5),
              const SizedBox(height: 10),
              Text('No attendance yet', style: ff(size: rem(.82), w: FontWeight.w700, color: K.ink2)),
              const SizedBox(height: 4),
              Text('Scan a QR at an event to record your first check-in.',
                  textAlign: TextAlign.center, style: ff(size: rem(.66), color: K.ink4, height: 1.5)),
            ],
          ),
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 34),
        child: Column(
          children: [
            Ico(_icFileText, size: 40, stroke: K.ink4, sw: 1.5),
            const SizedBox(height: 10),
            Text('No matches', style: ff(size: rem(.82), w: FontWeight.w700, color: K.ink2)),
            const SizedBox(height: 4),
            Text('Try a different search term, date range, or filter.',
                textAlign: TextAlign.center, style: ff(size: rem(.66), color: K.ink4, height: 1.5)),
            const SizedBox(height: 11),
            Press(
              scale: .95,
              onTap: _resetAll,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(color: K.t6, borderRadius: BorderRadius.circular(18)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Ico(_icRefresh, size: 11, stroke: Colors.white, sw: 2.2),
                  const SizedBox(width: 4),
                  Text('Reset all filters', style: ff(size: rem(.6), w: FontWeight.w700, color: Colors.white)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2-level grouping: community -> editions (mirrors renderAtt)
  List<Widget> _buildGroups(List<_Att> data) {
    final commOrder = <String>[];
    final groups = <String, _Group>{};
    for (final a in data) {
      final c = a.community.isNotEmpty ? a.community : 'Other';
      final ed = a.edition.isNotEmpty ? a.edition : '—';
      if (!groups.containsKey(c)) {
        groups[c] = _Group();
        commOrder.add(c);
      }
      final g = groups[c]!;
      if (!g.editions.containsKey(ed)) {
        g.editions[ed] = _Edition(window: a.window, venue: a.venue);
        g.order.add(ed);
      }
      g.editions[ed]!.items.add(a);
    }

    final widgets = <Widget>[];
    for (final comm in commOrder) {
      final g = groups[comm]!;
      int totalDone = 0, total = 0;
      for (final ed in g.order) {
        totalDone += g.editions[ed]!.items.where((x) => x.status == 'done').length;
        total += g.editions[ed]!.items.length;
      }
      final multi = g.order.length > 1;

      final children = <Widget>[
        // Community-level header
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [K.t9, K.t7]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFF5A623).withOpacity(.25),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Center(child: Ico(_icFlower, size: 15, stroke: K.g2, sw: 1.8)),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(comm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ff(size: rem(.74), w: FontWeight.w800, color: Colors.white)),
                  Text('${g.order.length} edition${g.order.length > 1 ? 's' : ''} attended',
                      style: ff(size: rem(.54), color: Colors.white.withOpacity(.6))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('$totalDone/$total', style: mono(size: rem(.6), w: FontWeight.w700, color: K.g2)),
          ]),
        ),
      ];

      for (final ed in g.order) {
        final grp = g.editions[ed]!;
        final ddone = grp.items.where((x) => x.status == 'done').length;
        // Edition sub-header (only when there is edition/window info to show)
        if (grp.window.isEmpty && ed == '—') {
          // No edition metadata on real check-ins → skip the sub-header.
        } else if (multi) {
          children.add(Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 0, 7),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: K.g1,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: K.g2),
            ),
            child: Row(children: [
              Container(width: 5, height: 5, decoration: const BoxDecoration(color: K.g4, shape: BoxShape.circle)),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$ed · ${grp.venue}', style: ff(size: rem(.62), w: FontWeight.w700, color: K.g5)),
                    Opacity(
                        opacity: .85,
                        child: Text(grp.window, style: ff(size: rem(.5), color: K.g5))),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Text('$ddone/${grp.items.length}', style: mono(size: rem(.54), w: FontWeight.w700, color: K.g5)),
            ]),
          ));
        } else {
          children.add(Container(
            margin: const EdgeInsets.only(bottom: 7),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: K.g1,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: K.g2),
            ),
            child: Row(children: [
              Ico(_icCal, size: 11, stroke: K.g5, sw: 1.9),
              const SizedBox(width: 7),
              Text(grp.window, style: ff(size: rem(.58), w: FontWeight.w700, color: K.g5)),
            ]),
          ));
        }

        for (final a in grp.items) {
          children.add(_AttCard(a, multi: multi));
        }
      }

      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      ));
    }
    return widgets;
  }
}

class _Group {
  final Map<String, _Edition> editions = {};
  final List<String> order = [];
}

class _Edition {
  final String window;
  final String venue;
  final List<_Att> items = [];
  _Edition({required this.window, required this.venue});
}

// Attendance item card
class _AttCard extends StatelessWidget {
  final _Att a;
  final bool multi;
  const _AttCard(this.a, {required this.multi});
  @override
  Widget build(BuildContext context) {
    final done = a.status == 'done';
    return Container(
      margin: EdgeInsets.fromLTRB(multi ? 22 : 0, 0, 0, 7),
      decoration: BoxDecoration(
        color: K.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: done ? const Color(0xFFBBF7D0) : K.bd, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // icon box
            Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: done
                      ? const [Color(0xFF16A34A), Color(0xFF15803D)]
                      : const [Color(0xFFE5E7EB), Color(0xFFD1D5DB)],
                ),
                borderRadius: BorderRadius.circular(11),
                boxShadow: done
                    ? [BoxShadow(color: const Color(0xFF16A34A).withOpacity(.35), blurRadius: 10, offset: const Offset(0, 3))]
                    : null,
              ),
              child: Center(
                child: done
                    ? Ico(_icCheck, size: 18, stroke: Colors.white, sw: 2.8)
                    : Ico(_icXCircle, size: 16, stroke: const Color(0xFF9CA3AF), sw: 2.4),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(a.ev, style: ff(size: rem(.78), w: FontWeight.w700, color: K.ink, height: 1.3)),
                      ),
                      const SizedBox(width: 6),
                      _badge(done),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(children: [
                    Ico(_icCal, size: 9, stroke: K.ink4, sw: 1.8),
                    const SizedBox(width: 3),
                    Text(a.date, style: ff(size: rem(.58), color: K.ink3)),
                    const SizedBox(width: 8),
                    Ico(_icVenue, size: 9, stroke: K.ink4, sw: 1.8),
                    const SizedBox(width: 3),
                    Flexible(child: Text(a.venue, style: ff(size: rem(.58), color: K.ink3))),
                  ]),
                  // extra
                  if (done && a.time.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withOpacity(.1),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Ico(_icClock, size: 9, stroke: K.ok, sw: 2),
                        const SizedBox(width: 3),
                        Text(a.time, style: mono(size: rem(.54), w: FontWeight.w700, color: K.ok)),
                      ]),
                    ),
                  ] else if (!done) ...[
                    const SizedBox(height: 5),
                    Text('QR was not scanned', style: ff(size: rem(.56), color: const Color(0xFF9CA3AF))),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(bool done) {
    if (done) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Ico(_icCheck, size: 9, stroke: const Color(0xFF15803D), sw: 2.8),
          const SizedBox(width: 4),
          Text('Attended', style: ff(size: rem(.58), w: FontWeight.w800, color: const Color(0xFF15803D))),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Ico(_icXCircle, size: 9, stroke: const Color(0xFF9CA3AF), sw: 2.4),
        const SizedBox(width: 4),
        Text('Missed', style: ff(size: rem(.58), w: FontWeight.w800, color: const Color(0xFF6B7280))),
      ]),
    );
  }
}

// Summary stat pill (header)
class _StatPill extends StatelessWidget {
  final String value, label;
  final Color bg, border, valColor, labelColor;
  const _StatPill({
    required this.value,
    required this.label,
    required this.bg,
    required this.border,
    required this.valColor,
    required this.labelColor,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Text(value, style: mono(size: rem(1.15), w: FontWeight.w800, color: valColor)),
            const SizedBox(height: 1),
            Text(label, style: ff(size: rem(.5), color: labelColor)),
          ],
        ),
      ),
    );
  }
}
