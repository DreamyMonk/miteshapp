import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

// ===== Icon inner-markup (exact from HTML) =====
const _logoFlower =
    '<circle cx="12" cy="12" r="2.5"/><path d="M12 9.5c0-2 1.5-3.5 0-5.5-1.5 2-1.5 3.5 0 5.5M12 14.5c0 2-1.5 3.5 0 5.5 1.5-2 1.5-3.5 0-5.5M9.5 12c-2 0-3.5 1.5-5.5 0 2-1.5 3.5-1.5 5.5 0M14.5 12c2 0 3.5-1.5 5.5 0-2 1.5-3.5 1.5-5.5 0"/>';
const _refresh =
    '<polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 1 0 2.13-9.36L1 10"/>';
const _check = '<polyline points="20 6 9 17 4 12"/>';
const _clock = '<circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>';
const _users =
    '<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/>';
const _monk =
    '<path d="M12 2a3 3 0 0 0-3 3c0 1.5.7 2.5 1.5 3.5C9 10 8 11.5 8 14a4 4 0 0 0 8 0c0-2.5-1-4-2.5-5.5C14.3 7.5 15 6.5 15 5a3 3 0 0 0-3-3z"/><path d="M9 17v5M15 17v5"/>';
const _star =
    '<polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>';
const _pin =
    '<path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/>';
const _venue = '<path d="M3 21h18M5 21V7l8-4v18M19 21V11l-6-3"/>';
const _directions = '<polygon points="3 11 22 2 13 21 11 13 3 11"/>';
const _calendar =
    '<rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>';
const _info =
    '<circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/>';
const _refreshNext =
    '<polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/>';
const _arrowBack =
    '<line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/>';
const _imagePlaceholder =
    '<rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/>';
const _mon = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _wk = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

DateTime? _d(String iso) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(iso);
  if (m == null) return null;
  return DateTime(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
}

String _dmy(DateTime? d) => d == null ? '—' : '${d.day} ${_mon[d.month - 1]} ${d.year}';
String _wkday(DateTime? d) => d == null ? '' : _wk[d.weekday - 1];

class S34 extends StatefulWidget {
  const S34({super.key});
  @override
  State<S34> createState() => _S34State();
}

class _S34State extends State<S34> {
  static final DateTime _today = DateTime(2026, 5, 22); // demo "today"

  final PageController _coverCtrl = PageController();
  int _coverIdx = 0;
  Timer? _coverTimer;

  // How many hero slides: 1 when the host uploaded a real cover, else 3 gradients.
  bool get _hasCover => _f('cover').isNotEmpty;
  int get _slideCount => _hasCover ? 1 : 3;

  @override
  void initState() {
    super.initState();
    AppData.I.addListener(_onData);
    // Auto-advance carousel every 3.2s (only when there's more than one slide).
    _coverTimer = Timer.periodic(const Duration(milliseconds: 3200), (_) {
      if (!mounted || !_coverCtrl.hasClients || _slideCount <= 1) return;
      final next = (_coverIdx + 1) % _slideCount;
      _coverCtrl.animateToPage(next,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  // A host-uploaded image field: an R2/URL (http…) or a legacy base64 data URL.
  Widget? _imageFor(String field, {BoxFit fit = BoxFit.cover}) {
    final s = _f(field);
    if (s.isEmpty) return null;
    if (s.startsWith('http')) {
      return Image.network(s,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => const SizedBox());
    }
    try {
      final i = s.indexOf('base64,');
      final bytes = base64Decode(i >= 0 ? s.substring(i + 7) : s);
      return Image.memory(bytes, fit: fit, width: double.infinity, height: double.infinity);
    } catch (_) {
      return null;
    }
  }

  void _onData() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppData.I.removeListener(_onData);
    _coverTimer?.cancel();
    _coverCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic>? get _community =>
      AppData.I.selectedCommunity ??
      (AppData.I.liveCommunities.isNotEmpty ? AppData.I.liveCommunities.first : null);

  String _f(String k) {
    final c = _community;
    return c == null ? '' : '${c[k] ?? ''}';
  }

  String get _name => _f('name');
  bool get _subscribed => _name.isNotEmpty && AppData.I.isSubscribed(_name);

  void _toggleSubscribe() {
    if (_name.isEmpty) return;
    final next = !_subscribed;
    AppData.I.setSubscribed(_name, next);
    toast(next ? 'Subscribed to $_name' : 'Unsubscribed');
  }

  @override
  Widget build(BuildContext context) {
    final c = _community;
    if (c == null) return _emptyScreen();

    final programs = AppData.I.programsOfCommunity(_name);

    return Container(
      color: K.cream,
      child: Column(
        children: [
          _hero(),
          Sc(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            cross: CrossAxisAlignment.stretch,
            [
              _subscriptionHero(),
              _timelineCard(),
              if (_f('guru').isNotEmpty) _guideCard(),
              if (_f('venue').isNotEmpty) _venueCard(),
              _programmesCard(programs),
              if (_f('about').isNotEmpty) _aboutCard(),
              if (_f('recurrence').isNotEmpty || _f('nextEdition').isNotEmpty) _nextEditionCard(),
              if (_f('pastEdition').isNotEmpty) _pastEditionsCard(),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Empty state (no community published) ----
  Widget _emptyScreen() {
    return Container(
      color: K.cream,
      child: Column(
        children: [
          AppBarX(
            title: 'Community',
            back: 's09',
            onBack: () => go('s09'),
          ),
          Sc(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            [
              CardX(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    children: [
                      Ico(_logoFlower, size: 28, stroke: K.ink4, sw: 1.5),
                      const SizedBox(height: 10),
                      Text('No community published yet',
                          style: ff(size: rem(.72), w: FontWeight.w700, color: K.ink2)),
                      const SizedBox(height: 4),
                      Text(
                          'Once a host publishes their community profile, its booking information will appear here.',
                          textAlign: TextAlign.center,
                          style: ff(size: rem(.6), color: K.ink3, height: 1.5)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Hero cover (carousel kept as-is; text driven by data) ----
  Widget _hero() {
    final editionLabel = _f('editionLabel');
    final editionDays = _f('editionDays');
    final recurrence = _f('recurrence');
    final status = _f('editionStatus');
    final live = status.isEmpty || status.toLowerCase() == 'active';
    final sub = editionDays.isNotEmpty
        ? '$editionDays-day gathering'
        : (recurrence.isNotEmpty ? recurrence : '');
    return SizedBox(
      height: 175,
      width: double.infinity,
      child: Stack(
        children: [
          // Carousel: the host's real cover photo if uploaded, else gradients.
          Positioned.fill(
            child: PageView(
              controller: _coverCtrl,
              onPageChanged: (i) => setState(() => _coverIdx = i),
              children: (() {
                final cover = _imageFor('cover');
                return cover != null
                    ? [cover]
                    : [_slide1(), _slide2(), _slide3()];
              })(),
            ),
          ),
          // Bottom gradient overlay for readability
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 80,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(.55)],
                  ),
                ),
              ),
            ),
          ),
          // Dots (only when there's more than one slide)
          if (_slideCount > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(_coverIdx == 0),
                  const SizedBox(width: 5),
                  _dot(_coverIdx == 1),
                  const SizedBox(width: 5),
                  _dot(_coverIdx == 2),
                ],
              ),
            ),
          // Back button overlay
          Positioned(
            top: 14,
            left: 14,
            child: Press(
              onTap: () => go('s09'),
              scale: .9,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.4),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: Colors.white.withOpacity(.15)),
                ),
                alignment: Alignment.center,
                child: Ico(_arrowBack, size: 16, stroke: Colors.white, sw: 1.8),
              ),
            ),
          ),
          // Calendar button overlay
          Positioned(
            top: 14,
            left: 54,
            child: Press(
              onTap: () => go('s10'),
              scale: .9,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.4),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: Colors.white.withOpacity(.15)),
                ),
                alignment: Alignment.center,
                child: Ico(_calendar, size: 14, stroke: Colors.white, sw: 1.9),
              ),
            ),
          ),
          // Status pill top-right
          if (live)
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withOpacity(.92),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF86EFAC).withOpacity(.5)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(.25), blurRadius: 10, offset: const Offset(0, 3)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          color: Color(0xFF86EFAC), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text('LIVE NOW',
                        style: ff(size: rem(.54), w: FontWeight.w800, color: Colors.white, ls: .4)),
                  ],
                ),
              ),
            ),
          // Community name overlay bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_name,
                    style: fd(
                        size: rem(1.35),
                        w: FontWeight.w800,
                        color: Colors.white,
                        height: 1.15)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (editionLabel.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5A623).withOpacity(.85),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Ico(_refresh, size: 9, stroke: Colors.white, sw: 2),
                            const SizedBox(width: 4),
                            Text(editionLabel,
                                style: ff(size: rem(.52), w: FontWeight.w800, color: Colors.white)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (sub.isNotEmpty)
                      Flexible(
                        child: Text(sub,
                            overflow: TextOverflow.ellipsis,
                            style: ff(size: rem(.6), w: FontWeight.w600, color: Colors.white.withOpacity(.9))),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Slide 1 — Community Logo, gradient 135deg #92400E→#D97706→#F5A623
  Widget _slide1() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF92400E), Color(0xFFD97706), Color(0xFFF5A623)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(.18),
              border: Border.all(color: Colors.white.withOpacity(.3)),
            ),
            alignment: Alignment.center,
            child: _imageFor('logo') ?? Ico(_logoFlower, size: 32, stroke: Colors.white, sw: 1.5),
          ),
          const SizedBox(height: 8),
          Text('Community Logo',
              style: ff(
                  size: rem(.55),
                  w: FontWeight.w800,
                  color: Colors.white.withOpacity(.7),
                  ls: 1)),
        ],
      ),
    );
  }

  // Slide 2 — EVENT GATHERING, gradient 135deg #7C2D12→#B45309
  Widget _slide2() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C2D12), Color(0xFFB45309)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 18,
            right: 18,
            child: Ico(_imagePlaceholder,
                size: 42, stroke: Colors.white.withOpacity(.25), sw: 1.2, round: false),
          ),
          Positioned(
            bottom: 14,
            left: 16,
            child: Text('EVENT GATHERING',
                style: ff(
                    size: rem(.5),
                    w: FontWeight.w700,
                    color: Colors.white.withOpacity(.7),
                    ls: .5)),
          ),
        ],
      ),
    );
  }

  // Slide 3 — PRAVACHAN HALL, gradient 135deg #1A0E3D→#5B3E9E
  Widget _slide3() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0E3D), Color(0xFF5B3E9E)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 18,
            right: 18,
            child: Ico(_imagePlaceholder,
                size: 42, stroke: Colors.white.withOpacity(.25), sw: 1.2, round: false),
          ),
          Positioned(
            bottom: 14,
            left: 16,
            child: Text('PRAVACHAN HALL',
                style: ff(
                    size: rem(.5),
                    w: FontWeight.w700,
                    color: Colors.white.withOpacity(.7),
                    ls: .5)),
          ),
        ],
      ),
    );
  }

  Widget _dot(bool on) => Container(
        width: on ? 16 : 6,
        height: 6,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(on ? .9 : .4),
          borderRadius: BorderRadius.circular(3),
        ),
      );

  // ---- Subscription status hero (matches HTML: dark purple card, amber check) ----
  Widget _subscriptionHero() {
    final sub = _subscribed;
    final title = sub ? "You're subscribed" : 'Subscribe to get updates';
    final desc = sub
        ? 'All updates auto-delivered for this community'
        : 'Notify me for every edition at any venue';
    final actionLabel = sub ? 'Unsubscribe' : 'Subscribe';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0E3D), Color(0xFF3D2582)]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF5A623), Color(0xFFD97706)]),
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(color: const Color(0xFFF5A623).withOpacity(.3), blurRadius: 10, offset: const Offset(0, 3)),
              ],
            ),
            alignment: Alignment.center,
            child: Ico(_check, size: 17, stroke: Colors.white, sw: 2.6),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ff(size: rem(.72), w: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 1),
                Text(desc,
                    style: ff(size: rem(.54), color: Colors.white.withOpacity(.8), height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 11),
          Press(
            onTap: _toggleSubscribe,
            scale: .95,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.18),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: Colors.white.withOpacity(.3)),
              ),
              child: Text(actionLabel,
                  style: ff(size: rem(.58), w: FontWeight.w800, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 6),
          Press(
            onTap: () {
              toast('Manage subscription');
              go('s22');
            },
            scale: .95,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0xFFFDE68A).withOpacity(.35)),
              ),
              child: Text('Manage',
                  style: ff(size: rem(.56), w: FontWeight.w700, color: const Color(0xFFFDE68A))),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Schedule Timeline card ----
  Widget _timelineCard() {
    final start = _d(_f('editionStart'));
    final end = _d(_f('editionEnd'));
    final total = int.tryParse(_f('editionDays')) ??
        ((start != null && end != null) ? end.difference(start).inDays + 1 : 0);
    int done = 0;
    if (start != null) {
      done = _today.difference(start).inDays + 1;
      if (done < 0) done = 0;
      if (total > 0 && done > total) done = total;
    }
    final left = (total - done) < 0 ? 0 : total - done;
    final frac = total > 0 ? (done / total).clamp(0.0, 1.0) : 0.0;
    final dayNo = done > 0 ? done : 1;

    return CardX(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeading(_clock, 'Schedule Timeline'),
          const SizedBox(height: 11),
          if (start == null && end == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('Edition dates to be announced.',
                  style: ff(size: rem(.62), color: K.ink3)),
            )
          else ...[
            // Visual timeline bar
            SizedBox(
              height: 32,
              child: LayoutBuilder(builder: (ctx, c) {
                final w = c.maxWidth;
                return Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 14,
                      child: Container(
                          height: 4,
                          decoration: BoxDecoration(color: K.bd, borderRadius: BorderRadius.circular(2))),
                    ),
                    Positioned(
                      left: 0,
                      top: 14,
                      child: Container(
                        width: w * frac,
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF16A34A), Color(0xFF86EFAC)]),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Start marker
                    Positioned(
                      left: 0,
                      top: 8,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                    // Today marker
                    Positioned(
                      left: (w * frac - 11).clamp(0.0, w - 22),
                      top: 4,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFF5A623), Color(0xFFD97706)]),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFFF5A623).withOpacity(.5), blurRadius: 6, offset: const Offset(0, 2)),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        ),
                      ),
                    ),
                    // End marker
                    Positioned(
                      right: 0,
                      top: 8,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: K.bd2,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 13),
            // Timeline labels
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('STARTED',
                          style: ff(size: rem(.5), w: FontWeight.w800, color: const Color(0xFF15803D), ls: .4)),
                      const SizedBox(height: 2),
                      Text(_dmy(start), style: mono(size: rem(.72), w: FontWeight.w700, color: K.ink)),
                      Text(_wkday(start), style: ff(size: rem(.54), color: K.ink4)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('TODAY · DAY $dayNo',
                          style: ff(size: rem(.5), w: FontWeight.w800, color: K.g5, ls: .4)),
                      const SizedBox(height: 2),
                      Text(_dmy(_today), style: mono(size: rem(.72), w: FontWeight.w700, color: K.g5)),
                      Text(_wkday(_today), style: ff(size: rem(.54), color: K.g5.withOpacity(.85))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('ENDS',
                          style: ff(size: rem(.5), w: FontWeight.w800, color: K.ink4, ls: .4)),
                      const SizedBox(height: 2),
                      Text(_dmy(end), style: mono(size: rem(.72), w: FontWeight.w700, color: K.ink)),
                      Text(_wkday(end), style: ff(size: rem(.54), color: K.ink4)),
                    ],
                  ),
                ),
              ],
            ),
            // Progress stats
            Container(
              margin: const EdgeInsets.only(top: 13),
              padding: const EdgeInsets.only(top: 11),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: K.bd)),
              ),
              child: Row(
                children: [
                  _statBox('$total', 'Total Days', K.cream, K.ink, K.ink3),
                  const SizedBox(width: 7),
                  _statBox('$done', 'Days Done', const Color(0xFF16A34A).withOpacity(.1),
                      const Color(0xFF16A34A), const Color(0xFF15803D)),
                  const SizedBox(width: 7),
                  _statBox('$left', 'Days Left', const Color(0xFFF5A623).withOpacity(.12), K.g5, K.g5),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Btn('View Day-wise Schedule',
              kind: BtnKind.p,
              leading: _calendar,
              padding: const EdgeInsets.all(9),
              fontSize: rem(.72),
              margin: 0,
              onTap: () => go('s11')),
        ],
      ),
    );
  }

  Widget _statBox(String num, String label, Color bg, Color numC, Color labelC) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Text(num, style: mono(size: rem(.95), w: FontWeight.w800, color: numC)),
            Text(label,
                style: ff(size: rem(.5), w: FontWeight.w700, color: labelC), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ---- Spiritual Guide card ----
  Widget _guideCard() {
    return CardX(
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeading(_users, 'Spiritual Guide'),
          const SizedBox(height: 11),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF5A623), Color(0xFFD97706)]),
                  shape: BoxShape.circle,
                  border: Border.all(color: K.g1, width: 3),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFF5A623).withOpacity(.3), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                alignment: Alignment.center,
                child: Ico(_monk, size: 32, stroke: Colors.white, sw: 1.8),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_f('guru'),
                        style: fd(size: rem(.92), w: FontWeight.w800, color: K.ink, height: 1.2)),
                    if (_f('guruDesc').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(_f('guruDesc'),
                          style: ff(size: rem(.6), color: K.ink3)),
                    ],
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Ico(_star, size: 9, stroke: K.g5, sw: 2),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                              _f('guruNote').isNotEmpty
                                  ? _f('guruNote')
                                  : 'Hosting daily 7 AM Pravachan',
                              style: ff(size: rem(.56), w: FontWeight.w700, color: K.g5)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Venue card ----
  Widget _venueCard() {
    final venue = _f('venue');
    final addr = _f('venueAddr');
    return CardX(
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeading(_pin, 'Hosted At'),
          const SizedBox(height: 11),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF5B3E9E), Color(0xFF3D2582)]),
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF3D2582).withOpacity(.25), blurRadius: 10, offset: const Offset(0, 3)),
                  ],
                ),
                alignment: Alignment.center,
                child: Ico(_venue, size: 20, stroke: Colors.white, sw: 1.7),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(venue,
                        style: fd(size: rem(.92), w: FontWeight.w800, color: K.ink, height: 1.2)),
                    if (addr.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(addr, style: ff(size: rem(.62), color: K.ink3, height: 1.55)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Btn('Get Directions on Google Maps',
              kind: BtnKind.p,
              leading: _directions,
              padding: const EdgeInsets.all(10),
              fontSize: rem(.74),
              margin: 0,
              onTap: () => gmaps(venue, addr)),
          const SizedBox(height: 6),
          Text('Opens in Google Maps app with destination pre-filled',
              style: ff(size: rem(.52), color: K.ink4), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ---- Programmes overview ----
  Widget _programmesCard(List<Map<String, dynamic>> programs) {
    final total = programs.length;
    final completed = programs.where((p) {
      final d = _d('${p['date'] ?? ''}');
      return d != null && d.isBefore(_today);
    }).length;
    final remaining = total - completed;
    return CardX(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Ico(_calendar, size: 11, stroke: K.ink4, sw: 2, round: false),
                  const SizedBox(width: 6),
                  Text('PROGRAMMES',
                      style: ff(size: rem(.6), w: FontWeight.w700, color: K.ink4, ls: .5)),
                ],
              ),
              Press(
                onTap: () => go('s11'),
                scale: .95,
                child: Text('See all ›',
                    style: ff(size: rem(.6), w: FontWeight.w700, color: K.t7)),
              ),
            ],
          ),
          const SizedBox(height: 11),
          if (total == 0)
            Text('No programmes published yet.',
                style: ff(size: rem(.62), color: K.ink3))
          else
            Row(
              children: [
                _progBox('$total', 'Total', K.t0, K.t1, K.t7, K.ink3),
                const SizedBox(width: 8),
                _progBox('$completed', 'Completed', const Color(0xFF16A34A).withOpacity(.1),
                    const Color(0xFF86EFAC).withOpacity(.4), const Color(0xFF16A34A), const Color(0xFF15803D)),
                const SizedBox(width: 8),
                _progBox('$remaining', 'Remaining', const Color(0xFFF5A623).withOpacity(.12), K.g3, K.g5, K.g5),
              ],
            ),
        ],
      ),
    );
  }

  Widget _progBox(String num, String label, Color bg, Color bd, Color numC, Color labelC) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: bd),
        ),
        child: Column(
          children: [
            Text(num, style: mono(size: rem(1.2), w: FontWeight.w800, color: numC)),
            const SizedBox(height: 1),
            Text(label,
                style: ff(size: rem(.5), w: FontWeight.w700, color: labelC), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ---- About ----
  Widget _aboutCard() {
    return CardX(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeading(_info, 'About'),
          const SizedBox(height: 7),
          Text(_f('about'), style: ff(size: rem(.72), color: K.ink3, height: 1.6)),
        ],
      ),
    );
  }

  // ---- Next edition planned (blue recurrence card) ----
  Widget _nextEditionCard() {
    final title = _f('nextEdition').isNotEmpty ? _f('nextEdition') : _f('recurrence');
    final dates = _f('nextEditionDates');
    final days = _f('nextEditionDays');
    return CardX(
      bg: K.in1,
      border: Border.all(color: const Color(0xFF1D4ED8).withOpacity(.18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Ico(_refreshNext, size: 11, stroke: K.inC, sw: 2),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text('NEXT EDITION PLANNED',
                          style: ff(size: rem(.6), w: FontWeight.w700, color: K.inC, ls: .5)),
                    ),
                  ],
                ),
              ),
              if (days.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D4ED8).withOpacity(.15),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(days,
                      style: ff(size: rem(.54), w: FontWeight.w700, color: K.inC)),
                ),
            ],
          ),
          const SizedBox(height: 7),
          Text(title, style: ff(size: rem(.72), w: FontWeight.w700, color: K.ink)),
          if (dates.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(dates, style: mono(size: rem(.58), color: K.ink3)),
          ],
          const SizedBox(height: 5),
          Text("We'll notify you 2 weeks before the next edition starts.",
              style: ff(size: rem(.54), color: K.inC, height: 1.5)),
        ],
      ),
    );
  }

  // ---- Past editions ----
  Widget _pastEditionsCard() {
    final title = _f('pastEdition');
    final meta = _f('pastEditionMeta');
    return CardX(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeading(_clock, 'Past Editions'),
          const SizedBox(height: 11),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: K.ink4, shape: BoxShape.circle),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: ff(size: rem(.7), w: FontWeight.w700, color: K.ink)),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(meta, style: mono(size: rem(.54), color: K.ink4)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 9),
              Press(
                onTap: () => go('s33'),
                scale: .95,
                child: Text('View attendance ›',
                    style: ff(size: rem(.54), w: FontWeight.w700, color: K.t7)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardHeading(String icon, String label) {
    return Row(
      children: [
        Ico(icon, size: 11, stroke: K.ink4, sw: 2, round: false),
        const SizedBox(width: 6),
        Text(label.toUpperCase(),
            style: ff(size: rem(.6), w: FontWeight.w700, color: K.ink4, ls: .5)),
      ],
    );
  }
}
