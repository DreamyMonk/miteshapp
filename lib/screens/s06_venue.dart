import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

// Amenity icons (exact inner markup from the HTML).
const _parking =
    '<rect x="3" y="3" width="18" height="18" rx="2"/><path d="M9 17V7h4a3 3 0 0 1 0 6H9"/>';
const _accessible =
    '<circle cx="16" cy="4" r="1"/><path d="m18 19 1-7-6 1"/><path d="m5 8 3-3 5.5 3-2.36 3.5"/><path d="M4.24 14.5a5 5 0 0 0 6.88 6"/><path d="M13.76 17.5a5 5 0 0 0-3.88-7.83"/>';

const _mon = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

DateTime? _d(String iso) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(iso);
  if (m == null) return null;
  return DateTime(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
}

String _dm(DateTime? d) => d == null ? '' : '${d.day} ${_mon[d.month - 1]}';
String _dmy(DateTime? d) => d == null ? '' : '${d.day} ${_mon[d.month - 1]} ${d.year}';

String _s(Map<String, dynamic>? c, String k) => c == null ? '' : '${c[k] ?? ''}';

String _amenIcon(String a) {
  final l = a.toLowerCase();
  if (l.contains('park')) return _parking;
  if (l.contains('access') || l.contains('wheel')) return _accessible;
  if (l.contains('contact') || l.contains('phone') || l.contains('help')) return P.phone;
  return P.check;
}

class S06 extends StatefulWidget {
  const S06({super.key});
  @override
  State<S06> createState() => _S06State();
}

class _S06State extends State<S06> {
  DateTime get _today => AppData.todayDate; // real device date

  @override
  void initState() {
    super.initState();
    AppData.I.addListener(_onData);
  }

  void _onData() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppData.I.removeListener(_onData);
    super.dispose();
  }

  Map<String, dynamic>? get _community =>
      AppData.I.selectedCommunity ??
      (AppData.I.liveCommunities.isNotEmpty ? AppData.I.liveCommunities.first : null);

  @override
  Widget build(BuildContext context) {
    final c = _community;
    final name = _s(c, 'name');
    final venue = _s(c, 'venue');
    final area = _s(c, 'area');
    final venueAddr = _s(c, 'venueAddr');
    final editionLabel = _s(c, 'editionLabel');
    final editionStatus = _s(c, 'editionStatus');
    final start = _d(_s(c, 'editionStart'));
    final end = _d(_s(c, 'editionEnd'));
    final amenities =
        (c?['amenities'] is List) ? (c!['amenities'] as List).map((e) => '$e').toList() : <String>[];
    final todays = name.isEmpty
        ? <Map<String, dynamic>>[]
        : AppData.I
            .programsOfCommunity(name)
            .where((p) => '${p['date'] ?? ''}'.startsWith(AppData.todayIso))
            .toList();

    final pillParts = <String>[
      if (editionLabel.isNotEmpty) editionLabel.toUpperCase(),
      (editionStatus.isEmpty ? 'ACTIVE' : editionStatus.toUpperCase()),
    ];
    final atLine = [
      if (venue.isNotEmpty) venue,
      if (area.isNotEmpty) area,
    ].join(' · ');

    final daysLeft = end == null ? -1 : end.difference(_today).inDays;
    final window = (start == null || end == null) ? '' : '${_dm(start)} — ${_dmy(end)}';
    final windowLine = [
      if (window.isNotEmpty) window,
      if (daysLeft >= 0) '$daysLeft days remaining',
    ].join(' · ');

    return Container(
      color: K.cream,
      child: Column(
        children: [
          // Hero band (130px purple gradient)
          SizedBox(
            height: 130,
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [K.t7, K.t5], // #3D2582 -> #7C5CBF
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Decorative blob
                  Positioned(
                    top: -20,
                    right: -10,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF5A623).withOpacity(.1),
                      ),
                    ),
                  ),
                  // Top row: back + calendar icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BackBtn(onTap: () => go('s05'), dark: false),
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
                          child: Center(
                            child: Ico(P.calendar, size: 14, stroke: Colors.white, sw: 1.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Bottom overlay
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Live pill
                        if (c != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16A34A).withOpacity(.85),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(pillParts.join(' · '),
                                    style: ff(
                                        size: rem(.52),
                                        w: FontWeight.w800,
                                        color: Colors.white,
                                        ls: .3)),
                              ],
                            ),
                          ),
                        Text(c == null ? 'Community' : name,
                            style: fd(
                                size: rem(1.25),
                                w: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Ico(P.venue, size: 9, stroke: Colors.white.withOpacity(.65), sw: 1.8),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                  c == null
                                      ? 'No live community yet'
                                      : (atLine.isEmpty ? 'Venue to be announced' : 'Currently at $atLine'),
                                  style: ff(
                                      size: rem(.58),
                                      color: Colors.white.withOpacity(.65))),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Scroll body
          Sc(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            [
              if (c == null)
                CardX(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Column(
                      children: [
                        Ico(P.flower, size: 26, stroke: K.ink4, sw: 1.6),
                        const SizedBox(height: 10),
                        Text('No community published yet',
                            style: ff(size: rem(.72), w: FontWeight.w700, color: K.ink2)),
                        const SizedBox(height: 4),
                        Text(
                            'Once a host publishes their community profile, its live venue page will appear here.',
                            textAlign: TextAlign.center,
                            style: ff(size: rem(.6), color: K.ink3, height: 1.5)),
                      ],
                    ),
                  ),
                )
              else ...[
                Btn('Subscribe to $name', kind: BtnKind.p, leading: P.check, onTap: () {
                  AppData.I.setSubscribed(name, true, cid: _s(c, 'id'));
                  go('s07');
                }),
                Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 12),
                  child: Transform.translate(
                    offset: const Offset(0, -9),
                    child: Text(
                      'Follow the community · auto-notified for every edition at any venue',
                      textAlign: TextAlign.center,
                      style: ff(size: rem(.55), color: K.ink4, height: 1.5),
                    ),
                  ),
                ),
                // Gold edition card
                Press(
                  scale: .98,
                  onTap: () {
                    AppData.I.selectedCommunity = c;
                    go('s34');
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [K.g1, K.g2], // #FEF3D5 -> #FDE68A
                      ),
                      border: Border.all(color: K.g3),
                      borderRadius: BorderRadius.circular(13),
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
                              colors: [K.g3, K.g4], // #F5A623 -> #D97706
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFFF5A623).withOpacity(.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3))
                            ],
                          ),
                          child: Center(
                              child: Ico(P.flower, size: 17, stroke: Colors.white, sw: 1.8)),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(name,
                                  style: ff(
                                      size: rem(.7), w: FontWeight.w700, color: K.g5)),
                              const SizedBox(height: 1),
                              Row(
                                children: [
                                  Ico(P.calendar, size: 9, stroke: K.g5, sw: 2),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      windowLine.isEmpty ? 'Edition dates to be announced' : windowLine,
                                      style: ff(size: rem(.58), color: K.g5.withOpacity(.85)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Ico(P.chevR, size: 13, stroke: K.g5, sw: 2.2),
                      ],
                    ),
                  ),
                ),
                // Amenity chips
                if (amenities.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final a in amenities)
                          Chip2(a, kind: ChipKind.p, leading: _amenIcon(a), fontSize: rem(.6)),
                      ],
                    ),
                  ),
                // Today's Programmes header
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: K.ok),
                      ),
                      const SizedBox(width: 6),
                      Text("Today's Programmes",
                          style: ff(size: rem(.62), w: FontWeight.w700, color: K.ink3, ls: .5)),
                    ],
                  ),
                ),
                if (todays.isEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.fromLTRB(13, 14, 13, 14),
                    decoration: BoxDecoration(
                      color: K.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: K.bd),
                    ),
                    child: Text('No programmes published for today yet.',
                        textAlign: TextAlign.center,
                        style: ff(size: rem(.62), color: K.ink3)),
                  )
                else
                  for (var i = 0; i < todays.length; i++)
                    _ProgCard(
                      title: '${todays[i]['title'] ?? 'Programme'}',
                      time: '${todays[i]['time'] ?? ''}',
                      chip: _statusChip(todays[i]),
                      // HTML: cards with a Live/Soon status show the bottom clock
                      // row; the time-as-chip card (Community Lunch) omits it.
                      showClock: _hasStatusChip(todays[i]),
                      accent: const [K.t6, K.g4, K.inC][i % 3],
                      onTap: () {
                        AppData.I.selectedProgram = todays[i];
                        go('s12');
                      },
                    ),
                if (venue.isNotEmpty)
                  Btn('Get Directions on Google Maps',
                      kind: BtnKind.s,
                      leading: P.directions,
                      onTap: () => gmaps(venue, venueAddr)),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  // True when the programme has a real Live/Soon status (distinct from the
  // time-as-chip fallback). Mirrors the HTML: only these cards show the clock row.
  bool _hasStatusChip(Map<String, dynamic> p) {
    final st = '${p['status'] ?? ''}'.toLowerCase();
    return st == 'live' || st == 'soon';
  }

  Widget _statusChip(Map<String, dynamic> p) {
    final st = '${p['status'] ?? ''}'.toLowerCase();
    if (st == 'live') return const Chip2('● Live', kind: ChipKind.g, fontSize: 8.32);
    if (st == 'soon') return const Chip2('Soon', kind: ChipKind.a, fontSize: 8.32);
    final t = '${p['time'] ?? ''}';
    return Chip2(t.isEmpty ? 'Today' : t, kind: ChipKind.i, fontSize: 8.32);
  }
}

class _ProgCard extends StatelessWidget {
  final String title;
  final String time;
  final Widget chip;
  final Color accent;
  final bool showClock;
  final VoidCallback onTap;
  const _ProgCard({
    required this.title,
    required this.time,
    required this.chip,
    required this.accent,
    required this.onTap,
    this.showClock = true,
  });

  @override
  Widget build(BuildContext context) {
    return Press(
      scale: .98,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
        decoration: BoxDecoration(
          color: K.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: accent, width: 3)),
          boxShadow: K.sh,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: ff(size: rem(.78), w: FontWeight.w700, color: K.ink)),
                      Text(time, style: ff(size: rem(.62), color: K.ink3)),
                    ],
                  ),
                ),
                chip,
              ],
            ),
            if (showClock) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Ico(P.clock, size: 11, stroke: K.t6, sw: 1.8),
                  const SizedBox(width: 4),
                  Text(time, style: ff(size: rem(.6), color: K.ink3)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
