import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

class S30 extends StatelessWidget {
  const S30({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [K.t9, K.t7, K.t5],
        ),
      ),
      child: Stack(
        children: [
          // ambient glows
          Positioned(
            top: -60,
            right: -50,
            child: _circle(200, const Color(0xFFF5A623).withOpacity(.08)),
          ),
          Positioned(
            bottom: -80,
            left: -50,
            child: _circle(240, const Color(0xFF7C5CBF).withOpacity(.16)),
          ),
          // confetti dots
          _dot(top: .24, left: .18, size: 8, color: const Color(0xFFF5A623), radius: 2),
          _dot(top: .20, left: .74, size: 7, color: const Color(0xFF86EFAC), radius: 99),
          _dot(top: .30, left: .30, size: 6, color: const Color(0xFFC4AEE8), radius: 2),
          _dot(top: .18, left: .55, size: 8, color: const Color(0xFFF5A623), radius: 99),
          _dot(top: .26, left: .86, size: 6, color: const Color(0xFF86EFAC), radius: 2),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // check ring with expanding pulses
                  SizedBox(
                    width: 104,
                    height: 104,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF86EFAC).withOpacity(.5), width: 2),
                          ),
                        ),
                        Container(
                          width: 88,
                          height: 88,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [K.ok, Color(0xFF15803D)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFF16A34A).withOpacity(.5),
                                  blurRadius: 36,
                                  offset: const Offset(0, 12))
                            ],
                          ),
                          child: Ico(P.check, size: 42, stroke: Colors.white, sw: 2.6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Profile Updated',
                      textAlign: TextAlign.center,
                      style: fd(size: rem(1.5), w: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 270),
                    child: Text('Your profile details have been saved successfully.',
                        textAlign: TextAlign.center,
                        style: ff(size: rem(.8), color: Colors.white.withOpacity(.55), height: 1.6)),
                  ),
                  const SizedBox(height: 24),
                  Btn('Back to Profile',
                      kind: BtnKind.white, leading: P.user, onTap: () => go('s21'), margin: 0),
                  Press(
                    onTap: () => go('s03'),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text('Go to Home',
                          textAlign: TextAlign.center,
                          style: ff(size: rem(.7), w: FontWeight.w600, color: Colors.white.withOpacity(.5))),
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
