import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

const _mon19 = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _dm19(String iso) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(iso);
  if (m == null) return '';
  return '${int.parse(m.group(3)!)} ${_mon19[(int.parse(m.group(2)!) - 1).clamp(0, 11)]}';
}

const _share =
    '<circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/><line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/>';
const _whatsapp =
    '<path d="M12 2a10 10 0 0 0-8.5 15.3L2 22l4.8-1.5A10 10 0 1 0 12 2zm5 14c-.3.7-1.5 1.3-2 1.3-.6.1-1.3.1-2.1-.1-.5-.2-1.1-.4-2-.7-3.4-1.5-5.6-4.9-5.7-5.1-.2-.2-1.4-1.8-1.4-3.4S4.6 6.3 5 5.9c.3-.4.7-.5.9-.5h.7c.2 0 .5 0 .8.6l1 2.3c.1.2.1.4 0 .6l-.5.6c-.2.2-.3.4-.1.7.6 1 1.3 1.6 2.1 2.1.3.2.5.1.7-.1l.7-.8c.2-.2.4-.2.6-.1l2.2 1c.3.2.5.2.5.4.1.2.1 1-.3 1.8z"/>';
const _link =
    '<path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/>';
const _sms = '<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>';
const _more =
    '<circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/>';

// pg-s19 tiles use distinct inline toasts (matching the HTML verbatim).

class S19 extends StatelessWidget {
  const S19({super.key});
  @override
  Widget build(BuildContext context) {
    final p = AppData.I.selectedProgram;
    final title = (p != null && '${p['title'] ?? ''}'.isNotEmpty) ? '${p['title']}' : 'Programme';
    final sub = p == null
        ? ''
        : [
            if ('${p['venue'] ?? ''}'.isNotEmpty) '${p['venue']}',
            if (_dm19('${p['date'] ?? ''}').isNotEmpty) _dm19('${p['date']}'),
            if ('${p['time'] ?? ''}'.isNotEmpty) '${p['time']}',
          ].join(' · ');
    return Container(
      color: K.cream,
      child: Column(
        children: [
          AppBarX(
            title: 'Share Programme',
            back: 's12',
            onBack: () => go('s12'),
          ),
          Sc(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            [
              CardX(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [K.t7, K.t5],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(child: Ico(_share, size: 24, stroke: Colors.white, sw: 1.8)),
                    ),
                    Text(title,
                        style: ff(size: rem(.84), w: FontWeight.w700, color: K.ink)),
                    if (sub.isNotEmpty)
                      Text(sub, style: ff(size: rem(.64), color: K.ink3)),
                  ],
                ),
              ),
              const Sec('Share via', padding: EdgeInsets.symmetric(vertical: 6)),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    _ShareTile(
                      icon: _whatsapp,
                      iconColor: K.ok,
                      bg: K.ok1,
                      label: 'WhatsApp',
                      iconSize: 22,
                      filled: true,
                      onTap: () => toast('Shared on WhatsApp'),
                    ),
                    const SizedBox(width: 8),
                    _ShareTile(
                      icon: _link,
                      iconColor: K.t7,
                      bg: K.t1,
                      label: 'Copy Link',
                      iconSize: 20,
                      onTap: () => toast('Copied link'),
                    ),
                    const SizedBox(width: 8),
                    _ShareTile(
                      icon: _sms,
                      iconColor: K.inC,
                      bg: K.in1,
                      label: 'SMS',
                      iconSize: 20,
                      onTap: () => toast('Shared via SMS'),
                    ),
                    const SizedBox(width: 8),
                    _ShareTile(
                      icon: _more,
                      iconColor: K.ink3,
                      bg: K.cream2,
                      label: 'More',
                      iconSize: 20,
                      onTap: () => toast('More options'),
                    ),
                  ],
                ),
              ),
              Btn('Done', kind: BtnKind.s, onTap: () => go('s12')),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShareTile extends StatelessWidget {
  final String icon;
  final Color iconColor;
  final Color bg;
  final String label;
  final double iconSize;
  final bool filled;
  final VoidCallback onTap;
  const _ShareTile({
    required this.icon,
    required this.iconColor,
    required this.bg,
    required this.label,
    required this.iconSize,
    this.filled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Press(
        scale: .95,
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
              child: Center(
                child: filled
                    ? Ico(icon, size: iconSize, stroke: iconColor, fill: iconColor, sw: 0)
                    : Ico(icon, size: iconSize, stroke: iconColor, sw: 1.8),
              ),
            ),
            Text(label, style: ff(size: rem(.55), color: K.ink3)),
          ],
        ),
      ),
    );
  }
}
