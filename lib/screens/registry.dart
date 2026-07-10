import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../widgets/common.dart';
import 's01_splash.dart';
import 's02_login.dart';
import 's03_home.dart';
import 's04_search.dart';
import 's05_results.dart';
import 's06_venue.dart';
import 's07_subscribe.dart';
import 's08_success.dart';
import 's09_communities.dart';
import 's10_calendar.dart';
import 's11_programmes.dart';
import 's12_detail.dart';
import 's13_live.dart';
import 's14_saved.dart';
import 's15_reminder.dart';
import 's16_notifications.dart';
import 's17_notifdetail.dart';
import 's18_support.dart';
import 's19_share.dart';
import 's20_profile.dart';
import 's21_subscriptions.dart';
import 's22_settings.dart';
import 's23_host.dart';
import 's24_fullcalendar.dart';
import 's25_monthswitch.dart';
import 's26_dayevents.dart';
import 's27_dayempty.dart';
import 's28_results.dart';
import 's29_editprofile.dart';
import 's30_profileupdated.dart';
import 's31_qrscanner.dart';
import 's32_recorded.dart';
import 's33_attendance.dart';
import 's34_community.dart';
import 's35_editionended.dart';
import 's36_addtype.dart';
import 's37_manualform.dart';
import 's38_aiscan.dart';
import 's39_logs.dart';

/// Maps a screen id ('s01'..'s39') to its widget. Unbuilt screens fall back to
/// a placeholder so the app always runs.
Widget buildScreen(String id) {
  final b = _registry[id];
  if (b != null) return b();
  return _Placeholder(id: id);
}

final Map<String, Widget Function()> _registry = {
  's01': () => const S01(),
  's02': () => const S02(),
  's03': () => const S03(),
  's04': () => const S04(),
  's05': () => const S05(),
  's06': () => const S06(),
  's07': () => const S07(),
  's08': () => const S08(),
  's09': () => const S09(),
  's10': () => const S10(),
  's11': () => const S11(),
  's12': () => const S12(),
  's13': () => const S13(),
  's14': () => const S14(),
  's15': () => const S15(),
  's16': () => const S16(),
  's17': () => const S17(),
  's18': () => const S18(),
  's19': () => const S19(),
  's20': () => const S20(),
  's21': () => const S21(),
  's22': () => const S22(),
  's23': () => const S23(),
  's24': () => const S24(),
  's25': () => const S25(),
  's26': () => const S26(),
  's27': () => const S27(),
  's28': () => const S28(),
  's29': () => const S29(),
  's30': () => const S30(),
  's31': () => const S31(),
  's32': () => const S32(),
  's33': () => const S33(),
  's34': () => const S34(),
  's35': () => const S35(),
  's36': () => const S36(),
  's37': () => const S37(),
  's38': () => const S38(),
  's39': () => const S39(),
};

class _Placeholder extends StatelessWidget {
  final String id;
  const _Placeholder({required this.id});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: K.cream,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(id.toUpperCase(), style: fd(size: rem(1.6), color: K.t7)),
            const SizedBox(height: 8),
            Text('Screen coming up', style: ff(size: rem(.8), color: K.ink3)),
            const SizedBox(height: 16),
            Btn('Back to Home',
                kind: BtnKind.s,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                onTap: () => go('s03')),
          ],
        ),
      ),
    );
  }
}
