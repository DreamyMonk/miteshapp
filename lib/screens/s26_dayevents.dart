import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

/// Selected real date ('YYYY-MM-DD'). Set by S24 before go('s26').
/// Empty → default to today.
String s26Iso = '';

const _calIcon =
    '<rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>';
const _calPlusIcon =
    '$_calIcon<line x1="12" y1="14" x2="12" y2="18"/><line x1="10" y1="16" x2="14" y2="16"/>';
const _searchIcon =
    '<circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>';
const _plusIcon =
    '<line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>';
const _clockIcon =
    '<circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>';
const _playIcon = '<polygon points="5 3 19 12 5 21 5 3"/>';

const _dNames = [
  'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
];
const _monthsShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

/// Parse s26Iso into a date-only DateTime; default to today when unset/invalid.
DateTime _selectedDate() {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s26Iso);
  if (m == null) return AppData.todayDate;
  return DateTime(
      int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
}

Color _hex(String h, [Color fallback = const Color(0xFF7C5CBF)]) {
  final s = h.replaceAll('#', '');
  if (s.length != 6) return fallback;
  final v = int.tryParse(s, radix: 16);
  return v == null ? fallback : Color(0xFF000000 | v);
}

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

class S26 extends StatefulWidget {
  const S26({super.key});
  @override
  State<S26> createState() => _S26State();
}

class _S26State extends State<S26> {
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

  @override
  Widget build(BuildContext context) {
    final dateObj = _selectedDate();
    final iso = AppData.isoOf(dateObj);
    final day = dateObj.day;
    final programs = AppData.I.liveProgramsForIso(iso);
    final userEvents = AppData.I.eventsForIso(iso);
    final total = programs.length + userEvents.length;

    final dayName = _dNames[dateObj.weekday % 7];
    final monthName = _monthsShort[dateObj.month - 1];

    final String sub;
    if (total == 0) {
      sub = 'No events this day';
    } else {
      final parts = <String>[
        if (programs.isNotEmpty)
          '${programs.length} event${programs.length > 1 ? 's' : ''} from your subscribed communities',
        if (userEvents.isNotEmpty)
          '${userEvents.length} personal event${userEvents.length > 1 ? 's' : ''}',
      ];
      sub = parts.join(' · ');
    }

    return Container(
      color: K.cream,
      child: Column(
        children: [
          // ── Dark header ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
            decoration: const BoxDecoration(gradient: K.gHeader),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BackBtn(onTap: () => go('s24'), dark: false),
                    Press(
                      scale: .9,
                      onTap: () => go('s24'),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.14),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Center(
                            child: Ico(_calIcon,
                                size: 15, stroke: Colors.white, sw: 1.8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('$dayName, $day $monthName',
                    style: fd(
                        size: rem(1.3), w: FontWeight.w800, color: Colors.white)),
                Text(sub,
                    style: ff(
                        size: rem(.64), color: Colors.white.withOpacity(.5))),
              ],
            ),
          ),
          // ── Body ─────────────────────────────────────────────────────
          if (total == 0)
            const _EmptyBody()
          else
            Sc(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              [
                ...programs.map((p) => _ProgramCard(p)),
                ...userEvents.map((e) => _UserEventCard(e)),
                Btn('← Back to Calendar',
                    kind: BtnKind.o, onTap: () => go('s24'), margin: 0),
                const SizedBox(height: 20),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Host programme card (existing card style) ────────────────────────────────
class _ProgramCard extends StatelessWidget {
  final Map<String, dynamic> p;
  const _ProgramCard(this.p);

  @override
  Widget build(BuildContext context) {
    final title = '${p['title'] ?? 'Programme'}';
    final venue = '${p['venue'] ?? ''}';
    final time = '${p['time'] ?? ''}';
    final status = _statusLabel('${p['status'] ?? ''}');
    final isLive = status == 'Live';

    void open() {
      AppData.I.selectedProgram = p;
      go('s12');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: K.white,
        borderRadius: BorderRadius.circular(13),
        border: Border(
          top: BorderSide(color: K.bd),
          right: BorderSide(color: K.bd),
          bottom: BorderSide(color: K.bd),
          left: BorderSide(
              color: isLive ? const Color(0xFFDC2626) : K.g4,
              width: isLive ? 3 : 4),
        ),
        boxShadow: K.sh,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Press(
            scale: .99,
            onTap: open,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: ff(
                                  size: rem(.8),
                                  w: FontWeight.w700,
                                  color: K.ink)),
                          Text(venue,
                              style: ff(size: rem(.62), color: K.ink3)),
                        ],
                      ),
                    ),
                    if (isLive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(17),
                          border:
                              Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                  color: Color(0xFFDC2626),
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 3),
                          Text('LIVE NOW',
                              style: ff(
                                  size: rem(.52),
                                  w: FontWeight.w700,
                                  color: const Color(0xFFDC2626))),
                        ]),
                      )
                    else
                      Chip2(status,
                          kind: status == 'Ended' ? ChipKind.e : ChipKind.a,
                          fontSize: rem(.52)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(children: [
                  Ico(_clockIcon, size: 11, stroke: K.t6, sw: 1.8),
                  const SizedBox(width: 3),
                  Text(time, style: ff(size: rem(.6), color: K.ink3)),
                ]),
              ],
            ),
          ),
          if (isLive) ...[
            const SizedBox(height: 8),
            Press(
              scale: .97,
              onTap: () => go('s13'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFDC2626), Color(0xFF991B1B)]),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Ico(_playIcon, size: 11, stroke: Colors.white, sw: 2.2),
                  const SizedBox(width: 6),
                  Text('Watch Live Stream',
                      style: ff(
                          size: rem(.62),
                          w: FontWeight.w800,
                          color: Colors.white,
                          ls: .3)),
                ]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── User event card ──────────────────────────────────────────────────────────
class _UserEventCard extends StatelessWidget {
  final UserEvent e;
  const _UserEventCard(this.e);

  @override
  Widget build(BuildContext context) {
    final c = _hex(e.colorHex);
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: K.white,
        borderRadius: BorderRadius.circular(13),
        border: Border(
          top: BorderSide(color: K.bd),
          right: BorderSide(color: K.bd),
          bottom: BorderSide(color: K.bd),
          left: BorderSide(color: c, width: 4),
        ),
        boxShadow: K.sh,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.name,
                        style: ff(
                            size: rem(.8), w: FontWeight.w700, color: K.ink)),
                    if (e.loc.isNotEmpty)
                      Text(e.loc, style: ff(size: rem(.62), color: K.ink3)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: c.withOpacity(.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(e.type,
                    style:
                        ff(size: rem(.52), w: FontWeight.w700, color: c)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(children: [
            Ico(_clockIcon, size: 11, stroke: K.t6, sw: 1.8),
            const SizedBox(width: 3),
            Text(e.time, style: ff(size: rem(.6), color: K.ink3)),
          ]),
        ],
      ),
    );
  }
}

// ── Empty-day body (mirrors S27's empty state) ───────────────────────────────
class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    return Sc(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      [
        const SizedBox(height: 30),
        // Big calendar icon w/ gold plus badge
        SizedBox(
          width: 108,
          height: 108,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFEDE6F7), Color(0xFFF7F4FC)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: K.bd2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5C3E9E).withOpacity(.16),
                      blurRadius: 34,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Center(child: Ico(_calIcon, size: 50, stroke: K.t5, sw: 1.5)),
              ),
              Positioned(
                bottom: -7,
                right: -7,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF5A623), Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: K.cream, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF5A623).withOpacity(.42),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                      child: Ico(_plusIcon,
                          size: 16, stroke: Colors.white, sw: 2.5)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('No Events for This Date',
            textAlign: TextAlign.center,
            style: fd(size: rem(1.3), w: FontWeight.w800, color: K.ink)),
        const SizedBox(height: 8),
        Center(
          child: SizedBox(
            width: 270,
            child: Text(
              'There are no programmes from your subscribed communities on this date. Discover more communities or add your own event.',
              textAlign: TextAlign.center,
              style: ff(size: rem(.78), color: K.ink3, height: 1.6),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Btn('Discover Venues',
            kind: BtnKind.p, leading: _searchIcon, onTap: () => go('s04')),
        Btn('Add a Personal Event',
            kind: BtnKind.s,
            leading: _calPlusIcon,
            onTap: () => go('s21'),
            margin: 0),
        const SizedBox(height: 18),
      ],
    );
  }
}
