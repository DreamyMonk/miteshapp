import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

const _mon35 = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

DateTime? _iso35(String s) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(s);
  if (m == null) return null;
  return DateTime(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
}

String _dmy35(DateTime d) => '${d.day} ${_mon35[d.month - 1]} ${d.year}';

const _arrowBack =
    '<line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/>';
const _check = '<polyline points="20 6 9 17 4 12"/>';
const _refreshNext =
    '<polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/>';
const _fileLines =
    '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/>';
const _flower =
    '<circle cx="12" cy="12" r="2.5"/><path d="M12 9.5c0-2 1.5-3.5 0-5.5-1.5 2-1.5 3.5 0 5.5M12 14.5c0 2-1.5 3.5 0 5.5 1.5-2 1.5-3.5 0-5.5M9.5 12c-2 0-3.5 1.5-5.5 0 2-1.5 3.5-1.5 5.5 0M14.5 12c2 0 3.5-1.5 5.5 0-2 1.5-3.5 1.5-5.5 0"/>';

class S35 extends StatelessWidget {
  const S35({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppData.I.selectedCommunity;
    final name = c != null ? '${c['name'] ?? ''}' : '';
    final editionLabel = c != null ? '${c['editionLabel'] ?? ''}' : '';
    final venue = c != null ? '${c['venue'] ?? ''}' : '';
    final start = c == null ? null : _iso35('${c['editionStart'] ?? ''}');
    final end = c == null ? null : _iso35('${c['editionEnd'] ?? ''}');
    final recurrence = c != null ? '${c['recurrence'] ?? ''}' : '';

    // Real stats derived from the store (no fabricated numbers).
    final progs = name.isEmpty ? const [] : AppData.I.programsOfCommunity(name);
    final totalEvents = progs.length;
    final attended = AppData.I.checkIns
        .where((r) => progs.any((p) => '${p['title'] ?? ''}'.toLowerCase() == r.event.toLowerCase()))
        .length;
    final days = (start != null && end != null) ? (end.difference(start).inDays + 1).clamp(0, 999) : 0;

    return Container(
      color: K.cream,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.7, -1),
                end: Alignment(0.7, 1),
                colors: [Color(0xFF1A0E3D), Color(0xFF3D2582)],
              ),
            ),
            child: Row(
              children: [
                Press(
                  onTap: () => go('s09'),
                  dx: -3,
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    child: Ico(_arrowBack, size: 18, stroke: Colors.white, sw: 2),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text('Edition Ended',
                      style: fd(size: rem(1.05), w: FontWeight.w800, color: Colors.white)),
                ),
              ],
            ),
          ),
          Sc(
            padding: const EdgeInsets.all(18),
            cross: CrossAxisAlignment.stretch,
            [
              // Centered hero
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 18, 0, 14),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(colors: [
                              const Color(0xFF7C5CBF).withOpacity(.15),
                              Colors.transparent,
                            ], stops: const [0, .7]),
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFEDE6F7), Color(0xFFF7F4FC)],
                            ),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: K.bd2),
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFF5C3E9E).withOpacity(.18),
                                  blurRadius: 28,
                                  offset: const Offset(0, 10)),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Ico(_check, size: 38, stroke: K.t5, sw: 1.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text('This Edition Has Ended',
                        style: fd(size: rem(1.2), w: FontWeight.w800, color: K.ink),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: ff(size: rem(.72), color: K.ink3, height: 1.55),
                          children: [
                            TextSpan(
                                text: [
                                  if (name.isNotEmpty) name,
                                  if (editionLabel.isNotEmpty) editionLabel,
                                ].join(' · '),
                                style: ff(size: rem(.72), w: FontWeight.w700, color: K.ink, height: 1.55)),
                            if (venue.isNotEmpty) TextSpan(text: ' at $venue'),
                            const TextSpan(text: ' concluded'),
                            if (end != null) ...[
                              const TextSpan(text: ' on '),
                              TextSpan(
                                  text: _dmy35(end),
                                  style: ff(size: rem(.72), w: FontWeight.w700, color: K.g5, height: 1.55)),
                            ],
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Subscription still active message
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF16A34A), Color(0xFF15803D)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Ico(_check, size: 13, stroke: Colors.white, sw: 2.4),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text('Your subscription is still active',
                              style: ff(size: rem(.74), w: FontWeight.w800, color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                        "You'll be notified when the next edition starts — at the same venue or anywhere else. No need to re-subscribe.",
                        style: ff(size: rem(.6), color: Colors.white.withOpacity(.95), height: 1.55)),
                  ],
                ),
              ),

              // Stats card
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    _statBox('$attended', 'Attended', const Color(0xFF16A34A)),
                    const SizedBox(width: 8),
                    _statBox('$totalEvents', 'Total Events', K.t7),
                    const SizedBox(width: 8),
                    _statBox('$days', 'Days', K.g5),
                  ],
                ),
              ),

              // Next edition planned card.
              CardX(
                bg: K.in1,
                border: Border.all(color: const Color(0xFF1D4ED8).withOpacity(.18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row: label + status badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
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
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D4ED8).withOpacity(.15),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(recurrence.isNotEmpty ? recurrence : 'when announced',
                              style: ff(size: rem(.54), w: FontWeight.w700, color: K.inC)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                        recurrence.isNotEmpty
                            ? 'Next edition · $recurrence'
                            : 'Next edition to be announced',
                        style: ff(size: rem(.74), w: FontWeight.w700, color: K.ink)),
                    const SizedBox(height: 3),
                    Text(
                        venue.isNotEmpty
                            ? 'Same or a new venue · $venue'
                            : 'Venue to be announced',
                        style: mono(size: rem(.58), color: K.ink3)),
                    const SizedBox(height: 5),
                    Text("You’ll get a notification 2 weeks before it begins.",
                        style: ff(size: rem(.54), color: K.inC, height: 1.5)),
                  ],
                ),
              ),

              // Actions
              Btn('View Past Attendance',
                  kind: BtnKind.p, leading: _fileLines, onTap: () => go('s33')),
              Btn('My Communities', kind: BtnKind.s, leading: _flower, onTap: () => go('s09')),
              Btn('Back to Home', kind: BtnKind.o, margin: 0, onTap: () => go('s03')),
              const SizedBox(height: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String num, String label, Color numC) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: K.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: K.bd),
        ),
        child: Column(
          children: [
            Text(num, style: mono(size: rem(1.2), w: FontWeight.w800, color: numC)),
            const SizedBox(height: 1),
            Text(label,
                style: ff(size: rem(.5), w: FontWeight.w700, color: K.ink3), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
