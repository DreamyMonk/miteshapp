import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';
import 's26_dayevents.dart' show s26Iso;

const _chevL = '<polyline points="15 18 9 12 15 6"/>';
const _chevR = '<polyline points="9 18 15 12 9 6"/>';
const _infoIcon =
    '<circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/>';

const _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

int _daysInMonth(int year, int month0) => DateTime(year, month0 + 2, 0).day;

Color _hex(String h, [Color fallback = const Color(0xFF7C5CBF)]) {
  final s = h.replaceAll('#', '');
  if (s.length != 6) return fallback;
  final v = int.tryParse(s, radix: 16);
  return v == null ? fallback : Color(0xFF000000 | v);
}

class S25 extends StatefulWidget {
  const S25({super.key});
  @override
  State<S25> createState() => _S25State();
}

class _S25State extends State<S25> {
  late int _year; // displayed year
  late int _month; // displayed month, 0-based

  @override
  void initState() {
    super.initState();
    final t = AppData.todayDate;
    _year = t.year;
    _month = t.month - 1;
  }

  void _setMonth(int y, int m) => setState(() {
        _year = y;
        _month = m;
      });

  void _shift(int delta) {
    var m = _month + delta, y = _year;
    while (m < 0) {
      m += 12;
      y--;
    }
    while (m > 11) {
      m -= 12;
      y++;
    }
    _setMonth(y, m);
  }

  // Live dot colors per day: purple for host programmes + colorHex per user event.
  Map<int, List<Color>> _dots() {
    final map = <int, List<Color>>{};
    final dim = _daysInMonth(_year, _month);
    for (var d = 1; d <= dim; d++) {
      final iso = AppData.isoOf(DateTime(_year, _month + 1, d));
      final colors = <Color>[];
      if (AppData.I.liveProgramsForIso(iso).isNotEmpty) colors.add(K.t5);
      for (final e in AppData.I.eventsForIso(iso)) {
        colors.add(_hex(e.colorHex));
      }
      if (colors.isNotEmpty) map[d] = colors;
    }
    return map;
  }

  // 4-month rolling window; the displayed month sits 3rd (mirrors the HTML's
  // April / May / June* / July layout) but is fully relative to the real date.
  List<Widget> _tabs() {
    final out = <Widget>[];
    for (var i = -2; i <= 1; i++) {
      var m = _month + i, y = _year;
      while (m < 0) {
        m += 12;
        y--;
      }
      while (m > 11) {
        m -= 12;
        y++;
      }
      final yy = y, mm = m;
      out.add(i == 0
          ? TabPill(_months[mm], on: true)
          : TabPill(_months[mm], onTap: () => _setMonth(yy, mm)));
      if (i < 1) out.add(const SizedBox(width: 7));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final dots = _dots();
    final first = DateTime(_year, _month + 1, 1).weekday % 7;
    final dim = _daysInMonth(_year, _month);

    final cells = <Widget>[];
    for (var b = 0; b < first; b++) {
      cells.add(const SizedBox.shrink());
    }
    for (var d = 1; d <= dim; d++) {
      final day = d;
      cells.add(_DayCell(
        day: day,
        dots: dots[day],
        onTap: () {
          s26Iso = AppData.isoOf(DateTime(_year, _month + 1, day));
          go((dots[day] != null && dots[day]!.isNotEmpty) ? 's26' : 's27');
        },
      ));
    }

    return Container(
      color: K.cream,
      child: Column(
        children: [
          AppBarX(
            title: 'My Calendar',
            sub: 'Switch months easily',
            back: 's24',
            onBack: () => go('s24'),
          ),
          // ── Month tabs (live rolling window) ──────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: K.white,
              border: Border(bottom: BorderSide(color: K.bd)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: _tabs()),
            ),
          ),
          // ── Calendar body ─────────────────────────────────────────────
          Sc(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IbBtn(_chevL, onTap: () => _shift(-1), iconSize: 16),
                  Text('${_months[_month]} $_year',
                      style: fd(size: rem(1.1), w: FontWeight.w800, color: K.ink)),
                  IbBtn(_chevR, onTap: () => _shift(1), iconSize: 16),
                ],
              ),
              const SizedBox(height: 14),
              const _WeekdayRow(),
              const SizedBox(height: 6),
              GridView.count(
                crossAxisCount: 7,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: cells,
              ),
              const SizedBox(height: 14),
              // Info hint
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                decoration: BoxDecoration(
                  color: K.t0,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: K.t1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Ico(_infoIcon, size: 14, stroke: K.t7, sw: 1.8),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Tap any month tab or use the arrows to switch. Tap a date to see that day's events.",
                        style: ff(size: rem(.68), color: K.t7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow();
  @override
  Widget build(BuildContext context) {
    const wd = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      children: wd
          .map((w) => Expanded(
                child: Center(
                  child: Text(w, style: ff(size: rem(.56), w: FontWeight.w700, color: K.ink4)),
                ),
              ))
          .toList(),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final List<Color>? dots;
  final VoidCallback onTap;
  const _DayCell({required this.day, required this.dots, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasDots = dots != null && dots!.isNotEmpty;
    return Press(
      scale: .92,
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: hasDots ? K.t0 : K.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: hasDots ? K.t1 : K.bd),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$day',
                  style: mono(size: rem(.78), w: hasDots ? FontWeight.w800 : FontWeight.w600, color: K.ink2)),
              if (hasDots)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: SizedBox(
                    height: 4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: dots!
                          .take(4)
                          .map((c) => Container(
                                width: 3.5,
                                height: 3.5,
                                margin: const EdgeInsets.symmetric(horizontal: .75),
                                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                              ))
                          .toList(),
                    ),
                  ),
                )
              else
                const SizedBox(height: 7),
            ],
          ),
        ),
      ),
    );
  }
}
