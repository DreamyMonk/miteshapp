import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';
import 's04_search.dart' show s28CtxType, s28CtxQuery;

// Header title per context type (HTML renderS28 `typeLabel`).
const Map<String, String> _titleLabels = {
  'all': 'All Results',
  'community': 'Communities',
  'venue': 'Venues',
  'event': 'Events',
  'area': 'In this area',
  'location': 'In this city',
  'guru': 'Spiritual Guides',
};

// Context-chip label per type (HTML `tlabel`).
const Map<String, String> _ctxLabels = {
  'all': 'All',
  'community': 'Community',
  'venue': 'Venue',
  'event': 'Event',
  'area': 'Area',
  'location': 'Location',
  'guru': 'Guru',
};

// Empty-state noun per type (HTML `s28-empty-type`).
const Map<String, String> _emptyTypes = {
  'community': 'communities',
  'venue': 'venues',
  'event': 'events',
  'area': 'venues in this area',
  'location': 'venues in this city',
  'guru': 'gurus',
  'all': 'matches',
};

// ===== Icon inner-markup (verbatim from HTML svg bodies) =====
const _icSearch = '<circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>';
const _icTrash =
    '<polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>';
const _icPin = '<path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/>';
const _icFlower =
    '<circle cx="12" cy="12" r="2.5"/><path d="M12 9.5c0-2 1.5-3.5 0-5.5-1.5 2-1.5 3.5 0 5.5M12 14.5c0 2-1.5 3.5 0 5.5 1.5-2 1.5-3.5 0-5.5M9.5 12c-2 0-3.5 1.5-5.5 0 2-1.5 3.5-1.5 5.5 0M14.5 12c2 0 3.5-1.5 5.5 0-2 1.5-3.5 1.5-5.5 0"/>';
const _icVenue = '<path d="M3 21h18M5 21V7l8-4v18M19 21V11l-6-3"/>';
const _icCal =
    '<rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>';
const _icUsers = '<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/>';
const _icUsers2 =
    '<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>';
const _icChevrons = '<polyline points="9 18 15 12 9 6"/><polyline points="3 18 9 12 3 6"/>';

// Rotating accent palette (deterministic per card index).
const List<Color> _accent = [
  Color(0xFF7C5CBF),
  Color(0xFFD97706),
  Color(0xFF16A34A),
  Color(0xFF1D4ED8),
  Color(0xFFB45309),
];

const List<List<Color>> _heroGrad = [
  [Color(0xFF3D2582), Color(0xFF7C5CBF)],
  [Color(0xFF92400E), Color(0xFFD97706)],
  [Color(0xFF166534), Color(0xFF16A34A)],
  [Color(0xFF1E3A8A), Color(0xFF1D4ED8)],
  [Color(0xFF7C2D12), Color(0xFFB45309)],
];

const List<String> _mon = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

/// '2026-05-20' + '2026-05-28' → '20 May – 28 May 2026' (empty-safe).
String _fmtWindow(String start, String end) {
  RegExpMatch? p(String s) => RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(s);
  final a = p(start), b = p(end);
  String dm(RegExpMatch m) =>
      '${int.parse(m.group(3)!)} ${_mon[(int.parse(m.group(2)!) - 1).clamp(0, 11)]}';
  String dmy(RegExpMatch m) => '${dm(m)} ${m.group(1)}';
  if (a != null && b != null) return '${dm(a)} – ${dmy(b)}';
  if (a != null) return dmy(a);
  if (b != null) return 'till ${dmy(b)}';
  return '';
}

/// A distinct venue derived from live communities + programmes.
class _Venue {
  final String name;
  final String area;
  final int events; // programmes at this venue
  final String communityName; // community hosting at this venue ('' if none)
  final Map<String, dynamic>? community;
  const _Venue(this.name, this.area, this.events, this.communityName, this.community);
}

class S28 extends StatefulWidget {
  const S28({super.key});
  @override
  State<S28> createState() => _S28State();
}

class _S28State extends State<S28> {
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

  void _onData() {
    if (mounted) setState(() {});
  }

  /// Distinct venues across live communities + programmes.
  List<_Venue> get _venues {
    final comms = AppData.I.liveCommunities;
    final progs = AppData.I.livePrograms;
    final byKey = <String, _Venue>{};

    int eventsAt(String venue) => progs
        .where((p) => '${p['venue'] ?? ''}'.toLowerCase() == venue.toLowerCase())
        .length;

    for (final c in comms) {
      final v = '${c['venue'] ?? ''}'.trim();
      if (v.isEmpty) continue;
      final key = v.toLowerCase();
      if (byKey.containsKey(key)) continue;
      byKey[key] = _Venue(v, '${c['area'] ?? ''}', eventsAt(v), '${c['name'] ?? ''}', c);
    }
    for (final p in progs) {
      final v = '${p['venue'] ?? ''}'.trim();
      if (v.isEmpty) continue;
      final key = v.toLowerCase();
      if (byKey.containsKey(key)) continue;
      // Try to resolve the community hosting at this venue via communityName.
      final commName = '${p['communityName'] ?? ''}';
      final comm = commName.isEmpty ? null : AppData.I.communityByName(commName);
      byKey[key] = _Venue(v, '${p['area'] ?? ''}', eventsAt(v), commName, comm);
    }
    return byKey.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    // Apply the search context set by s04 (type + free-text query).
    final q = s28CtxQuery.toLowerCase().trim();
    final qRaw = s28CtxQuery.trim();
    // HTML renderS28: title = q ? 'Results for "<q>"' : typeLabel
    final title = qRaw.isNotEmpty
        ? 'Results for "$qRaw"'
        : (_titleLabels[s28CtxType] ?? 'All Results');
    // HTML: ctxText = tlabel + (q ? ': '+q : '')
    final tlabel = _ctxLabels[s28CtxType] ?? 'All';
    final chipLabel = qRaw.isNotEmpty ? '$tlabel: $qRaw' : tlabel;
    bool matches(Iterable<String?> fields) =>
        q.isEmpty || fields.any((f) => '${f ?? ''}'.toLowerCase().contains(q));

    final comms = AppData.I.liveCommunities
        .where((c) => matches([c['name'], c['venue'], c['area'], c['city'], c['guru']]))
        .toList();
    final venues =
        _venues.where((v) => matches([v.name, v.area, v.communityName])).toList();
    final totalLen = comms.length + venues.length;
    final empty = totalLen == 0;

    return Container(
      color: K.cream,
      child: Column(
        children: [
          // Custom app bar (.ab) matching HTML markup
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: K.white,
              border: Border(bottom: BorderSide(color: K.bd)),
            ),
            child: Row(
              children: [
                BackBtn(onTap: () => go('s04'), dark: true),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: fd(size: rem(1.06), w: FontWeight.w700, color: K.ink, ls: -.2), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('$totalLen result${totalLen == 1 ? '' : 's'}', style: ff(size: rem(.6), color: K.ink4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Applied context summary row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: K.white,
              border: Border(bottom: BorderSide(color: K.bd)),
            ),
            child: Row(
              children: [
                Text('SEARCHING:',
                    style: ff(size: rem(.52), w: FontWeight.w700, color: K.ink4, ls: .4)),
                const SizedBox(width: 6),
                // ctx chip (.chip cp)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: K.t1,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: K.t2),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Ico(_icSearch, size: 10, stroke: K.t7, sw: 2),
                    const SizedBox(width: 4),
                    Text(chipLabel, style: ff(size: rem(.6), w: FontWeight.w700, color: K.t7)),
                  ]),
                ),
                const SizedBox(width: 6),
                // Change chip
                Press(
                  onTap: () => go('s04'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                    decoration: BoxDecoration(
                      color: K.white,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(color: K.bd),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Ico(_icTrash, size: 10, stroke: K.ink3, sw: 2),
                      const SizedBox(width: 4),
                      Text('Change', style: ff(size: rem(.6), w: FontWeight.w700, color: K.ink3)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          Sc(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            [
              if (empty)
                // Empty state (.s28-empty) — dashed white box, matches HTML markup.
                CustomPaint(
                  painter: _DashedBox(color: K.bd, radius: 14, sw: 1.5),
                  child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 36),
                  decoration: BoxDecoration(
                    color: K.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Ico(_icSearch, size: 40, stroke: K.ink4, sw: 1.5),
                      const SizedBox(height: 11),
                      Text('No matches',
                          textAlign: TextAlign.center,
                          style: ff(size: rem(.82), w: FontWeight.w700, color: K.ink2)),
                      const SizedBox(height: 4),
                      Text(
                          'No ${_emptyTypes[s28CtxType] ?? 'matches'} found'
                          '${qRaw.isNotEmpty ? ' for "$qRaw"' : ''}'
                          '. Try a different category or search term.',
                          textAlign: TextAlign.center,
                          style: ff(size: rem(.62), color: K.ink4, height: 1.5)),
                      const SizedBox(height: 13),
                      Press(
                        onTap: () => go('s04'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: K.t6,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Ico(_icChevrons, size: 11, stroke: Colors.white, sw: 2.2),
                            const SizedBox(width: 5),
                            Text('Refine Search',
                                style: ff(size: rem(.62), w: FontWeight.w700, color: Colors.white)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
                )
              else ...[
                if (comms.isNotEmpty) ...[
                  _SecInline('Communities (${comms.length})', top: 0),
                  ...List.generate(comms.length, (i) => _CommCard(comms[i], i)),
                ],
                if (venues.isNotEmpty) ...[
                  _SecInline('Venues (${venues.length})', top: comms.isNotEmpty ? 10 : 0),
                  ...List.generate(venues.length, (i) => _VenueCard(venues[i], i)),
                ],
              ],
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

// Inline section label (.sec with custom padding)
class _SecInline extends StatelessWidget {
  final String text;
  final double top;
  const _SecInline(this.text, {this.top = 0});
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(0, top, 0, 8),
        child: Text(text.toUpperCase(),
            style: ff(size: rem(.56), w: FontWeight.w700, color: K.ink4, ls: 2)),
      );
}

// Venue card — taps to s06 (venue detail) with the hosting community selected
class _VenueCard extends StatelessWidget {
  final _Venue v;
  final int i;
  const _VenueCard(this.v, this.i);
  @override
  Widget build(BuildContext context) {
    return Press(
      scale: .98,
      onTap: () {
        if (v.community != null) AppData.I.selectedCommunity = v.community;
        go('s06');
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: K.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(
              left: BorderSide(color: _accent[i % _accent.length], width: 4),
              top: BorderSide(color: K.bd),
              right: BorderSide(color: K.bd),
              bottom: BorderSide(color: K.bd)),
          boxShadow: K.sh,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(v.name, style: fd(size: rem(.92), w: FontWeight.w800, color: K.ink, height: 1.2)),
              if (v.area.isNotEmpty) ...[
                const SizedBox(height: 3),
                Row(children: [
                  Ico(_icPin, size: 10, stroke: K.ink4, sw: 2),
                  const SizedBox(width: 4),
                  Flexible(child: Text(v.area, style: ff(size: rem(.62), color: K.ink3))),
                ]),
              ],
              if (v.events > 0 || v.communityName.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  if (v.events > 0)
                    Chip2('${v.events} event${v.events == 1 ? '' : 's'}',
                        kind: ChipKind.g, fontSize: rem(.52)),
                  if (v.communityName.isNotEmpty)
                    Chip2(v.communityName, kind: ChipKind.a, leading: _icFlower, fontSize: rem(.52)),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Rich community card — taps to s34 with the community selected
class _CommCard extends StatelessWidget {
  final Map<String, dynamic> c;
  final int i;
  const _CommCard(this.c, this.i);
  @override
  Widget build(BuildContext context) {
    final grad = _heroGrad[i % _heroGrad.length];
    final acc = _accent[i % _accent.length];
    final name = '${c['name'] ?? ''}';
    final venue = '${c['venue'] ?? ''}';
    final area = '${c['area'] ?? ''}';
    final guru = '${c['guru'] ?? ''}';
    final edition = '${c['editionLabel'] ?? ''}';
    final win = _fmtWindow('${c['editionStart'] ?? ''}', '${c['editionEnd'] ?? ''}');
    final subs = c['subscribers'];
    final subsLabel = subs == null ? '' : '$subs';

    return Press(
      scale: .98,
      onTap: () {
        AppData.I.selectedCommunity = c;
        go('s34');
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 11),
        decoration: BoxDecoration(
          color: K.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: K.bd2, width: 1.5),
          boxShadow: K.sh,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero (logo slide)
              SizedBox(
                height: 118,
                width: double.infinity,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft, end: Alignment.bottomRight, colors: grad),
                      ),
                      child: _logoSlide(),
                    ),
                    // Edition pill top-left
                    if (edition.isNotEmpty)
                      Positioned(
                        top: 9,
                        left: 9,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A).withOpacity(.92),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 6, offset: const Offset(0, 2))],
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                            const SizedBox(width: 5),
                            Text(edition.toUpperCase(),
                                style: ff(size: rem(.52), w: FontWeight.w800, color: Colors.white, ls: .3)),
                          ]),
                        ),
                      ),
                    // Subscriber count chip top-right
                    if (subsLabel.isNotEmpty)
                      Positioned(
                        top: 9,
                        right: 9,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withOpacity(.18)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Ico(_icUsers2, size: 9, stroke: Colors.white, sw: 2.2),
                            const SizedBox(width: 4),
                            Text('$subsLabel subscribers',
                                style: ff(size: rem(.54), w: FontWeight.w700, color: Colors.white)),
                          ]),
                        ),
                      ),
                  ],
                ),
              ),
              // Body
              Container(
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: acc, width: 4)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: fd(size: rem(.95), w: FontWeight.w800, color: K.ink, height: 1.2)),
                    if (win.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Ico(_icCal, size: 10, stroke: K.g5, sw: 2),
                        const SizedBox(width: 3),
                        Flexible(child: Text(win, style: ff(size: rem(.56), w: FontWeight.w700, color: K.g5))),
                      ]),
                    ],
                    const SizedBox(height: 9),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: K.bd)),
                      ),
                      padding: const EdgeInsets.only(top: 9),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (venue.isNotEmpty || area.isNotEmpty)
                            Row(children: [
                              Ico(_icVenue, size: 10, stroke: K.ink4, sw: 1.8),
                              const SizedBox(width: 5),
                              Flexible(
                                  child: Text(
                                      area.isNotEmpty && venue.isNotEmpty
                                          ? '$venue · $area'
                                          : (venue.isNotEmpty ? venue : area),
                                      style: ff(size: rem(.6), color: K.ink3, height: 1.55))),
                            ]),
                          if (guru.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Row(children: [
                              Ico(_icUsers, size: 10, stroke: K.ink4, sw: 1.8),
                              const SizedBox(width: 5),
                              Flexible(child: Text(guru, style: ff(size: rem(.6), color: K.ink3, height: 1.55))),
                            ]),
                          ],
                        ],
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

  Widget _logoSlide() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.2),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: Colors.white.withOpacity(.3)),
              ),
              child: Center(child: Ico(_icFlower, size: 24, stroke: Colors.white, sw: 1.5)),
            ),
            const SizedBox(height: 6),
            Text('COMMUNITY LOGO',
                style: ff(size: rem(.5), w: FontWeight.w700, color: Colors.white.withOpacity(.75), ls: .5)),
          ],
        ),
      );
}

/// Dashed rounded-rect border (CSS `border:1.5px dashed`).
class _DashedBox extends CustomPainter {
  final Color color;
  final double radius;
  final double sw;
  const _DashedBox({required this.color, this.radius = 14, this.sw = 1.5});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw;
    final rrect = RRect.fromRectAndRadius(
        Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    const dash = 5.0, gap = 4.0;
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(
            metric.extractPath(d, (d + dash).clamp(0, metric.length)), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBox old) =>
      old.color != color || old.radius != radius || old.sw != sw;
}
