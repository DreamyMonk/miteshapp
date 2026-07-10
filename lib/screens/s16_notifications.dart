import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

const _clock = '<circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>';
const _plus = '<line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>';
const _bell = '<path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>';
const _check = '<polyline points="20 6 9 17 4 12"/>';
const _flower =
    '<circle cx="12" cy="12" r="2.5"/><path d="M12 9.5c0-2 1.5-3.5 0-5.5-1.5 2-1.5 3.5 0 5.5M12 14.5c0 2-1.5 3.5 0 5.5 1.5-2 1.5-3.5 0-5.5M9.5 12c-2 0-3.5 1.5-5.5 0 2-1.5 3.5-1.5 5.5 0M14.5 12c2 0 3.5-1.5 5.5 0-2 1.5-3.5 1.5-5.5 0"/>';
const _qr =
    '<path d="M3 7V5a2 2 0 0 1 2-2h2M17 3h2a2 2 0 0 1 2 2v2M21 17v2a2 2 0 0 1-2 2h-2M7 21H5a2 2 0 0 1-2-2v-2"/><line x1="7" y1="12" x2="17" y2="12"/>';
const _send =
    '<line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/>';

class S16 extends StatefulWidget {
  const S16({super.key});
  @override
  State<S16> createState() => _S16State();
}

class _S16State extends State<S16> {
  void _onData() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    AppData.I.addListener(_onData);
    // Opening the inbox marks everything read (clears the bell badge).
    WidgetsBinding.instance.addPostFrameCallback((_) => AppData.I.markAllRead());
  }

  @override
  void dispose() {
    AppData.I.removeListener(_onData);
    super.dispose();
  }

  // type -> (icon, stroke, bg, border)
  (String, Color, Color, Color) _style(String type) {
    switch (type) {
      case 'event':
        return (_plus, K.ok, K.ok1, const Color(0xFF16A34A));
      case 'reminder':
        return (_clock, K.er, K.er1, const Color(0xFFDC2626));
      case 'rsvp':
        return (_check, K.ok, K.ok1, const Color(0xFF16A34A));
      case 'attendance':
        return (_qr, K.t7, K.t1, K.t2);
      case 'community':
        return (_flower, K.t7, K.t1, K.t2);
      case 'push':
        return (_send, K.inC, K.in1, const Color(0xFF1D4ED8));
      default:
        return (_bell, K.t7, K.t0, K.t1);
    }
  }

  String _ago(String iso) {
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

  @override
  Widget build(BuildContext context) {
    final items = AppData.I.notifications;
    return Container(
      color: K.cream,
      child: Column(
        children: [
          AppBarX(
            title: 'Notifications',
            sub: 'From your venues',
            back: 's03',
            onBack: () => go('s03'),
          ),
          if (items.isEmpty)
            Expanded(child: _empty())
          else
            Sc(
              padding: const EdgeInsets.symmetric(vertical: 12),
              [for (final n in items) _row(n)],
            ),
        ],
      ),
    );
  }

  Widget _row(AppNotification n) {
    final s = _style(n.type);
    return Press(
      scale: .99,
      onTap: () {
        AppData.I.selectedNotification = n;
        AppData.I.markRead(n.id);
        go('s17');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: n.read ? K.white : K.t0,
          border: Border(bottom: BorderSide(color: K.bd)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: s.$3,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: s.$4.withOpacity(.2)),
              ),
              child: Center(child: Ico(s.$1, size: 16, stroke: s.$2, sw: 1.8)),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(n.title, style: ff(size: rem(.76), w: FontWeight.w700, color: K.ink)),
                  if (n.body.isNotEmpty) Text(n.body, style: ff(size: rem(.62), color: K.ink3)),
                  const SizedBox(height: 2),
                  Text(_ago(n.iso), style: ff(size: rem(.56), color: K.ink4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: K.t1, borderRadius: BorderRadius.circular(18)),
            child: const Center(child: Ico(_bell, size: 28, stroke: K.t6, sw: 1.6)),
          ),
          const SizedBox(height: 14),
          Text('No notifications yet', style: fd(size: rem(1), w: FontWeight.w800, color: K.ink)),
          const SizedBox(height: 4),
          Text('Reminders and updates will show up here',
              style: ff(size: rem(.72), color: K.ink3)),
        ],
      ),
    );
  }
}
