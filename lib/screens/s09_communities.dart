import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

// Icons used on this screen.
const _info =
    '<circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/>';
const _satsang =
    '<path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83"/>';
const _music = '<path d="M9 18V5l12-2v13"/><circle cx="6" cy="18" r="3"/><circle cx="18" cy="16" r="3"/>';
const _refresh =
    '<polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/>';

const _mon = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

DateTime? _d(String iso) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(iso);
  if (m == null) return null;
  return DateTime(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
}

String _dm(DateTime? d) => d == null ? '' : '${d.day} ${_mon[d.month - 1]}';
String _dmy(DateTime? d) => d == null ? '' : '${d.day} ${_mon[d.month - 1]} ${d.year}';
String _my(DateTime? d) => d == null ? '' : '${_mon[d.month - 1]} ${d.year}';

String _s(Map<String, dynamic> c, String k) => '${c[k] ?? ''}';

String _window(Map<String, dynamic> c) {
  final start = _d(_s(c, 'editionStart'));
  final end = _d(_s(c, 'editionEnd'));
  if (start == null || end == null) return '';
  return '${_dm(start)} — ${_dmy(end)}';
}

// Rotating icon looks (visual variety, matches the prototype's card styles).
const _icons = [P.flower, _satsang, _music];
const _iconGrads = <Gradient>[
  K.gGold,
  LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF16A34A), Color(0xFF15803D)]),
  LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF5B3E9E), Color(0xFF3D2582)]),
];

class S09 extends StatefulWidget {
  const S09({super.key});
  @override
  State<S09> createState() => _S09State();
}

class _S09State extends State<S09> {
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

  void _open(Map<String, dynamic> c) {
    AppData.I.selectedCommunity = c;
    go('s34');
  }

  @override
  Widget build(BuildContext context) {
    final live = AppData.I.liveCommunities;
    final subscribed =
        live.where((c) => AppData.I.isSubscribed(_s(c, 'name'))).toList();
    final discover =
        live.where((c) => !AppData.I.isSubscribed(_s(c, 'name'))).toList();

    return Container(
      color: K.cream,
      child: Column(
        children: [
          AppBarX(
            title: 'My Communities',
            sub: '${subscribed.length} subscribed',
            back: 's03',
            onBack: () => go('s03'),
            actions: [
              IbBtn(P.calendar, onTap: () => go('s10')),
              const SizedBox(width: 6),
              IbBtn(P.bell, onTap: () => go('s16')),
              const SizedBox(width: 6),
              IbBtn(P.search, onTap: () => go('s04')),
            ],
          ),
          Sc(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            [
              // Info banner
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: K.t0,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: K.t1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Ico(_info, size: 14, stroke: K.t7, sw: 1.8),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Subscribe once — stay updated for every edition at any venue. We’ll notify you whenever a community starts a new programme.',
                        style: ff(size: rem(.6), color: K.t7, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),

              if (live.isEmpty)
                _emptyCard(
                    'No communities are live yet',
                    'Once hosts publish their community profiles, they will appear here.')
              else if (subscribed.isEmpty)
                _emptyCard('No subscriptions yet',
                    'Subscribe to a community below to get updates for every edition at any venue.')
              else
                for (var i = 0; i < subscribed.length; i++)
                  _subscribedCard(subscribed[i], i),

              if (discover.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: Text('DISCOVER',
                      style: ff(size: rem(.6), w: FontWeight.w700, color: K.ink4, ls: .5)),
                ),
                for (var i = 0; i < discover.length; i++)
                  _discoverCard(discover[i], i),
              ],

              const SizedBox(height: 2),
              Btn('Subscribe to New Community', kind: BtnKind.p, leading: P.plus, onTap: () => go('s04')),
              const SizedBox(height: 1),
              Btn('Manage Subscriptions', kind: BtnKind.o, onTap: () => go('s21')),
              const SizedBox(height: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(String title, String desc) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
        color: K.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: K.bd),
      ),
      child: Column(
        children: [
          Ico(P.flower, size: 26, stroke: K.ink4, sw: 1.6),
          const SizedBox(height: 10),
          Text(title, style: ff(size: rem(.72), w: FontWeight.w700, color: K.ink2)),
          const SizedBox(height: 4),
          Text(desc,
              textAlign: TextAlign.center,
              style: ff(size: rem(.6), color: K.ink3, height: 1.5)),
        ],
      ),
    );
  }

  Widget _subscribedCard(Map<String, dynamic> c, int i) {
    final name = _s(c, 'name');
    final status = _s(c, 'editionStatus');
    final active = status.isEmpty || status.toLowerCase() == 'active';
    final editionLabel = _s(c, 'editionLabel');
    final venue = _s(c, 'venue');
    final end = _d(_s(c, 'editionEnd'));
    final nextEdition = _my(_d(_s(c, 'nextEditionDate')));
    return _CommunityCard(
      accent: active ? K.ok : K.bd2,
      iconGradient: _iconGrads[i % _iconGrads.length],
      iconShadow: [
        BoxShadow(
            color: const Color(0xFFF5A623).withOpacity(.28),
            blurRadius: 10,
            offset: const Offset(0, 3)),
      ],
      icon: _icons[i % _icons.length],
      title: name,
      status: active
          ? _StatusPill.active(
              editionLabel.isEmpty ? 'Active' : '$editionLabel · Active')
          : _StatusPill.dormant('Between editions'),
      footer: active
          // Active: venue · till <end date>
          ? Row(
              children: [
                const Ico(P.venue, size: 10, stroke: K.ink4, sw: 1.8),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(venue.isEmpty ? 'Venue to be announced' : venue,
                      style: ff(size: rem(.6), color: K.ink3),
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 6),
                Text('·', style: ff(size: rem(.6), color: K.ink4)),
                const SizedBox(width: 6),
                const Ico(P.calendar, size: 10, stroke: K.ink4, sw: 1.8),
                const SizedBox(width: 6),
                Text(end == null ? 'Dates TBA' : 'till ${_dm(end)}',
                    style: ff(size: rem(.6), color: K.ink3)),
              ],
            )
          // Dormant: refresh · Next edition expected <Month Year> · venue TBA
          : Row(
              children: [
                const Ico(_refresh, size: 10, stroke: K.ink4, sw: 1.8),
                const SizedBox(width: 6),
                Expanded(
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: ff(size: rem(.6), color: K.ink3),
                      children: [
                        const TextSpan(text: 'Next edition expected '),
                        TextSpan(
                            text: nextEdition.isEmpty ? 'soon' : nextEdition,
                            style: ff(size: rem(.6), w: FontWeight.w700, color: K.g5)),
                        const TextSpan(text: ' · venue TBA'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      onTap: () => _open(c),
    );
  }

  Widget _discoverCard(Map<String, dynamic> c, int i) {
    final name = _s(c, 'name');
    final editionLabel = _s(c, 'editionLabel');
    final window = _window(c);
    final venueLine = [
      if (_s(c, 'venue').isNotEmpty) _s(c, 'venue'),
      if (_s(c, 'area').isNotEmpty) _s(c, 'area'),
    ].join(' · ');
    final metaLine = [
      if (venueLine.isNotEmpty) venueLine,
      if (window.isNotEmpty) window,
    ].join(' · ');
    return Press(
      scale: .98,
      onTap: () => _open(c),
      child: Container(
        width: double.infinity,
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
            GBox(
              size: 40,
              radius: 11,
              gradient: _iconGrads[(i + 1) % _iconGrads.length],
              child: Ico(_icons[(i + 1) % _icons.length], size: 20, stroke: Colors.white, sw: 1.8),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(name,
                      style: fd(size: rem(.82), w: FontWeight.w800, color: K.ink, height: 1.2)),
                  if (editionLabel.isNotEmpty || metaLine.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                        [
                          if (editionLabel.isNotEmpty) editionLabel,
                          if (metaLine.isNotEmpty) metaLine,
                        ].join(' · '),
                        style: ff(size: rem(.56), color: K.ink3),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 9),
            Press(
              scale: .95,
              onTap: () {
                AppData.I.setSubscribed(name, true);
                toast('Subscribed to $name');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  gradient: K.gPurple,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text('Subscribe',
                    style: ff(size: rem(.58), w: FontWeight.w800, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color border;
  final Color dot;
  final Color fg;
  const _StatusPill(
      {required this.text, required this.bg, required this.border, required this.dot, required this.fg});

  factory _StatusPill.active(String text) => _StatusPill(
        text: text,
        bg: const Color(0xFF16A34A).withOpacity(.12),
        border: const Color(0xFF86EFAC).withOpacity(.4),
        dot: const Color(0xFF16A34A),
        fg: const Color(0xFF15803D),
      );

  factory _StatusPill.dormant(String text) =>
      _StatusPill(text: text, bg: K.cream2, border: K.bd, dot: K.ink4, fg: K.ink3);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 3),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 5, height: 5, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(text,
              style: ff(size: rem(.52), w: FontWeight.w800, color: fg, ls: .3)),
        ],
      ),
    );
  }
}

/// 1px dashed horizontal rule (matches `border-top:1px dashed var(--bd)`).
class _DashedLine extends StatelessWidget {
  const _DashedLine();
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 1,
        width: double.infinity,
        child: CustomPaint(painter: _DashPainter()),
      );
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = K.bd
      ..strokeWidth = 1;
    const dash = 3.0, gap = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CommunityCard extends StatelessWidget {
  final Color accent;
  final Gradient iconGradient;
  final List<BoxShadow>? iconShadow;
  final String icon;
  final String title;
  final Widget status;
  final Widget footer;
  final VoidCallback onTap;
  const _CommunityCard({
    required this.accent,
    required this.iconGradient,
    this.iconShadow,
    required this.icon,
    required this.title,
    required this.status,
    required this.footer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Press(
      scale: .98,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: K.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            top: BorderSide(color: K.bd),
            right: BorderSide(color: K.bd),
            bottom: BorderSide(color: K.bd),
            left: BorderSide(color: accent, width: 4),
          ),
          boxShadow: K.sh,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GBox(
                  size: 44,
                  radius: 12,
                  gradient: iconGradient,
                  shadow: iconShadow,
                  child: Ico(icon, size: 22, stroke: Colors.white, sw: 1.8),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title,
                          style: fd(size: rem(.92), w: FontWeight.w800, color: K.ink, height: 1.2)),
                      status,
                    ],
                  ),
                ),
                const SizedBox(width: 11),
                const Ico(P.chevR, size: 13, stroke: K.ink4, sw: 2.2),
              ],
            ),
            const SizedBox(height: 9),
            const _DashedLine(),
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: footer,
            ),
          ],
        ),
      ),
    );
  }
}
