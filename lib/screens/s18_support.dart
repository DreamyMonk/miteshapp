import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

const _arrowLeft = '<line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/>';
const _plus = '<line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>';
const _chevR = '<polyline points="9 18 15 12 9 6"/>';
const _send = '<line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/>';
const _image =
    '<rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/>';

class S18 extends StatefulWidget {
  const S18({super.key});
  @override
  State<S18> createState() => _S18State();
}

class _S18State extends State<S18> {
  String _view = 'list'; // 'list' | 'raise' | 'chat'
  int _cat = 0;

  void _supView(String v) => setState(() => _view = v);

  @override
  Widget build(BuildContext context) {
    switch (_view) {
      case 'raise':
        return _buildRaise();
      case 'chat':
        return _buildChat();
      default:
        return _buildList();
    }
  }

  // ───────────────── Sub-view A: My Tickets list ─────────────────
  Widget _buildList() {
    return Container(
      color: K.cream,
      child: Column(
        children: [
          // dark header band
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
            decoration: const BoxDecoration(gradient: K.gHeader),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: BackBtn(dark: false, onTap: () => go('s34')),
                ),
                Text('Support', style: fd(size: rem(1.3), w: FontWeight.w800, color: Colors.white)),
                Text('Invite Karoo help desk · replies within 1 hour',
                    style: ff(size: rem(.66), color: Colors.white.withOpacity(.5))),
              ],
            ),
          ),
          Sc(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            [
              Btn('Raise New Ticket', kind: BtnKind.p, leading: _plus, onTap: () => _supView('raise')),
              const Sec('My Tickets', padding: EdgeInsets.fromLTRB(0, 6, 0, 8)),
              _ticketCard(
                title: 'App not showing new events',
                meta: '#TKT-2041 · Chennai Conv.',
                chip: 'Open',
                chipKind: ChipKind.a,
                last: 'Last reply 1 hr ago',
              ),
              _ticketCard(
                title: 'Reminder not received',
                meta: '#TKT-1987 · General',
                chip: 'In Progress',
                chipKind: ChipKind.i,
                last: 'Last reply yesterday',
              ),
              _ticketCard(
                title: 'Wrong venue address shown',
                meta: '#TKT-1820 · SPP Gardens',
                chip: 'Resolved',
                chipKind: ChipKind.g,
                last: 'Closed 3 days ago',
              ),
              const Sec('Quick Help', padding: EdgeInsets.fromLTRB(0, 6, 0, 8)),
              _faqCard('How do venue subscriptions work?', 'FAQ: How subscriptions work'),
              _faqCard('Why am I not getting notifications?', 'FAQ: Notifications'),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ticketCard({
    required String title,
    required String meta,
    required String chip,
    required ChipKind chipKind,
    required String last,
  }) {
    return CardX(
      onTap: () => _supView('chat'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: ff(size: rem(.8), w: FontWeight.w700, color: K.ink)),
                      Text(meta, style: ff(size: rem(.62), color: K.ink3)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Chip2(chip, kind: chipKind, fontSize: rem(.52)),
              ],
            ),
          ),
          Text(last, style: ff(size: rem(.62), color: K.ink4)),
        ],
      ),
    );
  }

  Widget _faqCard(String text, String toastMsg) {
    return CardX(
      onTap: () => toast(toastMsg),
      child: Row(
        children: [
          Expanded(child: Text(text, style: ff(size: rem(.74), color: K.ink2))),
          Ico(_chevR, size: 14, stroke: K.ink4, sw: 2.2),
        ],
      ),
    );
  }

  // ───────────────── Sub-view B: Raise Ticket ─────────────────
  Widget _buildRaise() {
    const cats = ['Events & Schedule', 'Notifications', 'Subscription', 'Other'];
    return Container(
      color: K.cream,
      child: Column(
        children: [
          AppBarX(
            title: 'Raise a Ticket',
            sub: 'Tell us what is wrong',
            back: 's18',
            onBack: () => _supView('list'),
          ),
          Sc(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            [
              const Lbl('Category'),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(cats.length, (i) {
                    final active = i == _cat;
                    return GestureDetector(
                      onTap: () => setState(() => _cat = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                        decoration: BoxDecoration(
                          color: active ? K.t6 : K.white,
                          borderRadius: BorderRadius.circular(18),
                          border: active ? null : Border.all(color: K.bd),
                        ),
                        child: Text(cats[i],
                            style: ff(
                                size: rem(.66),
                                w: FontWeight.w700,
                                color: active ? Colors.white : K.ink3)),
                      ),
                    );
                  }),
                ),
              ),
              const Lbl('Related Venue (optional)'),
              _SelectInp(
                value: 'Chennai Convention Centre',
                onTap: () => toast('Select related venue'),
              ),
              const Lbl('Subject'),
              const Inp(hint: 'Brief summary of the issue'),
              const Lbl('Describe the issue'),
              _TextArea(hint: 'What happened, what you expected, what you saw...'),
              const Lbl('Attach screenshot (optional)'),
              GestureDetector(
                onTap: () => toast('Attach screenshot - picker opens'),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: K.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: K.bd2, width: 1.5, style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      Ico(_image, size: 24, stroke: K.t6, sw: 1.7),
                      const SizedBox(height: 5),
                      Text('Tap to attach',
                          style: ff(size: rem(.72), w: FontWeight.w700, color: K.ink3)),
                    ],
                  ),
                ),
              ),
              Btn('Submit Ticket', kind: BtnKind.p, leading: _send, onTap: () => _supView('chat')),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────── Sub-view C: Ticket detail + chat ─────────────────
  Widget _buildChat() {
    return Container(
      color: K.cream,
      child: Column(
        children: [
          AppBarX(
            title: 'Ticket #TKT-2041',
            sub: 'App not showing new events',
            back: 's18',
            onBack: () => _supView('list'),
            actions: [Chip2('Open', kind: ChipKind.a, fontSize: rem(.52))],
          ),
          Sc(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Opened 1 hour ago · Chennai Conv. Centre · Events & Schedule',
                  textAlign: TextAlign.center,
                  style: ff(size: rem(.58), color: K.ink4),
                ),
              ),
              _bubble('New programmes added by the venue are not showing in my calendar even though I am subscribed.',
                  me: true),
              _bubble('Hi Mitesh! Could you check if "Auto-add to calendar" is on for this community in Manage Subscriptions (S21)?',
                  me: false),
              _bubble('Checked - it was off! Turned it on now.', me: true),
              _bubble('Perfect. New events should sync within a minute now. We will mark this resolved!',
                  me: false, marginBottom: 8),
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 14),
                child: Text(
                  'Replies within 1 hour · Mon-Sat 9 AM-9 PM',
                  textAlign: TextAlign.center,
                  style: ff(size: rem(.56), color: K.ink4),
                ),
              ),
            ],
          ),
          // composer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: K.white,
              border: Border(top: BorderSide(color: K.bd)),
            ),
            child: Row(
              children: [
                const Expanded(child: Inp(hint: 'Type a reply...', margin: 0)),
                const SizedBox(width: 8),
                Press(
                  scale: .9,
                  onTap: () => toast('Reply sent'),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: K.gPurple,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Center(child: Ico(_send, size: 17, stroke: Colors.white, sw: 2)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(String text, {required bool me, double marginBottom = 10}) {
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 0.78 * 354), // 78% of ~354 content width
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        gradient: me ? K.gPurple : null,
        color: me ? null : K.white,
        border: me ? null : Border.all(color: K.bd),
        borderRadius: me
            ? const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(4),
              )
            : const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(14),
              ),
      ),
      child: Text(text,
          style: ff(size: rem(.74), color: me ? Colors.white : K.ink2, height: 1.45)),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom),
      child: Row(
        mainAxisAlignment: me ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [Flexible(child: bubble)],
      ),
    );
  }
}

/// A select-style field (.inp dropdown) shown as a tappable box.
class _SelectInp extends StatelessWidget {
  final String value;
  final VoidCallback onTap;
  const _SelectInp({required this.value, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: K.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: K.bd2, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(child: Text(value, style: ff(size: rem(.81), color: K.ink))),
            Ico('<polyline points="6 9 12 15 18 9"/>', size: 15, stroke: K.ink4, sw: 2),
          ],
        ),
      ),
    );
  }
}

/// Multi-line text area (.inp textarea, height 88, no resize).
class _TextArea extends StatelessWidget {
  final String hint;
  const _TextArea({required this.hint});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      child: TextField(
        maxLines: null,
        minLines: 4,
        style: ff(size: rem(.81), color: K.ink),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: ff(size: rem(.81), color: K.ink4),
          filled: true,
          fillColor: K.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11), borderSide: BorderSide(color: K.bd2, width: 1.5)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11), borderSide: BorderSide(color: K.bd2, width: 1.5)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: K.t6, width: 1.5)),
        ),
      ),
    );
  }
}
