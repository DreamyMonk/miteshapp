import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

// ── Live search index item (built from Firestore data) ──────────────────────
class _SItem {
  final String n;
  final String type;
  final String sub;
  final String ic;
  final Map<String, dynamic>? community; // for community/venue/guru items
  final Map<String, dynamic>? program; // for event items
  const _SItem(this.n, this.type, this.sub, this.ic, {this.community, this.program});
}

// SI icon paths (inner svg markup, verbatim)
const Map<String, String> _si = {
  'venue': '<path d="M3 21h18M5 21V7l8-4v18M19 21V11l-6-3"/>',
  'flower':
      '<circle cx="12" cy="12" r="2.5"/><path d="M12 9.5c0-2 1.5-3.5 0-5.5-1.5 2-1.5 3.5 0 5.5M12 14.5c0 2-1.5 3.5 0 5.5 1.5-2 1.5-3.5 0-5.5M9.5 12c-2 0-3.5 1.5-5.5 0 2-1.5 3.5-1.5 5.5 0M14.5 12c2 0 3.5-1.5 5.5 0-2 1.5-3.5 1.5-5.5 0"/>',
  'pin': '<path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/>',
  'guru': '<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/>',
  'event':
      '<rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>',
};

// catColor (area resolves to #5B3E9E per JS .replace)
const Map<String, Color> _catColor = {
  'community': Color(0xFF7C5CBF),
  'venue': Color(0xFF5B3E9E),
  'location': Color(0xFF1D4ED8),
  'area': Color(0xFF5B3E9E),
  'guru': Color(0xFFD97706),
  'event': Color(0xFF16A34A),
};

const Map<String, String> _placeholders = {
  'all': 'Type then tap Search...',
  'community': 'Type community name...',
  'venue': 'Type venue name...',
  'location': 'Type city name...',
  'guru': 'Type guru / speaker name...',
  'event': 'Type event name...',
  'area': 'Type area name...',
};

const List<List<String>> _cats = [
  ['all', 'All'],
  ['community', 'Community'],
  ['venue', 'Venue'],
  ['location', 'Location'],
  ['guru', 'Guru / Speaker'],
  ['event', 'Event'],
  ['area', 'Area'],
];

// setS28Context equivalent — keep it simple (top-level state).
String s28CtxType = 'all';
String s28CtxQuery = '';
void setS28Context(String type, String query) {
  s28CtxType = type;
  s28CtxQuery = query;
}

const _srchIcon =
    '<circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>';
const _hotIcon =
    '<path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.153.433-2.294 1-3a2.5 2.5 0 0 0 2.5 2.5z"/>';
// arrow-up-right (recent search row trailing icon, verbatim from HTML)
const _upRightIcon =
    '<line x1="7" y1="17" x2="17" y2="7"/><polyline points="7 7 17 7 17 17"/>';

class S04 extends StatefulWidget {
  const S04({super.key});
  @override
  State<S04> createState() => _S04State();
}

class _S04State extends State<S04> {
  final _ctrl = TextEditingController();
  String _cat = 'all';
  String _query = '';

  @override
  void initState() {
    super.initState();
    AppData.I.addListener(_onData);
  }

  @override
  void dispose() {
    AppData.I.removeListener(_onData);
    _ctrl.dispose();
    super.dispose();
  }

  void _onData() {
    if (mounted) setState(() {});
  }

  void _pickCat(String c) {
    setState(() => _cat = c);
  }

  void _submit() {
    final v = _ctrl.text.trim();
    if (v.isEmpty && _cat == 'all') {
      toast('Type a search term or pick a category');
      return;
    }
    setS28Context(_cat == 'all' ? 'all' : _cat, v);
    go('s28');
  }

  void _clear() {
    _ctrl.clear();
    setState(() => _query = '');
  }

  // ── Live search index (built from Firestore communities + programmes) ──
  List<_SItem> get _searchIndex {
    final items = <_SItem>[];
    final seen = <String>{};
    void add(_SItem it) {
      if (it.n.trim().isEmpty) return;
      if (seen.add('${it.n.toLowerCase()}|${it.type}')) items.add(it);
    }

    for (final c in AppData.I.liveCommunities) {
      final name = '${c['name'] ?? ''}';
      final venue = '${c['venue'] ?? ''}';
      final city = '${c['city'] ?? ''}';
      final area = '${c['area'] ?? ''}';
      final guru = '${c['guru'] ?? ''}';
      add(_SItem(
          name,
          'community',
          'Community${city.isNotEmpty ? ' · $city' : ''}',
          'flower',
          community: c));
      add(_SItem(
          venue,
          'venue',
          'Venue${area.isNotEmpty || city.isNotEmpty ? ' · ${[
              if (area.isNotEmpty) area,
              if (city.isNotEmpty) city
            ].join(', ')}' : ''}',
          'venue',
          community: c));
      add(_SItem(city, 'location', 'City', 'pin', community: c));
      add(_SItem(
          area,
          'area',
          city.isNotEmpty ? 'Area in $city' : 'Area',
          'pin',
          community: c));
      add(_SItem(
          guru,
          'guru',
          'Guru / Speaker${name.isNotEmpty ? ' · $name' : ''}',
          'guru',
          community: c));
    }
    for (final p in AppData.I.livePrograms) {
      final title = '${p['title'] ?? ''}';
      final comm = '${p['communityName'] ?? ''}';
      add(_SItem(
          title,
          'event',
          'Event${comm.isNotEmpty ? ' · $comm' : ''}',
          'event',
          program: p));
    }
    return items;
  }

  List<_SItem> get _filtered {
    final q = _query.toLowerCase();
    return _searchIndex.where((s) {
      final matchCat = _cat == 'all' || s.type == _cat;
      final matchTxt =
          s.n.toLowerCase().contains(q) || s.sub.toLowerCase().contains(q);
      return matchCat && matchTxt;
    }).toList();
  }

  void _open(_SItem s) {
    setS28Context(s.type, s.n);
    switch (s.type) {
      case 'community':
      case 'guru':
        if (s.community != null) AppData.I.selectedCommunity = s.community;
        go('s34');
        break;
      case 'venue':
        if (s.community != null) AppData.I.selectedCommunity = s.community;
        go('s06');
        break;
      case 'event':
        if (s.program != null) AppData.I.selectedProgram = s.program;
        go('s12');
        break;
      default:
        go('s28');
    }
  }

  @override
  Widget build(BuildContext context) {
    final typing = _query.isNotEmpty;
    return Container(
      color: K.cream,
      child: Column(
        children: [
          // ── Dark header + smart search ──
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
            decoration: const BoxDecoration(gradient: K.gHeader),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  BackBtn(onTap: () => go('s03'), dark: false),
                  const SizedBox(width: 10),
                  Text('Search',
                      style: fd(size: rem(1.1), w: FontWeight.w800, color: Colors.white)),
                ]),
                const SizedBox(height: 13),
                // Search input
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: K.white,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(.18),
                          blurRadius: 14,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(children: [
                    const SizedBox(width: 13),
                    Ico(_srchIcon, size: 17, stroke: K.t6, sw: 2.2),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        onChanged: (v) => setState(() => _query = v),
                        onSubmitted: (_) => _submit(),
                        style: ff(size: rem(.85), color: K.ink),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: _placeholders[_cat],
                          hintStyle: ff(size: rem(.85), color: K.ink4),
                        ),
                      ),
                    ),
                    if (typing)
                      Press(
                        onTap: _clear,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                              color: K.cream2, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Ico(P.x, size: 11, stroke: K.ink3, sw: 2.4),
                        ),
                      ),
                    const SizedBox(width: 12),
                  ]),
                ),
                const SizedBox(height: 10),
                // Submit button (gold)
                Press(
                  onTap: _submit,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      gradient: K.gGold,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFFF5A623).withOpacity(.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Ico(_srchIcon, size: 14, stroke: Colors.white, sw: 2.4),
                        const SizedBox(width: 6),
                        Text('Search',
                            style: ff(
                                size: rem(.76),
                                w: FontWeight.w800,
                                color: Colors.white,
                                ls: .3)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Category chips ──
          Container(
            color: K.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: const BoxDecoration(
              color: K.white,
              border: Border(bottom: BorderSide(color: K.bd)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final c in _cats) ...[
                    _Scat(label: c[1], on: _cat == c[0], onTap: () => _pickCat(c[0])),
                    if (c != _cats.last) const SizedBox(width: 7),
                  ],
                ],
              ),
            ),
          ),
          // ── Body ──
          Sc(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            [
              if (typing) ..._suggestions() else ..._defaultView(),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  // ── Live suggestions ──
  List<Widget> _suggestions() {
    final f = _filtered;
    if (f.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 24, 14, 24),
          child: Column(
            children: [
              Ico(_srchIcon, size: 34, stroke: K.ink4, sw: 1.6),
              const SizedBox(height: 8),
              Text("No matches for '$_query'",
                  textAlign: TextAlign.center,
                  style: ff(size: rem(.78), w: FontWeight.w700, color: K.ink2)),
              const SizedBox(height: 3),
              Text('Try a community, guru, area or event name',
                  textAlign: TextAlign.center,
                  style: ff(size: rem(.64), color: K.ink4)),
            ],
          ),
        ),
      ];
    }
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 7),
        child: Text('${f.length} result${f.length > 1 ? 's' : ''}'.toUpperCase(),
            style: ff(size: rem(.6), w: FontWeight.w800, color: K.ink3, ls: .5)),
      ),
      for (final s in f) _suggestRow(s),
    ];
  }

  Widget _suggestRow(_SItem s) {
    final col = _catColor[s.type] ?? const Color(0xFF7C5CBF);
    return Press(
      onTap: () => _open(s),
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: K.white,
          border: Border.all(color: K.bd),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration:
                BoxDecoration(color: col, borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Ico(_si[s.ic] ?? '', size: 17, stroke: Colors.white, sw: 1.8),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.n, style: ff(size: rem(.78), w: FontWeight.w700, color: K.ink)),
                Text(s.sub, style: ff(size: rem(.62), color: K.ink3)),
              ],
            ),
          ),
          const SizedBox(width: 11),
          Ico(P.chevR, size: 14, stroke: K.ink4, sw: 2.2),
        ]),
      ),
    );
  }

  // ── Default view: trending (first live communities + programmes) ──
  List<Widget> _defaultView() {
    final comms = AppData.I.liveCommunities;
    final progs = AppData.I.livePrograms;

    if (comms.isEmpty && progs.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 34, 14, 24),
          child: Column(
            children: [
              Ico(_srchIcon, size: 34, stroke: K.ink4, sw: 1.6),
              const SizedBox(height: 8),
              Text('Nothing published yet — check back soon',
                  textAlign: TextAlign.center,
                  style: ff(size: rem(.78), w: FontWeight.w700, color: K.ink2)),
              const SizedBox(height: 3),
              Text('Communities and events will appear here once hosts publish them',
                  textAlign: TextAlign.center,
                  style: ff(size: rem(.64), color: K.ink4)),
            ],
          ),
        ),
      ];
    }

    // First 3 items across communities then programmes.
    final trend = <Widget>[];
    for (final c in comms) {
      if (trend.length >= 3) break;
      final area = '${c['area'] ?? ''}';
      final venue = '${c['venue'] ?? ''}';
      trend.add(_trendCard(
        gradient: const LinearGradient(
            colors: [Color(0xFF3D2582), Color(0xFF7C5CBF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        icon: _si['flower']!,
        title: '${c['name'] ?? ''}',
        sub: 'Community${venue.isNotEmpty ? ' · $venue' : ''}${area.isNotEmpty ? ', $area' : ''}',
        hot: trend.isEmpty,
        onTap: () {
          setS28Context('community', '${c['name'] ?? ''}');
          AppData.I.selectedCommunity = c;
          go('s34');
        },
      ));
    }
    for (final p in progs) {
      if (trend.length >= 3) break;
      final venue = '${p['venue'] ?? ''}';
      final area = '${p['area'] ?? ''}';
      trend.add(_trendCard(
        gradient: const LinearGradient(
            colors: [Color(0xFF92400E), Color(0xFFD97706)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        icon: _si['event']!,
        title: '${p['title'] ?? ''}',
        sub: 'Event${venue.isNotEmpty ? ' · $venue' : ''}${area.isNotEmpty ? ', $area' : ''}',
        onTap: () {
          setS28Context('event', '${p['title'] ?? ''}');
          AppData.I.selectedProgram = p;
          go('s12');
        },
      ));
    }

    // ── Recent Searches: derive live rows from published data ──
    final recent = <Widget>[];
    for (final c in comms) {
      if (recent.length >= 2) break;
      final name = '${c['name'] ?? ''}';
      if (name.trim().isEmpty) continue;
      recent.add(_recentRow(
        label: name,
        onTap: () {
          setS28Context('community', name);
          AppData.I.selectedCommunity = c;
          go('s34');
        },
      ));
    }
    for (final c in comms) {
      if (recent.length >= 2) break;
      final area = '${c['area'] ?? ''}';
      if (area.trim().isEmpty) continue;
      recent.add(_recentRow(
        label: '$area area',
        onTap: () {
          setS28Context('area', area);
          go('s28');
        },
      ));
    }

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 2, 0, 8),
        child: Text('Trending Now'.toUpperCase(),
            style: ff(size: rem(.6), w: FontWeight.w800, color: K.ink3, ls: .5)),
      ),
      ...trend,
      if (recent.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Text('Recent Searches'.toUpperCase(),
              style: ff(size: rem(.6), w: FontWeight.w800, color: K.ink3, ls: .5)),
        ),
        ...recent,
      ],
    ];
  }

  // ── Recent search row (.row) ──
  Widget _recentRow({required String label, required VoidCallback onTap}) {
    return Press(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: K.white,
          border: Border.all(color: K.bd),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(children: [
          Ico(P.clock, size: 15, stroke: K.ink4, sw: 1.8),
          const SizedBox(width: 11),
          Expanded(
            child: Text(label,
                style: ff(size: rem(.76), color: K.ink2)),
          ),
          const SizedBox(width: 11),
          Ico(_upRightIcon, size: 13, stroke: K.ink4, sw: 2),
        ]),
      ),
    );
  }

  Widget _trendCard({
    required Gradient gradient,
    required String icon,
    required String title,
    required String sub,
    bool hot = false,
    required VoidCallback onTap,
  }) {
    return Press(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: K.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: K.bd),
          boxShadow: K.sh,
        ),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration:
                BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(11)),
            alignment: Alignment.center,
            child: Ico(icon, size: 20, stroke: Colors.white, sw: 1.7),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ff(size: rem(.78), w: FontWeight.w700, color: K.ink)),
                Text(sub, style: ff(size: rem(.62), color: K.ink3)),
              ],
            ),
          ),
          if (hot) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: K.g1,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Ico(_hotIcon, size: 9, stroke: K.g5, sw: 2),
                const SizedBox(width: 2),
                Text('Hot',
                    style: ff(size: rem(.52), w: FontWeight.w700, color: K.g5)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}

class _Scat extends StatelessWidget {
  final String label;
  final bool on;
  final VoidCallback onTap;
  const _Scat({required this.label, required this.on, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Press(
      scale: .95,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: on ? K.t6 : K.cream,
          border: Border.all(color: on ? K.t6 : K.bd, width: 1.5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: ff(
              size: rem(.68),
              w: FontWeight.w700,
              color: on ? Colors.white : K.ink3),
        ),
      ),
    );
  }
}
