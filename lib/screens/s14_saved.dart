import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

// 'YYYY-MM-DD' → 'D Mon' (falls back to the raw string).
String _fmtDate(String iso) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(iso);
  if (m == null) return iso;
  return '${int.parse(m.group(3)!)} ${_months[(int.parse(m.group(2)!) - 1).clamp(0, 11)]}';
}

class S14 extends StatefulWidget {
  const S14({super.key});
  @override
  State<S14> createState() => _S14State();
}

class _S14State extends State<S14> {
  void _onData() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    AppData.I.addListener(_onData);
  }

  @override
  void dispose() {
    AppData.I.removeListener(_onData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Live programmes the user has bookmarked (by title).
    final saved = AppData.I.livePrograms
        .where((p) => AppData.I.saved.contains('${p['title'] ?? ''}'))
        .toList();

    return Container(
      color: K.white,
      child: Column(
        children: [
          AppBarX(
            title: 'Saved Programmes',
            sub: 'Your bookmarks',
            onBack: () => go('s03'),
          ),
          Sc(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            [
              // Live saved programmes (border-left alternates t5 / g4 to match
              // the approved design's colour variety).
              for (int i = 0; i < saved.length; i++)
                _savedCard(saved[i], i.isOdd ? K.g4 : K.t5),
              // Persistent tap-hint line (shown alone when nothing is saved).
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text('Tap the bookmark icon on any programme to save it here.',
                      textAlign: TextAlign.center,
                      style: ff(size: rem(.7), color: K.ink4)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _savedCard(Map<String, dynamic> p, Color accent) {
    final title = '${p['title'] ?? ''}';
    final community = '${p['communityName'] ?? ''}';
    final venue = '${p['venue'] ?? ''}';
    final when = '${_fmtDate('${p['date'] ?? ''}')} · ${p['time'] ?? ''}';
    final sub = [if (community.isNotEmpty) community, if (venue.isNotEmpty) venue, when].join(' · ');

    return Press(
      scale: .98,
      onTap: () {
        AppData.I.selectedProgram = p;
        go('s12');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: K.white,
          borderRadius: BorderRadius.circular(13),
          border: Border(
            top: BorderSide(color: K.bd),
            right: BorderSide(color: K.bd),
            bottom: BorderSide(color: K.bd),
            left: BorderSide(color: accent, width: 4),
          ),
          boxShadow: K.sh,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: ff(size: rem(.8), w: FontWeight.w700, color: K.ink)),
                  Text(sub, style: ff(size: rem(.62), color: K.ink3)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Filled bookmark indicator (tap to remove from saved).
            Press(
              scale: .9,
              onTap: () {
                AppData.I.toggleSaved(title);
                toast('Removed from saved');
              },
              child: Ico(P.bookmark, size: 16, stroke: K.t6, fill: K.t6, sw: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
