import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../app_state.dart';
import '../session.dart';
import '../auth_service.dart';
import '../data_store.dart';
import '../notif_service.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

class S22 extends StatefulWidget {
  const S22({super.key});
  @override
  State<S22> createState() => _S22State();
}

class _S22State extends State<S22> {
  late bool _push = AppData.I.settings['push'] ?? true;
  late bool _reminders = AppData.I.settings['reminders'] ?? true;
  late bool _autoCal = AppData.I.settings['autoCal'] ?? true;

  String? _token;
  String _diag = '';
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    NotifService.refreshToken().then((t) {
      if (mounted) setState(() => _token = t);
    });
  }

  void _setPush(bool v) {
    setState(() => _push = v);
    AppData.I.setSetting('push', v);
    NotifService.setPushEnabled(v); // (un)subscribe FCM 'programs' topic
    toast(v ? 'Push notifications on' : 'Push notifications off');
  }

  void _setReminders(bool v) {
    setState(() => _reminders = v);
    AppData.I.setSetting('reminders', v);
  }

  void _setAutoCal(bool v) {
    setState(() => _autoCal = v);
    AppData.I.setSetting('autoCal', v);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: K.cream,
      child: Column(
        children: [
          AppBarX(
            title: 'Settings',
            back: 's20',
            onBack: () => go('s20'),
          ),
          Sc(
            padding: const EdgeInsets.symmetric(vertical: 12),
            [
              const Sec('Notifications'),
              _ToggleRow('Push notifications', _push, _setPush),
              _ToggleRow('Programme reminders', _reminders, _setReminders),
              _ToggleRow('Auto-add to calendar', _autoCal, _setAutoCal),

              const Sec('Account'),
              _NavRow('Manage Subscriptions', onTap: () => go('s21')),
              _ValueRow('Language', 'English', onTap: () => toast('Language settings')),

              const Sec('Push diagnostics'),
              _ValueRow(
                'FCM token',
                _token == null || _token!.isEmpty
                    ? 'unavailable — FCM not registered'
                    : '${_token!.substring(0, _token!.length < 12 ? _token!.length : 12)}… (tap to copy)',
                onTap: _token == null || _token!.isEmpty
                    ? null
                    : () {
                        Clipboard.setData(ClipboardData(text: _token!));
                        toast('FCM token copied');
                      },
              ),
              _NavRow(
                _sending ? 'Sending test push…' : 'Send test push to this device',
                onTap: () async {
                  if (_sending) return;
                  setState(() => _sending = true);
                  toast('Sending test push…');
                  final res = await NotifService.sendTestPushToThisDevice();
                  if (mounted) {
                    setState(() {
                      _sending = false;
                      _diag = res;
                    });
                  }
                  toast(res);
                },
              ),
              _NavRow('Re-subscribe push topics', onTap: () async {
                final topics = await NotifService.resubscribeAll();
                final msg = topics.isEmpty
                    ? 'Subscribed to nothing (no token / no followed communities)'
                    : 'Subscribed: ${topics.join(', ')}';
                if (mounted) setState(() => _diag = msg);
                toast(msg);
              }),
              if (_diag.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
                  child: Text(_diag, style: ff(size: rem(.66), color: K.ink4)),
                ),

              const Sec('About'),
              const _ValueRow('Invite Karoo', 'v2.0'),

              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                child: Press(
                  onTap: () async {
                    await AuthService.signOut();
                    await AppData.I.clearForLogout();
                    await Session.I.signOut();
                    toast('Logged out');
                    go('s01');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: K.er, width: 1.5),
                    ),
                    child: Text('Log Out',
                        textAlign: TextAlign.center,
                        style: ff(size: rem(.82), w: FontWeight.w700, color: K.er)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const _rowPad = EdgeInsets.symmetric(horizontal: 18, vertical: 13);

TextStyle _rowLabel() => ff(size: rem(.78), w: FontWeight.w600, color: K.ink);

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool on;
  final ValueChanged<bool> onChanged;
  const _ToggleRow(this.label, this.on, this.onChanged);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _rowPad,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: K.bd))),
      child: Row(
        children: [
          Expanded(child: Text(label, style: _rowLabel())),
          Toggle(on: on, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavRow(this.label, {required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Press(
      scale: .99,
      onTap: onTap,
      child: Container(
        padding: _rowPad,
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: K.bd))),
        child: Row(
          children: [
            Expanded(child: Text(label, style: _rowLabel())),
            const Ico(P.chevR, size: 15, stroke: K.ink4, sw: 2.2),
          ],
        ),
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _ValueRow(this.label, this.value, {this.onTap});
  @override
  Widget build(BuildContext context) {
    final row = Container(
      padding: _rowPad,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: K.bd))),
      child: Row(
        children: [
          Expanded(child: Text(label, style: _rowLabel())),
          Text(value, style: ff(size: rem(.66), color: K.ink4)),
        ],
      ),
    );
    return onTap == null ? row : Press(scale: .99, onTap: onTap, child: row);
  }
}
