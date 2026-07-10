import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';

const double kPhoneW = 390;
const double kPhoneH = 848;

/// The dark prototype backdrop + the phone device frame, centered and scaled
/// to fit the viewport.
class PhoneFrame extends StatelessWidget {
  final Widget child;
  const PhoneFrame({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: K.phoneBg,
        gradient: RadialGradient(
          center: Alignment(-0.9, -1),
          radius: 1.1,
          colors: [Color(0x335B3E9E), Color(0x000C0918)],
          stops: [0, .6],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Container(
              width: kPhoneW,
              height: kPhoneH,
              decoration: BoxDecoration(
                color: K.cream,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: const Color(0xFF7C5CBF).withOpacity(.18), width: 2),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF0C0918).withOpacity(.96), blurRadius: 0, spreadRadius: 10),
                  BoxShadow(color: Colors.black.withOpacity(.9), blurRadius: 100, offset: const Offset(0, 40)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(48),
                child: Column(
                  children: [
                    const _Notch(),
                    const _StatusBar(),
                    Expanded(child: child),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Notch extends StatelessWidget {
  const _Notch();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 112,
        height: 26,
        decoration: BoxDecoration(
          color: K.cream,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(17)),
          border: Border.all(color: const Color(0xFF7C5CBF).withOpacity(.13), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFF7C5CBF).withOpacity(.22), shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Container(width: 34, height: 4, decoration: BoxDecoration(color: const Color(0xFF7C5CBF).withOpacity(.14), borderRadius: BorderRadius.circular(2))),
          ],
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 2, 22, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('9:41', style: ff(size: rem(.62), w: FontWeight.w700, color: K.ink3)),
          Text('▐▐▐ ⬤⬤', style: ff(size: rem(.54), w: FontWeight.w700, color: K.ink3, ls: 1)),
        ],
      ),
    );
  }
}

/// Toast overlay (.mt)
class ToastLayer extends StatelessWidget {
  const ToastLayer({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: AppController.I.toast,
      builder: (_, msg, __) {
        return IgnorePointer(
          child: AnimatedOpacity(
            opacity: msg == null ? 0 : 1,
            duration: const Duration(milliseconds: 180),
            child: Align(
              alignment: const Alignment(0, .82),
              child: msg == null
                  ? const SizedBox.shrink()
                  : Container(
                      constraints: const BoxConstraints(maxWidth: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(color: K.ink, borderRadius: BorderRadius.circular(12)),
                      child: Text(msg,
                          textAlign: TextAlign.center,
                          style: ff(size: rem(.75), w: FontWeight.w600, color: Colors.white)),
                    ),
            ),
          ),
        );
      },
    );
  }
}
