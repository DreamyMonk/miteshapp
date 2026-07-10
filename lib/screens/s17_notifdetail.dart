import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

const Map<String, String> _typeSource = {
  'reminder': 'Reminder',
  'event': 'Calendar update',
  'rsvp': 'RSVP',
  'attendance': 'Attendance',
  'community': 'Community update',
  'push': 'Announcement',
  'system': 'Notification',
};

String _agoOf(String iso) {
  final t = DateTime.tryParse(iso);
  if (t == null) return '';
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'Just now';
  if (d.inMinutes < 60) return '${d.inMinutes} min ago';
  if (d.inHours < 24) return '${d.inHours} hr${d.inHours > 1 ? 's' : ''} ago';
  if (d.inDays == 1) return 'Yesterday';
  if (d.inDays < 7) return '${d.inDays} days ago';
  return '${d.inDays ~/ 7} wk ago';
}

class S17 extends StatelessWidget {
  const S17({super.key});
  @override
  Widget build(BuildContext context) {
    final n = AppData.I.selectedNotification;
    final source = n == null ? 'Notification' : (_typeSource[n.type] ?? 'Notification');
    final ago = n == null ? '' : _agoOf(n.iso);
    final title = (n != null && n.title.isNotEmpty) ? n.title : 'Update';
    final body = n?.body ?? '';
    return Container(
      color: K.cream,
      child: Column(
        children: [
          AppBarX(
            title: 'Update',
            back: 's16',
            onBack: () => go('s16'),
          ),
          Sc(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            [
              // header row: icon tile + source + time
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [K.t7, K.t5],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Ico(P.venue, size: 18, stroke: Colors.white, sw: 1.8)),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(source,
                            style: ff(size: rem(.8), w: FontWeight.w700, color: K.ink)),
                        if (ago.isNotEmpty) Text(ago, style: ff(size: rem(.6), color: K.ink3)),
                      ],
                    ),
                  ],
                ),
              ),
              CardX(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: body.isNotEmpty ? 8 : 0),
                      child: Text(title,
                          style: fd(size: rem(1.05), w: FontWeight.w800, color: K.ink)),
                    ),
                    if (body.isNotEmpty)
                      Text(body, style: ff(size: rem(.78), color: K.ink3, height: 1.6)),
                  ],
                ),
              ),
              Btn('View Programme', kind: BtnKind.p, onTap: () => go('s12')),
              Btn('Back to Notifications', kind: BtnKind.s, onTap: () => go('s16')),
            ],
          ),
        ],
      ),
    );
  }
}
