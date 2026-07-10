import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

const _youtube =
    '<path d="M22.54 6.42a2.78 2.78 0 0 0-1.94-2C18.88 4 12 4 12 4s-6.88 0-8.6.46a2.78 2.78 0 0 0-1.94 2A29 29 0 0 0 1 11.75a29 29 0 0 0 .46 5.33A2.78 2.78 0 0 0 3.4 19c1.72.46 8.6.46 8.6.46s6.88 0 8.6-.46a2.78 2.78 0 0 0 1.94-2 29 29 0 0 0 .46-5.25 29 29 0 0 0-.46-5.33z"/><polygon points="9.75 15.02 15.5 11.75 9.75 8.48 9.75 15.02"/>';
const _imgPlaceholder =
    '<rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/>';
const _qr =
    '<rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><line x1="14" y1="14" x2="14" y2="14.01"/><line x1="21" y1="14" x2="21" y2="14.01"/><line x1="14" y1="21" x2="14" y2="21.01"/><line x1="21" y1="21" x2="21" y2="21.01"/><line x1="17.5" y1="17.5" x2="17.5" y2="17.51"/>';
const _users =
    '<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/>';
const _support =
    '<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>';

const _MONTHS_L = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];
const _MONTHS_S = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _DAYS_S = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

DateTime? _iso(String s) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(s);
  if (m == null) return null;
  return DateTime(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
}

String _fmtDate(String iso) {
  final d = _iso(iso);
  if (d == null) return iso;
  return '${_DAYS_S[d.weekday % 7]}, ${d.day} ${_MONTHS_L[d.month - 1]} ${d.year}';
}

String _fmtShort(String iso) {
  final d = _iso(iso);
  if (d == null) return iso;
  return '${d.day} ${_MONTHS_S[d.month - 1]} ${d.year}';
}

class S12 extends StatelessWidget {
  const S12({super.key});

  @override
  Widget build(BuildContext context) {
    final p = AppData.I.selectedProgram;
    if (p == null) return _empty();

    final title = '${p['title'] ?? 'Programme'}';
    final comm = '${p['communityName'] ?? ''}';
    final venue = '${p['venue'] ?? ''}';
    final area = '${p['area'] ?? ''}';
    final date = '${p['date'] ?? ''}';
    final time = '${p['time'] ?? ''}';
    final desc = '${p['description'] ?? ''}';
    final speaker = '${p['speaker'] ?? ''}'.trim();
    final status = '${p['status'] ?? 'scheduled'}'.toLowerCase();
    final youtube = '${p['youtube'] ?? ''}'.trim();

    // Community edition context (for the "Day X of N" festival pill + card).
    final c = comm.isEmpty ? null : AppData.I.communityByName(comm);
    final edStart = '${c?['editionStart'] ?? ''}';
    final edEnd = '${c?['editionEnd'] ?? ''}';
    final edLabel = '${c?['editionLabel'] ?? ''}'.trim();
    final helpline = '${c?['helpline'] ?? ''}'.trim();
    final sd = _iso(edStart), ed = _iso(edEnd), pd = _iso(date);
    int dayNum = 0, dayTotal = 0;
    if (sd != null && ed != null) {
      dayTotal = ed.difference(sd).inDays + 1;
      if (pd != null) dayNum = pd.difference(sd).inDays + 1;
    }
    final hasDay = dayNum >= 1 && dayTotal >= 1 && dayNum <= dayTotal;

    // Host-uploaded event gallery (live). Empty => section hidden.
    final gallery = <String>[];
    final g = p['gallery'] ?? p['photos'];
    if (g is List) {
      for (final e in g) {
        final s = '$e'.trim();
        if (s.isNotEmpty) gallery.add(s);
      }
    }

    return Container(
      color: K.white,
      child: Column(
        children: [
          // ── Dark header (hero) ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.7, -1),
                end: Alignment(0.7, 1),
                colors: [K.t9, K.t7, K.t5],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Press(
                      dx: -3,
                      onTap: () => go('s11'),
                      child: Ico(P.arrowLeft, size: 18, stroke: Colors.white, sw: 2.2),
                    ),
                    Row(
                      children: [
                        _hdrIcon(P.calendar, 15, () => go('s10')),
                        const SizedBox(width: 7),
                        _hdrIcon(P.bookmark, 15, () => go('s14')),
                        const SizedBox(width: 7),
                        _hdrIcon(P.share, 15, () => go('s19')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: fd(size: rem(1.3), w: FontWeight.w800, color: Colors.white, height: 1.2)),
                          if (venue.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(venue,
                                style: ff(size: rem(.7), color: Colors.white.withOpacity(.55))),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _statusChip(status),
                  ],
                ),
                // Community + Day-of-Festival pills
                if (comm.isNotEmpty || hasDay) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      if (comm.isNotEmpty)
                        Press(
                          scale: .96,
                          onTap: () {
                            AppData.I.selectedCommunity = AppData.I.communityByName(comm);
                            go('s34');
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5A623).withOpacity(.18),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFFDE68A).withOpacity(.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Ico(P.flower, size: 10, stroke: const Color(0xFFFDE68A), sw: 2),
                                const SizedBox(width: 5),
                                Text(comm,
                                    style: ff(size: rem(.56), w: FontWeight.w700, color: const Color(0xFFFDE68A))),
                              ],
                            ),
                          ),
                        ),
                      if (hasDay)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF86EFAC).withOpacity(.18),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFF86EFAC).withOpacity(.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Ico(P.calendar, size: 10, stroke: const Color(0xFF86EFAC), sw: 2),
                              const SizedBox(width: 5),
                              Text('Day $dayNum of $dayTotal',
                                  style: mono(size: rem(.56), w: FontWeight.w700, color: const Color(0xFF86EFAC))),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // ── Body ──
          Sc(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            [
              // Event Gallery (host photos) — only when the host attached images
              if (gallery.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Event Gallery',
                          style: ff(size: rem(.62), w: FontWeight.w700, color: K.ink3, ls: .6)),
                      Text('Added by host', style: ff(size: rem(.58), color: K.ink4)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    height: 84,
                    child: ScrollConfiguration(
                      behavior: const _NoBar(),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        itemCount: gallery.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => _galleryTile(gallery[i]),
                      ),
                    ),
                  ),
                ),
              ],
              // Schedule context: which day in the community festival
              if (hasDay)
                Press(
                  scale: .98,
                  onTap: () => go('s11'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFEF3D5), K.g2],
                      ),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: K.g3),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [K.g3, K.g4],
                            ),
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFFF5A623).withOpacity(.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3)),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('$dayNum',
                                    style: mono(size: rem(.95), w: FontWeight.w800, color: Colors.white, height: 1)),
                                Text('DAY',
                                    style: ff(
                                        size: rem(.42),
                                        w: FontWeight.w700,
                                        color: Colors.white.withOpacity(.85),
                                        ls: .5)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  comm.isEmpty ? 'Day $dayNum of the festival' : 'Day $dayNum of $comm',
                                  style: ff(size: rem(.7), w: FontWeight.w700, color: K.g5, height: 1.3)),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Ico(P.calendar, size: 9, stroke: K.g5, sw: 2),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                        [
                                          if (edStart.isNotEmpty && edEnd.isNotEmpty)
                                            '${_fmtShort(edStart)} – ${_fmtShort(edEnd)}',
                                          'View Schedule',
                                        ].join(' · '),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: ff(size: rem(.58), color: K.g5.withOpacity(.85))),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Ico(P.chevR, size: 13, stroke: K.g5, sw: 2.2),
                      ],
                    ),
                  ),
                ),
              // Time / Location / Speaker info card
              Container(
                decoration: BoxDecoration(
                  color: K.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: K.bd),
                  boxShadow: K.sh,
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _infoRow(
                      icon: P.clock,
                      iconBg: K.t1,
                      iconColor: K.t7,
                      title: time.isNotEmpty ? time : 'Time to be announced',
                      sub: date.isNotEmpty ? _fmtDate(date) : 'Date to be announced',
                      border: venue.isNotEmpty || speaker.isNotEmpty,
                    ),
                    if (venue.isNotEmpty)
                      Press(
                        onTap: () => gmaps(venue, area),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                          decoration: BoxDecoration(
                            border: speaker.isNotEmpty
                                ? Border(bottom: BorderSide(color: K.bd))
                                : null,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(color: K.t1, borderRadius: BorderRadius.circular(9)),
                                  child: Center(child: Ico(P.pin, size: 15, stroke: K.t7, sw: 1.8)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(venue,
                                        style: ff(size: rem(.78), w: FontWeight.w700, color: K.ink)),
                                    if (area.isNotEmpty)
                                      Text(area,
                                          style: ff(size: rem(.62), color: K.ink3, height: 1.5)),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Ico(P.directions, size: 10, stroke: K.t7, sw: 2),
                                        const SizedBox(width: 3),
                                        Text('Get Directions on Google Maps',
                                            style: ff(size: rem(.6), w: FontWeight.w700, color: K.t7)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (speaker.isNotEmpty)
                      _infoRow(
                        icon: _users,
                        iconBg: K.g1,
                        iconColor: K.g5,
                        title: speaker,
                        sub: 'Speaker',
                        border: false,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // About
              if (desc.isNotEmpty)
                CardX(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('About', style: ff(size: rem(.7), w: FontWeight.w700, color: K.ink)),
                      const SizedBox(height: 5),
                      Text(desc, style: ff(size: rem(.72), color: K.ink3, height: 1.55)),
                    ],
                  ),
                ),
              // Set Reminder
              Btn('Set Reminder', kind: BtnKind.s, leading: P.bell, onTap: () => go('s15')),
              // View Programme Live (only when the host attached a stream link)
              if (youtube.isNotEmpty)
                Press(
                  onTap: () => _openYoutube(youtube),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Ico(_youtube, size: 16, stroke: Colors.white, sw: 2),
                        const SizedBox(width: 8),
                        Text('View Programme Live',
                            style: ff(size: rem(.82), w: FontWeight.w700, color: Colors.white)),
                        const SizedBox(width: 2),
                        Text('on YouTube',
                            style: ff(size: rem(.62), w: FontWeight.w600, color: Colors.white.withOpacity(.85))),
                      ],
                    ),
                  ),
                ),
              // QR Attendance card (scan = checked in)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [K.t9, K.t7],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -16,
                      right: -12,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5A623).withOpacity(.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(child: Ico(_qr, size: 24, stroke: Colors.white, sw: 1.7)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Mark Your Attendance',
                                      style: ff(size: rem(.82), w: FontWeight.w700, color: Colors.white)),
                                  const SizedBox(height: 2),
                                  Text("Scan the QR code displayed in the hall — that's it, you're checked in.",
                                      style: ff(size: rem(.62), color: Colors.white.withOpacity(.55), height: 1.4)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Btn('Scan QR to Check In',
                            kind: BtnKind.gold, leading: _qr, margin: 0, onTap: () => go('s31')),
                      ],
                    ),
                  ],
                ),
              ),
              // Automated reminders info
              CardX(
                bg: K.t0,
                border: Border.all(color: K.t1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Ico(P.bell, size: 16, stroke: K.t7, sw: 1.8),
                        const SizedBox(width: 8),
                        Text('Automated Reminders',
                            style: ff(size: rem(.74), w: FontWeight.w700, color: K.ink)),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text("You'll automatically get notified before this programme starts — no setup needed.",
                        style: ff(size: rem(.66), color: K.ink3, height: 1.5)),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: const [
                        Chip2('2 hours before', kind: ChipKind.p),
                        Chip2('1 hour before', kind: ChipKind.p),
                        Chip2('30 min before', kind: ChipKind.p),
                        Chip2('5 min before', kind: ChipKind.p),
                      ],
                    ),
                  ],
                ),
              ),
              // Event Helpline (dialer redirect) — only when the community set one
              if (helpline.isNotEmpty) ...[
                CardX(
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(color: K.ok1, borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Ico(P.phone, size: 19, stroke: K.ok, sw: 1.8)),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Event Helpline',
                                style: ff(size: rem(.78), w: FontWeight.w700, color: K.ink)),
                            Text(helpline,
                                style: mono(size: rem(.66), w: FontWeight.w500, color: K.ink3, ls: .3)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Press(
                        scale: .95,
                        onTap: () => _dial(helpline),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                          decoration: BoxDecoration(color: K.ok, borderRadius: BorderRadius.circular(11)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Ico(P.phone, size: 14, stroke: Colors.white, sw: 2),
                              const SizedBox(width: 6),
                              Text('Call',
                                  style: ff(size: rem(.72), w: FontWeight.w700, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text("Calling redirects to your phone's dialer — no in-app calling.",
                      textAlign: TextAlign.center,
                      style: ff(size: rem(.58), color: K.ink4)),
                ),
              ],
              const SizedBox(height: 8),
              // Directions + Support
              Row(
                children: [
                  Expanded(
                    child: Btn('Directions',
                        kind: BtnKind.s,
                        leading: P.directions,
                        margin: 0,
                        onTap: () => gmaps(venue, area)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Btn('Support',
                        kind: BtnKind.o, leading: _support, margin: 0, onTap: () => go('s18')),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openYoutube(String u) async {
    try {
      await launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication);
    } catch (_) {
      toast('Could not open the live stream link');
    }
  }

  Future<void> _dial(String number) async {
    final tel = number.replaceAll(RegExp(r'[^\d+]'), '');
    if (tel.isEmpty) return;
    try {
      final ok = await launchUrl(Uri.parse('tel:$tel'), mode: LaunchMode.externalApplication);
      if (!ok) toast('Calling $number');
    } catch (_) {
      toast('Calling $number');
    }
  }

  Widget _galleryTile(String label) {
    return Container(
      width: 120,
      height: 84,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [K.t7, K.t5],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 14,
            left: 43,
            child: Ico(_imgPlaceholder, size: 34, stroke: Colors.white.withOpacity(.25), sw: 1.5),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ff(size: rem(.56), w: FontWeight.w600, color: Colors.white.withOpacity(.85))),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    switch (status) {
      case 'live':
        return Chip2('● Live now', kind: ChipKind.g, fontSize: rem(.55));
      case 'done':
      case 'ended':
        return Chip2('Done', kind: ChipKind.p, fontSize: rem(.55));
      case 'postponed':
        return Chip2('Postponed', kind: ChipKind.a, fontSize: rem(.55));
      case 'cancelled':
        return Chip2('Cancelled', kind: ChipKind.e, fontSize: rem(.55));
      default:
        return Chip2('Scheduled', kind: ChipKind.i, fontSize: rem(.55));
    }
  }

  // ── Empty state (opened without a selected programme) ──
  Widget _empty() {
    return Container(
      color: K.cream,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.7, -1),
                end: Alignment(0.7, 1),
                colors: [K.t9, K.t7, K.t5],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Row(
              children: [
                Press(
                  dx: -3,
                  onTap: () => go('s11'),
                  child: Ico(P.arrowLeft, size: 18, stroke: Colors.white, sw: 2.2),
                ),
                const SizedBox(width: 9),
                Text('Programme Detail',
                    style: fd(size: rem(1.05), w: FontWeight.w800, color: Colors.white)),
              ],
            ),
          ),
          Sc(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            [
              Container(
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
                    Ico(P.calendar, size: 38, stroke: K.ink4, sw: 1.5),
                    const SizedBox(height: 10),
                    Text('No programme selected',
                        style: ff(size: rem(.78), w: FontWeight.w700, color: K.ink2)),
                    const SizedBox(height: 4),
                    Text('Pick a programme from the schedule to see its details here.',
                        textAlign: TextAlign.center,
                        style: ff(size: rem(.62), color: K.ink4, height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Btn('Back to Home', kind: BtnKind.p, leading: P.home, margin: 0, onTap: () => go('s03')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _hdrIcon(String icon, double size, VoidCallback onTap) {
    return Press(
      scale: .9,
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.14),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(child: Ico(icon, size: size, stroke: Colors.white, sw: 1.8)),
      ),
    );
  }

  Widget _infoRow({
    required String icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String sub,
    required bool border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        border: border ? Border(bottom: BorderSide(color: K.bd)) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(9)),
            child: Center(child: Ico(icon, size: 15, stroke: iconColor, sw: 1.7)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ff(size: rem(.78), w: FontWeight.w700, color: K.ink)),
                Text(sub, style: ff(size: rem(.62), color: K.ink3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoBar extends ScrollBehavior {
  const _NoBar();
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) => child;
}
