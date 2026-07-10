import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

const _flower =
    '<circle cx="12" cy="12" r="2.5"/><path d="M12 9.5c0-2 1.5-3.5 0-5.5-1.5 2-1.5 3.5 0 5.5M12 14.5c0 2-1.5 3.5 0 5.5 1.5-2 1.5-3.5 0-5.5M9.5 12c-2 0-3.5 1.5-5.5 0 2-1.5 3.5-1.5 5.5 0M14.5 12c2 0 3.5-1.5 5.5 0-2 1.5-3.5 1.5-5.5 0"/>';
const _calIcon =
    '<rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>';
const _venueIcon = '<path d="M3 21h18M5 21V7l8-4v18M19 21V11l-6-3"/>';
const _guruIcon =
    '<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/>';
// recurrence "refresh" loop icon (matches HTML richCommCard)
const _recurIcon =
    '<polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/>';

// Rotating accent palette (accent color + logo-slide gradient per card index).
class _Accent {
  final Color c;
  final Color g1, g2;
  const _Accent(this.c, this.g1, this.g2);
}

const List<_Accent> _accents = [
  _Accent(Color(0xFF7C5CBF), Color(0xFF3D2582), Color(0xFF7C5CBF)),
  _Accent(Color(0xFFD97706), Color(0xFF92400E), Color(0xFFD97706)),
  _Accent(Color(0xFF16A34A), Color(0xFF166534), Color(0xFF16A34A)),
  _Accent(Color(0xFF1D4ED8), Color(0xFF1E3A8A), Color(0xFF1D4ED8)),
  _Accent(Color(0xFFB45309), Color(0xFF7C2D12), Color(0xFFB45309)),
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

class S05 extends StatefulWidget {
  const S05({super.key});
  @override
  State<S05> createState() => _S05State();
}

class _S05State extends State<S05> {
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
    final comms = AppData.I.liveCommunities;
    return Container(
      color: K.cream,
      child: Column(
        children: [
          AppBarX(
            title: 'Active Communities',
            sub:
                '${comms.length} ${comms.length == 1 ? 'community' : 'communities'} currently hosting',
            back: 's04',
            onBack: () => go('s04'),
          ),
          Sc(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            [
              if (comms.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 34, 14, 24),
                  child: Column(
                    children: [
                      Ico(_flower, size: 34, stroke: K.ink4, sw: 1.6),
                      const SizedBox(height: 8),
                      Text('Nothing published yet — check back soon',
                          textAlign: TextAlign.center,
                          style: ff(size: rem(.78), w: FontWeight.w700, color: K.ink2)),
                      const SizedBox(height: 3),
                      Text('Active communities will appear here once hosts publish them',
                          textAlign: TextAlign.center,
                          style: ff(size: rem(.64), color: K.ink4)),
                    ],
                  ),
                )
              else
                for (int i = 0; i < comms.length; i++) _CommCard(comms[i], i),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommCard extends StatelessWidget {
  final Map<String, dynamic> c;
  final int i;
  const _CommCard(this.c, this.i);

  @override
  Widget build(BuildContext context) {
    final acc = _accents[i % _accents.length];
    final name = '${c['name'] ?? ''}';
    final venue = '${c['venue'] ?? ''}';
    final area = '${c['area'] ?? ''}';
    final guru = '${c['guru'] ?? ''}';
    final edition = '${c['editionLabel'] ?? ''}';
    final win = _fmtWindow('${c['editionStart'] ?? ''}', '${c['editionEnd'] ?? ''}');
    final recurrence = '${c['recurrence'] ?? ''}';
    // "Today count" chip = number of programmes this community is running today.
    final count = AppData.I.programsOfCommunity(name).length;
    final countLabel = count > 0 ? '$count' : '';

    return Press(
      onTap: () {
        AppData.I.selectedCommunity = c;
        go('s34');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: K.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: K.bd, width: 1.5),
          boxShadow: K.sh,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── hero (logo slide) ──
            SizedBox(
              height: 118,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [acc.g1, acc.g2],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                      ),
                    ),
                  ),
                  const Positioned.fill(child: _LogoSlide()),
                  // edition pill top-left
                  if (edition.isNotEmpty)
                    Positioned(
                      top: 9,
                      left: 9,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A).withOpacity(.92),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          Text(edition.toUpperCase(),
                              style: ff(
                                  size: rem(.52),
                                  w: FontWeight.w800,
                                  color: Colors.white,
                                  ls: .3)),
                        ]),
                      ),
                    ),
                  // today programme-count chip top-right (calendar icon + count)
                  if (countLabel.isNotEmpty)
                    Positioned(
                      top: 9,
                      right: 9,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.5),
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: Colors.white.withOpacity(.18)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Ico(_calIcon, size: 9, stroke: Colors.white, sw: 2.2),
                          const SizedBox(width: 4),
                          Text(countLabel,
                              style: ff(
                                  size: rem(.54),
                                  w: FontWeight.w700,
                                  color: Colors.white)),
                        ]),
                      ),
                    ),
                ],
              ),
            ),
            // ── body (left color accent) ──
            Container(
              decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: acc.c, width: 4))),
              padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: fd(
                          size: rem(.95),
                          w: FontWeight.w800,
                          color: K.ink,
                          height: 1.2)),
                  // booking window (gold) + recurrence (purple), flex-wrap
                  if (win.isNotEmpty || recurrence.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 7,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (win.isNotEmpty)
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Ico(_calIcon, size: 10, stroke: K.g5, sw: 2),
                            const SizedBox(width: 3),
                            Text(win,
                                style: ff(
                                    size: rem(.56),
                                    w: FontWeight.w700,
                                    color: K.g5)),
                          ]),
                        if (win.isNotEmpty && recurrence.isNotEmpty)
                          Text('·', style: ff(size: rem(.56), color: K.ink4)),
                        if (recurrence.isNotEmpty)
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Ico(_recurIcon, size: 10, stroke: K.t7, sw: 2),
                            const SizedBox(width: 3),
                            Text(recurrence,
                                style: ff(
                                    size: rem(.56),
                                    w: FontWeight.w700,
                                    color: K.t7)),
                          ]),
                      ],
                    ),
                  ],
                  const SizedBox(height: 9),
                  // dashed top divider (matches CSS `1px dashed var(--bd)`)
                  const _DashedLine(color: K.bd),
                  const SizedBox(height: 9),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        if (venue.isNotEmpty || area.isNotEmpty)
                          Row(children: [
                            Ico(_venueIcon, size: 10, stroke: K.ink4, sw: 1.8),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                  area.isNotEmpty && venue.isNotEmpty
                                      ? '$venue · $area'
                                      : (venue.isNotEmpty ? venue : area),
                                  style: ff(
                                      size: rem(.6), color: K.ink3, height: 1.55)),
                            ),
                          ]),
                        if (guru.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Row(children: [
                            Ico(_guruIcon, size: 10, stroke: K.ink4, sw: 1.8),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(guru,
                                  style: ff(
                                      size: rem(.6),
                                      color: K.ink3,
                                      height: 1.55)),
                            ),
                          ]),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single horizontal dashed hairline (CSS `1px dashed`).
class _DashedLine extends StatelessWidget {
  final Color color;
  const _DashedLine({required this.color});
  @override
  Widget build(BuildContext context) =>
      SizedBox(height: 1, width: double.infinity, child: CustomPaint(painter: _DashPainter(color)));
}

class _DashPainter extends CustomPainter {
  final Color color;
  _DashPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dash = 3.0, gap = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset((x + dash).clamp(0, size.width), 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}

class _LogoSlide extends StatelessWidget {
  const _LogoSlide();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.2),
            border: Border.all(color: Colors.white.withOpacity(.3)),
            borderRadius: BorderRadius.circular(13),
          ),
          alignment: Alignment.center,
          child: Ico(_flower, size: 24, stroke: Colors.white, sw: 1.5),
        ),
        const SizedBox(height: 6),
        Text('COMMUNITY LOGO',
            style: ff(
                size: rem(.5),
                w: FontWeight.w700,
                color: Colors.white.withOpacity(.75),
                ls: .5)),
      ],
    );
  }
}
