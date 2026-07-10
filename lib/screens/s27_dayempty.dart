import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';
import 's26_dayevents.dart' show s26Iso;

const _dNames = [
  'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
];
const _monthsShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

/// Parse the shared selected date; default to today when unset/invalid.
DateTime _selectedDate() {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s26Iso);
  if (m == null) return AppData.todayDate;
  return DateTime(
      int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
}

const _calIcon =
    '<rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>';
const _calPlusIcon =
    '$_calIcon<line x1="12" y1="14" x2="12" y2="18"/><line x1="10" y1="16" x2="14" y2="16"/>';
const _searchIcon = '<circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>';
const _plusIcon = '<line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>';

class S27 extends StatelessWidget {
  const S27({super.key});

  @override
  Widget build(BuildContext context) {
    final d = _selectedDate();
    final headerLabel =
        '${_dNames[d.weekday % 7]}, ${d.day} ${_monthsShort[d.month - 1]}';
    return Container(
      color: K.cream,
      child: Column(
        children: [
          // ── Dark header ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
            decoration: const BoxDecoration(gradient: K.gHeader),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BackBtn(onTap: () => go('s24'), dark: false),
                    Press(
                      scale: .9,
                      onTap: () => go('s24'),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.14),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Center(child: Ico(_calIcon, size: 15, stroke: Colors.white, sw: 1.8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(headerLabel, style: fd(size: rem(1.3), w: FontWeight.w800, color: Colors.white)),
                Text('No events this day', style: ff(size: rem(.64), color: Colors.white.withOpacity(.5))),
              ],
            ),
          ),
          // ── Empty state body ─────────────────────────────────────────
          Sc(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            [
              const SizedBox(height: 30),
              // Big calendar icon w/ gold plus badge
              SizedBox(
                width: 108,
                height: 108,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFEDE6F7), Color(0xFFF7F4FC)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: K.bd2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5C3E9E).withOpacity(.16),
                            blurRadius: 34,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Center(child: Ico(_calIcon, size: 50, stroke: K.t5, sw: 1.5)),
                    ),
                    Positioned(
                      bottom: -7,
                      right: -7,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFF5A623), Color(0xFFD97706)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: K.cream, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF5A623).withOpacity(.42),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(child: Ico(_plusIcon, size: 16, stroke: Colors.white, sw: 2.5)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('No Events for This Date',
                  textAlign: TextAlign.center,
                  style: fd(size: rem(1.3), w: FontWeight.w800, color: K.ink)),
              const SizedBox(height: 8),
              Center(
                child: SizedBox(
                  width: 270,
                  child: Text(
                    'There are no programmes from your subscribed communities on this date. Discover more communities or add your own event.',
                    textAlign: TextAlign.center,
                    style: ff(size: rem(.78), color: K.ink3, height: 1.6),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Btn('Discover Venues', kind: BtnKind.p, leading: _searchIcon, onTap: () => go('s04')),
              Btn('Add a Personal Event', kind: BtnKind.s, leading: _calPlusIcon, onTap: () => go('s21'), margin: 0),
              const SizedBox(height: 18),
            ],
          ),
        ],
      ),
    );
  }
}
