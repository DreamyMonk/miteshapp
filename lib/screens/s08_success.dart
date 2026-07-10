import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

const _mon = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

// '2026-05-20' + '2026-05-28' → '20 May – 28 May 2026' (empty-safe).
String _fmtWindow(String start, String end) {
  RegExpMatch? p(String s) => RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(s);
  final a = p(start), b = p(end);
  String dm(RegExpMatch m) => '${int.parse(m.group(3)!)} ${_mon[(int.parse(m.group(2)!) - 1).clamp(0, 11)]}';
  String dmy(RegExpMatch m) => '${dm(m)} ${m.group(1)}';
  if (a != null && b != null) return '${dm(a)} – ${dmy(b)}';
  if (a != null) return dmy(a);
  if (b != null) return 'till ${dmy(b)}';
  return '';
}

class S08 extends StatelessWidget {
  const S08({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppData.I.selectedCommunity;
    final name = (c != null && '${c['name'] ?? ''}'.isNotEmpty) ? '${c['name']}' : 'this community';
    final window =
        c == null ? '' : _fmtWindow('${c['editionStart'] ?? ''}', '${c['editionEnd'] ?? ''}');
    return Container(
      decoration: const BoxDecoration(
        // 160deg #052E16 -> #166534 -> #16A34A
        gradient: LinearGradient(
          begin: Alignment(-0.2, -1),
          end: Alignment(0.2, 1),
          colors: [Color(0xFF052E16), Color(0xFF166534), Color(0xFF16A34A)],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Decorative blob
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Check ring (.fst-ring)
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(.14),
                      border: Border.all(color: Colors.white.withOpacity(.25), width: 2),
                    ),
                    child: Center(
                      child: Ico(P.check, size: 34, stroke: Colors.white, sw: 2.2),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Title with sparkle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Subscribed!',
                          style: fd(size: rem(1.45), w: FontWeight.w800, color: Colors.white)),
                      const SizedBox(width: 6),
                      Ico(P.sparkle, size: 20, stroke: Colors.white, sw: 2),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Body text (.fst-body — max-width 280, white .55)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: ff(
                            size: rem(.78),
                            color: Colors.white.withOpacity(.55),
                            height: 1.55),
                        children: [
                          const TextSpan(text: "You're now subscribed to "),
                          TextSpan(
                              text: name,
                              style: ff(
                                  size: rem(.78),
                                  w: FontWeight.w700,
                                  color: K.g2,
                                  height: 1.55)),
                          const TextSpan(
                              text:
                                  ". You'll get every edition's schedule — at any venue."),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Current Edition info box (max-width 280, width 90%)
                  Container(
                    constraints: const BoxConstraints(maxWidth: 280),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.12),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: K.g2.withOpacity(.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Ico(P.clock, size: 12, stroke: K.g2, sw: 1.9),
                            const SizedBox(width: 6),
                            Text('CURRENT EDITION',
                                style: ff(
                                    size: rem(.58),
                                    w: FontWeight.w700,
                                    color: K.g2,
                                    ls: .5)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(window.isNotEmpty ? window : 'Active now',
                            textAlign: TextAlign.center,
                            style: mono(size: rem(.68), w: FontWeight.w500, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(
                          "Subscription stays active across all editions. We'll notify you when the next edition starts · anywhere.",
                          textAlign: TextAlign.center,
                          style: ff(
                              size: rem(.54),
                              color: Colors.white.withOpacity(.55),
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // View My Calendar button (.fst-close)
                  Press(
                    onTap: () => go('s10'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.16),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(.22)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('View My Calendar',
                              style: ff(
                                  size: rem(.78),
                                  w: FontWeight.w700,
                                  color: Colors.white)),
                          const SizedBox(width: 6),
                          Ico(P.arrowRight, size: 12, stroke: Colors.white, sw: 2.5),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Back to Home
                  Press(
                    scale: .97,
                    onTap: () => go('s03'),
                    child: Text('Back to Home',
                        style: ff(size: rem(.66), color: Colors.white.withOpacity(.5))),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
