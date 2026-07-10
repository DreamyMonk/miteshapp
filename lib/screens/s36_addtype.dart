import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

const _camera =
    '<path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/>';
const _pencil =
    '<path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>';

class S36 extends StatelessWidget {
  const S36({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: K.cream,
      child: Column(
        children: [
          AppBarX(title: 'Add Private Event', sub: 'Pick how to add', onBack: () => go('s03')),
          Sc(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            [
              Text(
                "Add a personal event — wedding you're attending, a meeting, a birthday, anything.",
                style: ff(size: rem(.62), color: K.ink3, height: 1.5),
              ),
              const SizedBox(height: 13),

              // AI Scan
              Press(
                scale: .98,
                onTap: () => go('s38'),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 11),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [K.t7, K.t5]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // decorative radial glow (top-right)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [Colors.white.withOpacity(.1), Colors.white.withOpacity(0)],
                              stops: const [0, .7],
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.2),
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(color: Colors.white.withOpacity(.3)),
                            ),
                            child: Center(child: Ico(_camera, size: 22, stroke: Colors.white, sw: 1.8)),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('AI Scan', style: fd(size: rem(.95), w: FontWeight.w700, color: Colors.white)),
                                    const SizedBox(width: 5),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        gradient: K.gGold,
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: Text('SMART',
                                          style: ff(size: rem(.5), w: FontWeight.w700, color: Colors.white, ls: .3)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text('Upload invitation card — auto-extract dates & details',
                                    style: ff(size: rem(.6), color: Colors.white.withOpacity(.9), height: 1.4)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Ico(P.chevR, size: 14, stroke: Colors.white, sw: 2.4),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Add Manually
              Press(
                scale: .98,
                onTap: () => go('s37'),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: K.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: K.bd, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [K.t6, K.t4]),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Center(child: Ico(_pencil, size: 22, stroke: Colors.white, sw: 1.8)),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Add Manually', style: fd(size: rem(.95), w: FontWeight.w700, color: K.ink)),
                            const SizedBox(height: 2),
                            Text('Fill details yourself — quick & precise',
                                style: ff(size: rem(.6), color: K.ink3, height: 1.4)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Ico(P.chevR, size: 14, stroke: K.ink4, sw: 2.2),
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
}
