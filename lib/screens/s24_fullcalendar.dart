import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';
import 's26_dayevents.dart' show s26Iso;

const _mNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];
const _monthsShort = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

int _daysInMonth(int year, int month0) => DateTime(year, month0 + 2, 0).day;

Color _hex(String h, [Color fallback = const Color(0xFF7C5CBF)]) {
  final s = h.replaceAll('#', '');
  if (s.length != 6) return fallback;
  final v = int.tryParse(s, radix: 16);
  return v == null ? fallback : Color(0xFF000000 | v);
}

const _chevL = '<polyline points="15 18 9 12 15 6"/>';
const _chevR = '<polyline points="9 18 15 12 9 6"/>';

class S24 extends StatefulWidget {
  const S24({super.key});
  @override
  State<S24> createState() => _S24State();
}

class _S24State extends State<S24> {
  late int _month; // 0-indexed
  late int _year;

  @override
  void initState() {
    super.initState();
    final t = AppData.todayDate;
    _year = t.year;
    _month = t.month - 1;
    AppData.I.addListener(_onData);
  }

  @override
  void dispose() {
    AppData.I.removeListener(_onData);
    super.dispose();
  }

  void _onData() {
    if (mounted) setState(() {});
  }

  void _shift(int dir) {
    setState(() {
      _month += dir;
      if (_month > 11) {
        _month = 0;
        _year++;
      } else if (_month < 0) {
        _month = 11;
        _year--;
      }
    });
  }

  void _yearShift(int dir) => setState(() => _year += dir);

  /// Day → dot colors for the visible real month:
  /// purple for host programmes + colorHex per user event.
  Map<int, List<Color>> _dotsForMonth() {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: K.cream,
      child: Column(
        children: [
          AppBarX(
            title: 'My Calendar',
            sub: 'All subscribed communities',
            back: 's03',
            onBack: () => go('s03'),
          ),
          // ── Year stepper ─────────────────────────────────────────────
          Container(
            color: K.white,
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _stepBtn(_chevL, () => _yearShift(-1)),
                const SizedBox(width: 14),
                SizedBox(
                  width: 54,
                  child: Text('$_year',
                      textAlign: TextAlign.center,
                      style: mono(size: rem(1), w: FontWeight.w700, color: K.t7, ls: .5)),
                ),
                const SizedBox(width: 14),
                _stepBtn(_chevR, () => _yearShift(1)),
              ],
            ),
          ),
          // ── Month tabs ───────────────────────────────────────────────
          Container(
            color: K.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: K.white,
              border: Border(bottom: BorderSide(color: K.bd)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(12, (m) {
                  return Padding(
                    padding: EdgeInsets.only(right: m < 11 ? 7 : 0),
                    child: TabPill(
                      _monthsShort[m],
                      on: m == _month,
                      onTap: () => setState(() => _month = m),
                    ),
                  );
                }),
              ),
            ),
          ),
          // ── Calendar body ────────────────────────────────────────────
          Sc(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IbBtn(_chevL, onTap: () => _shift(-1), iconSize: 16),
                  Text('${_mNames[_month]} $_year',
                      style: fd(size: rem(1.1), w: FontWeight.w800, color: K.ink)),
                  IbBtn(_chevR, onTap: () => _shift(1), iconSize: 16),
                ],
              ),
              const SizedBox(height: 14),
              const _WeekdayRow(),
              const SizedBox(height: 6),
              _MonthGrid(year: _year, month: _month, events: _dotsForMonth()),
              const SizedBox(height: 14),
              const _Legend(),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepBtn(String inner, VoidCallback onTap) => Press(
        scale: .9,
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: K.t0,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: K.t1),
          ),
          child: Center(child: Ico(inner, size: 15, stroke: K.t7, sw: 2.2)),
        ),
      );
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

// ── Full month grid (port of buildCal27) ─────────────────────────────────────
class _MonthGrid extends StatelessWidget {
  final int year;
  final int month; // 0-indexed
  final Map<int, List<Color>> events;
  const _MonthGrid({required this.year, required this.month, required this.events});

  @override
  Widget build(BuildContext context) {
    final first = DateTime(year, month + 1, 1).weekday % 7; // Sun=0
    final dim = _daysInMonth(year, month);
    final today = AppData.todayDate;

    final cells = <Widget>[];
    for (var b = 0; b < first; b++) {
      cells.add(const SizedBox.shrink());
    }
    for (var d = 1; d <= dim; d++) {
      final dots = events[d];
      final isToday = year == today.year && month == today.month - 1 && d == today.day;
      cells.add(_DayCell(year: year, month: month, day: d, dots: dots, isToday: isToday));
    }

    return GridView.count(
      crossAxisCount: 7,
      mainAxisSpacing: 3,
      crossAxisSpacing: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cells,
    );
  }
}

class _DayCell extends StatelessWidget {
  final int year;
  final int month; // 0-indexed
  final int day;
  final List<Color>? dots;
  final bool isToday;
  const _DayCell(
      {required this.year,
      required this.month,
      required this.day,
      required this.dots,
      required this.isToday});

  @override
  Widget build(BuildContext context) {
    final hasDots = dots != null && dots!.isNotEmpty;
    final col = isToday ? Colors.white : K.ink2;

    return Press(
      scale: .92,
      onTap: () {
        s26Iso = AppData.isoOf(DateTime(year, month + 1, day));
        go(hasDots ? 's26' : 's27');
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            gradient: isToday
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7C5CBF), Color(0xFF3D2582)])
                : null,
            color: isToday
                ? null
                : hasDots
                    ? K.t0
                    : K.white,
            borderRadius: BorderRadius.circular(11),
            border: isToday
                ? null
                : Border.all(color: hasDots ? K.t1 : K.bd),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$day', style: mono(size: rem(.78), w: isToday || hasDots ? FontWeight.w800 : FontWeight.w600, color: col)),
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
                                decoration:
                                    BoxDecoration(color: isToday ? Colors.white : c, shape: BoxShape.circle),
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

class _Legend extends StatelessWidget {
  const _Legend();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: K.bd))),
      child: Wrap(
        spacing: 14,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Dots = events that day',
              style: ff(size: rem(.58), w: FontWeight.w700, color: K.ink4, ls: .5)),
          _legendItem([K.t5], '1'),
          _legendItem([K.t5, K.g4], '2'),
          _legendItem([K.t5, K.g4, K.ok, K.inC], '3+'),
        ],
      ),
    );
  }

  Widget _legendItem(List<Color> colors, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: colors
              .map((c) => Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(right: 1.5),
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                  ))
              .toList(),
        ),
        const SizedBox(width: 4),
        Text(label, style: ff(size: rem(.6), color: K.ink3)),
      ],
    );
  }
}
