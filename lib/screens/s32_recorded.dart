import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

class S32 extends StatelessWidget {
  const S32({super.key});
  @override
  Widget build(BuildContext context) {
    // The check-in that was just recorded (most recent).
    final rec = AppData.I.checkIns.isNotEmpty ? AppData.I.checkIns.first : null;
    final eventName = (rec != null && rec.event.isNotEmpty) ? rec.event : 'the programme';
    final checkedTime = (rec != null && rec.time.isNotEmpty) ? rec.time : '';
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF052E16), Color(0xFF166534), Color(0xFF16A34A)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -50,
            child: _circle(200, Colors.white.withOpacity(.06)),
          ),
          Positioned(
            bottom: -80,
            left: -50,
            child: _circle(240, const Color(0xFFF5A623).withOpacity(.1)),
          ),
          // confetti
          _dot(top: .22, left: .18, size: 8, color: const Color(0xFFF5A623), radius: 2),
          _dot(top: .19, left: .76, size: 7, color: const Color(0xFFFDE68A), radius: 99),
          _dot(top: .28, left: .32, size: 6, color: Colors.white, radius: 2),
          _dot(top: .17, left: .56, size: 8, color: const Color(0xFFF5A623), radius: 99),
          _dot(top: .25, left: .88, size: 6, color: const Color(0xFFFDE68A), radius: 2),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 104,
                    height: 104,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(.5), width: 2),
                          ),
                        ),
                        Container(
                          width: 88,
                          height: 88,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.16),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(.3), width: 2),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(.3),
                                  blurRadius: 36,
                                  offset: const Offset(0, 12))
                            ],
                          ),
                          child: Ico(P.check, size: 44, stroke: Colors.white, sw: 2.6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Attendance Recorded',
                      textAlign: TextAlign.center,
                      style: fd(size: rem(1.5), w: FontWeight.w800, color: Colors.white, height: 1.2)),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: ff(size: rem(.8), color: Colors.white.withOpacity(.6), height: 1.6),
                        children: [
                          const TextSpan(text: "You’re checked in for "),
                          TextSpan(
                              text: eventName,
                              style: ff(size: rem(.8), w: FontWeight.w700, color: Colors.white, height: 1.6)),
                          const TextSpan(text: ' . Enjoy the programme!'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // timestamp chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(.18)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Ico(P.clock, size: 13, stroke: Colors.white, sw: 1.8),
                        const SizedBox(width: 6),
                        Text(checkedTime.isEmpty ? 'Checked in' : 'Checked in · $checkedTime',
                            style: mono(size: rem(.66), w: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Btn('View Programme',
                      kind: BtnKind.white, leading: P.arrowRight, onTap: () => go('s12'), margin: 8),
                  _OutlineBtn(
                    label: 'My Attendance History',
                    icon: P.file,
                    onTap: () => go('s33'),
                  ),
                  Press(
                    onTap: () => go('s03'),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text('Back to Home',
                          textAlign: TextAlign.center,
                          style: ff(size: rem(.7), w: FontWeight.w600, color: Colors.white.withOpacity(.6))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double s, Color c) =>
      Container(width: s, height: s, decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  Widget _dot({required double top, required double left, required double size, required Color color, required double radius}) {
    return Align(
      alignment: Alignment(left * 2 - 1, top * 2 - 1),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radius)),
      ),
    );
  }
}

/// Translucent white-outline button (rgba(255,255,255,.15) bg, white text).
class _OutlineBtn extends StatelessWidget {
  final String label;
  final String icon;
  final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Press(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Ico(icon, size: 16, stroke: Colors.white, sw: 2),
            const SizedBox(width: 8),
            Flexible(
              child: Text(label,
                  textAlign: TextAlign.center,
                  style: ff(size: rem(.82), w: FontWeight.w700, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
