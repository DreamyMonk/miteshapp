import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../session.dart';
import '../auth_service.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

// Decorative SVG markup (inner paths).
const _plane =
    '<line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/>';
const _cloud = '<path d="M18 10h-1.26A8 8 0 1 0 9 20h9a5 5 0 0 0 0-10z"/>';
const _heart =
    '<path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>';
const _star =
    '<polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>';

const _gold = Color(0xFFF5A623);
const _goldSoft = Color(0xFFF6C463);

/// Animated flash screen — recreates the artwork with motion:
///   • the bell logo pops in, tagline + subtitle reveal
///   • a paper plane flies along a dashed loop trail
///   • heart & star twinkle, and clouds rise from the bottom
/// Shown on every launch; then routes to Home (signed in) or the Get Started
/// phase (logged out).
class S01 extends StatefulWidget {
  const S01({super.key});
  @override
  State<S01> createState() => _S01State();
}

class _S01State extends State<S01> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _logo, _logoFade, _tag, _sub, _clouds, _accents, _fly, _footer;
  Timer? _timer;
  bool _showGetStarted = false;
  bool _advanced = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2100))..forward();
    Animation<double> seg(double a, double b, [Curve c = Curves.easeOut]) =>
        CurvedAnimation(parent: _c, curve: Interval(a, b, curve: c));
    _logo = seg(0.04, 0.42, Curves.easeOutBack);
    _logoFade = seg(0.04, 0.30);
    _tag = seg(0.30, 0.55);
    _sub = seg(0.40, 0.66);
    _accents = seg(0.45, 0.74, Curves.easeOutBack);
    _fly = seg(0.42, 0.96, Curves.easeInOut);
    _clouds = seg(0.48, 0.86);
    _footer = seg(0.70, 1.0);
    _timer = Timer(const Duration(milliseconds: 2700), _afterFlash);
  }

  void _afterFlash() {
    if (!mounted || _advanced) return;
    _advanced = true;
    if (AuthService.isSignedIn || Session.I.loggedIn) {
      go('s03');
    } else {
      setState(() => _showGetStarted = true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showGetStarted ? null : _afterFlash,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Container(
            color: K.cream,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Soft ambient blobs.
                Positioned(top: -70, right: -60, child: Opacity(opacity: .10, child: _circle(220, _gold))),
                Positioned(bottom: -90, left: -70, child: Opacity(opacity: .12, child: _circle(280, K.t5))),

                // Rising clouds at the bottom.
                _cloudWidget(bottom: -6, left: -10, size: 150, color: K.t5, opacity: .9),
                _cloudWidget(bottom: -14, right: -18, size: 170, color: _gold, opacity: .95),

                // Paper plane + dashed trail (lower-middle).
                Align(
                  alignment: const Alignment(0, .34),
                  child: SizedBox(
                    width: 320,
                    height: 150,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: CustomPaint(painter: _TrailPainter(_fly.value, K.t5.withOpacity(.55))),
                        ),
                        _planeWidget(),
                      ],
                    ),
                  ),
                ),

                // Heart + star accents.
                Align(
                  alignment: const Alignment(-.62, .2),
                  child: _pop(_accents, child: Ico(_heart, size: 22, stroke: K.t5, fill: K.t5, sw: 0)),
                ),
                Align(
                  alignment: const Alignment(-.42, .42),
                  child: _pop(_accents, child: Ico(_star, size: 15, stroke: _gold, fill: _gold, sw: 0)),
                ),

                // Center hero + text.
                Align(
                  alignment: const Alignment(0, -.28),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Opacity(
                          opacity: _logoFade.value.clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: 0.7 + 0.3 * _logo.value,
                            child: SizedBox(width: 200, child: Image.asset('assets/logo.png', fit: BoxFit.contain)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _reveal(_tag,
                            child: Text('Invite. Connect. Celebrate.',
                                textAlign: TextAlign.center,
                                style: fd(size: rem(1.05), w: FontWeight.w800, color: K.t7))),
                        const SizedBox(height: 8),
                        _reveal(_sub,
                            child: Text('Create beautiful invitations and\nshare joy with your loved ones.',
                                textAlign: TextAlign.center,
                                style: ff(size: rem(.76), color: K.ink3, height: 1.5))),
                      ],
                    ),
                  ),
                ),

                // Footer line.
                Align(
                  alignment: const Alignment(0, .93),
                  child: Opacity(
                    opacity: _footer.value.clamp(0.0, 1.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Ico(_star, size: 10, stroke: _gold, fill: _gold, sw: 0),
                        const SizedBox(width: 8),
                        Text('Every invitation creates a memory.',
                            style: ff(size: rem(.62), w: FontWeight.w600, color: K.t7.withOpacity(.75))),
                        const SizedBox(width: 8),
                        Ico(_star, size: 10, stroke: _gold, fill: _gold, sw: 0),
                      ],
                    ),
                  ),
                ),

                // Get Started CTA (onboarding phase).
                if (_showGetStarted)
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 0, 28, 26),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 340),
                          curve: Curves.easeOut,
                          builder: (_, t, child) => Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 10 * (1 - t)), child: child)),
                          child: Btn('Get Started', kind: BtnKind.p, trailing: P.arrowRight, onTap: () => go('s02')),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Plane positioned along the trail at the current fly progress, angled to its heading.
  Widget _planeWidget() {
    final metric = _TrailPainter.trail(const Size(320, 150)).computeMetrics().first;
    final len = metric.length * _fly.value.clamp(0.0, 1.0);
    final tan = metric.getTangentForOffset(len);
    if (tan == null) return const SizedBox();
    final pos = tan.position;
    final angle = tan.angle; // radians (screen y-down)
    return Positioned(
      left: pos.dx - 13,
      top: pos.dy - 13,
      child: Opacity(
        opacity: (_fly.value * 3).clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: -angle + math.pi / 4, // plane icon points up-right by default
          child: Ico(_plane, size: 26, stroke: K.t7, fill: Colors.white, sw: 1.8),
        ),
      ),
    );
  }

  Widget _cloudWidget({double? bottom, double? left, double? right, required double size, required Color color, double opacity = 1}) {
    final t = _clouds.value.clamp(0.0, 1.0);
    return Positioned(
      bottom: (bottom ?? 0) - 40 * (1 - t),
      left: left,
      right: right,
      child: Opacity(
        opacity: opacity * t,
        child: Ico(_cloud, size: size, stroke: color, fill: color, sw: 0),
      ),
    );
  }

  Widget _reveal(Animation<double> a, {required Widget child}) {
    final t = a.value.clamp(0.0, 1.0);
    return Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child));
  }

  Widget _pop(Animation<double> a, {required Widget child}) {
    final t = a.value.clamp(0.0, 1.2);
    return Opacity(opacity: t.clamp(0.0, 1.0), child: Transform.scale(scale: t, child: child));
  }

  Widget _circle(double s, Color c) =>
      Container(width: s, height: s, decoration: BoxDecoration(color: c, shape: BoxShape.circle));
}

class _TrailPainter extends CustomPainter {
  final double progress;
  final Color color;
  _TrailPainter(this.progress, this.color);

  // The swooping flight path (in the 320x150 canvas space).
  static Path trail(Size s) {
    final p = Path();
    p.moveTo(s.width * .06, s.height * .82);
    p.cubicTo(s.width * .24, s.height * 1.05, s.width * .40, s.height * .30, s.width * .55, s.height * .58);
    p.cubicTo(s.width * .68, s.height * .80, s.width * .78, s.height * .18, s.width * .92, s.height * .16);
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = trail(size);
    final metric = path.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * progress.clamp(0.0, 1.0));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (final m in drawn.computeMetrics()) {
      var dist = 0.0;
      while (dist < m.length) {
        final len = math.min(6.0, m.length - dist);
        canvas.drawPath(m.extractPath(dist, dist + len), paint);
        dist += 11;
      }
    }
  }

  @override
  bool shouldRepaint(_TrailPainter old) => old.progress != progress || old.color != color;
}
