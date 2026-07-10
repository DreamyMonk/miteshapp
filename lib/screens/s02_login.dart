import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../theme.dart';
import '../app_state.dart';
import '../session.dart';
import '../auth_service.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/header.dart';
import '../widgets/svg.dart';

const _hand =
    '<path d="M18 11V6a2 2 0 0 0-2-2a2 2 0 0 0-2 2"/><path d="M14 10V4a2 2 0 0 0-2-2a2 2 0 0 0-2 2v2"/><path d="M10 10.5V6a2 2 0 0 0-2-2a2 2 0 0 0-2 2v8"/><path d="M18 8a2 2 0 1 1 4 0v6a8 8 0 0 1-8 8h-2c-2.8 0-4.5-.86-5.99-2.34l-3.6-3.6a2 2 0 0 1 2.83-2.82L7 15"/>';
const _users =
    '<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>';

// WhatsApp OTP is minted/verified by the host-dashboard server routes.
const _apiBase = 'https://host.invitekaroo.com';

class S02 extends StatefulWidget {
  const S02({super.key});
  @override
  State<S02> createState() => _S02State();
}

class _S02State extends State<S02> {
  final _name = TextEditingController();
  final _family = TextEditingController();
  final _mobile = TextEditingController(text: '+91 ');
  final _city = TextEditingController();
  final _otp = List.generate(6, (_) => TextEditingController());
  final _otpFocus = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _secs = 0;
  bool _codeSent = false;
  bool _busy = false;

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secs = 24);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secs <= 0) {
        t.cancel();
        setState(() {});
      } else {
        setState(() => _secs--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _name.dispose();
    _family.dispose();
    _mobile.dispose();
    _city.dispose();
    for (final c in _otp) { c.dispose(); }
    for (final f in _otpFocus) { f.dispose(); }
    super.dispose();
  }

  // Step 1: send the OTP over WhatsApp (via the server route).
  Future<void> _send() async {
    if (_busy) return;
    if (_name.text.trim().isEmpty) {
      toast('Please enter your name');
      return;
    }
    final phone = AuthService.normalize(_mobile.text);
    if (phone.length < 11) {
      toast('Enter a valid mobile number');
      return;
    }
    setState(() => _busy = true);
    toast('Sending OTP on WhatsApp…');
    try {
      final res = await http
          .post(Uri.parse('$_apiBase/api/otp/whatsapp/send'),
              headers: {'Content-Type': 'application/json'}, body: jsonEncode({'phone': phone}))
          .timeout(const Duration(seconds: 30));
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200 || j['ok'] != true) {
        throw Exception('${j['error'] ?? 'Could not send code'}');
      }
      if (!mounted) return;
      setState(() {
        _busy = false;
        _codeSent = true;
      });
      _startCountdown();
      FocusScope.of(context).requestFocus(_otpFocus[0]);
      toast('OTP sent on WhatsApp to $phone');
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      toast('Could not send: ${_short(e)}');
    }
  }

  // Step 2: verify the entered code → custom token → sign in.
  Future<void> _verify() async {
    if (_busy) return;
    final code = _otp.map((c) => c.text).join();
    if (code.length < 6) {
      toast('Enter the 6-digit OTP');
      FocusScope.of(context).requestFocus(_otpFocus[code.length.clamp(0, 5)]);
      return;
    }
    setState(() => _busy = true);
    try {
      final phone = AuthService.normalize(_mobile.text);
      final res = await http
          .post(Uri.parse('$_apiBase/api/otp/whatsapp/verify'),
              headers: {'Content-Type': 'application/json'}, body: jsonEncode({'phone': phone, 'code': code}))
          .timeout(const Duration(seconds: 30));
      final j = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200 || j['ok'] != true || j['token'] == null) {
        throw Exception('${j['error'] ?? 'Invalid code'}');
      }
      await AuthService.signInWithCustomToken('${j['token']}');
      await _onSignedIn();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      toast(_short(e));
    }
  }

  String _short(Object e) {
    var s = e.toString().replaceFirst('Exception: ', '');
    if (s.length > 90) s = '${s.substring(0, 90)}…';
    return s;
  }

  // Single primary action: send the code first, then verify once it's been sent.
  Future<void> _primary() async {
    if (_codeSent) {
      await _verify();
    } else {
      await _send();
    }
  }

  Future<void> _onSignedIn() async {
    await Session.I.signIn(
      name: _name.text,
      family: _family.text,
      mobile: _mobile.text,
      city: _city.text,
    );
    final uid = AuthService.uid;
    if (uid != null) await AppData.I.bindUser(uid);
    go('s03');
  }

  void _resend() {
    if (_secs > 0) return;
    _send();
  }

  // Hidden test path (long-press "Welcome"): anonymous login, no SMS.
  // Temporary — to be removed once real SMS OTP is fully provisioned.
  Future<void> _testLogin() async {
    if (_busy) return;
    setState(() => _busy = true);
    toast('Test login (no SMS)…');
    try {
      await AuthService.signInAnonymously();
      if (_name.text.trim().isEmpty) _name.text = 'Test User';
      if (AuthService.normalize(_mobile.text).length < 6) _mobile.text = '+91 9000000000';
      await _onSignedIn();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      toast('Test login failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: K.cream,
      child: Column(
        children: [
          DarkHeader(
            blobs: [Blob(150, const Color(0xFFF5A623).withOpacity(.07), bottom: -40, right: -40)],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onLongPress: _busy ? null : _testLogin,
                    child: Text('Welcome', style: fd(size: rem(1.55), w: FontWeight.w800, color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  Ico(_hand, size: 22, stroke: Colors.white, sw: 1.8),
                ]),
                const SizedBox(height: 6),
                Text("Enter your mobile to continue. We'll send an OTP.",
                    style: ff(size: rem(.76), color: Colors.white.withOpacity(.48), height: 1.55)),
              ],
            ),
          ),
          Sc(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            [
              const Lbl('Full Name'),
              Inp(controller: _name, leadingIcon: P.user, hint: 'e.g. Mahesh Ranka', margin: 10),
              const Lbl('Family Name'),
              Inp(controller: _family, leadingIcon: _users, hint: 'e.g. Ranka', margin: 10),
              const Lbl('Mobile Number'),
              Inp(controller: _mobile, leadingIcon: P.phone, mono_: true, margin: 10),
              const Lbl('City'),
              Inp(controller: _city, leadingIcon: P.pin, hint: 'e.g. Chennai', margin: 10),
              Sec('Enter OTP', padding: const EdgeInsets.fromLTRB(0, 8, 0, 6)),
              _OtpRow(controllers: _otp, focusNodes: _otpFocus),
              const SizedBox(height: 16),
              Btn(_busy ? (_codeSent ? 'Verifying…' : 'Sending…') : 'Verify & Continue',
                  kind: BtnKind.p, trailing: _busy ? null : P.arrowRight, onTap: _busy ? null : _primary),
              Center(
                child: (_codeSent && _secs > 0)
                    ? RichText(
                        text: TextSpan(
                          text: 'Resend OTP in ',
                          style: ff(size: rem(.66), color: K.ink4),
                          children: [
                            TextSpan(
                                text: '0:${_secs.toString().padLeft(2, '0')}',
                                style: mono(size: rem(.66), w: FontWeight.w700, color: K.t7)),
                          ],
                        ),
                      )
                    : Press(
                        onTap: _codeSent ? _resend : null,
                        child: Text(
                            _codeSent ? 'Resend OTP' : 'Resend OTP in 0:24',
                            style: _codeSent
                                ? ff(size: rem(.7), w: FontWeight.w700, color: K.t7)
                                : ff(size: rem(.66), color: K.ink4)),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OtpRow extends StatefulWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  const _OtpRow({required this.controllers, required this.focusNodes});
  @override
  State<_OtpRow> createState() => _OtpRowState();
}

class _OtpRowState extends State<_OtpRow> {
  int get _n => widget.controllers.length;

  // Fill all boxes from a full code (paste / OS autofill), focus the last one.
  void _fill(String code) {
    final digits = code.replaceAll(RegExp(r'[^0-9]'), '');
    for (var k = 0; k < _n; k++) {
      final ch = k < digits.length ? digits[k] : '';
      if (widget.controllers[k].text != ch) widget.controllers[k].text = ch;
    }
    final last = (digits.length.clamp(1, _n) - 1).clamp(0, _n - 1);
    widget.focusNodes[last].requestFocus();
    setState(() {});
  }

  void _onChanged(int i, String v) {
    final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
    // A pasted / autofilled full code lands in one box → spread it across all.
    if (digits.length >= _n) {
      _fill(digits);
      return;
    }
    // Otherwise keep just the last digit typed and advance.
    final one = digits.isEmpty ? '' : digits.substring(digits.length - 1);
    if (widget.controllers[i].text != one) {
      widget.controllers[i].value =
          TextEditingValue(text: one, selection: TextSelection.collapsed(offset: one.length));
    }
    if (one.isNotEmpty && i < _n - 1) {
      widget.focusNodes[i + 1].requestFocus();
    }
    setState(() {});
  }

  KeyEventResult _onKey(int i, FocusNode node, KeyEvent e) {
    if (e is KeyDownEvent &&
        e.logicalKey == LogicalKeyboardKey.backspace &&
        widget.controllers[i].text.isEmpty &&
        i > 0) {
      widget.controllers[i - 1].clear();
      widget.focusNodes[i - 1].requestFocus();
      setState(() {});
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_n, (i) {
        final filled = widget.controllers[i].text.isNotEmpty;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < _n - 1 ? 9 : 0),
            child: AspectRatio(
              aspectRatio: 1,
              child: Focus(
                onKeyEvent: (node, e) => _onKey(i, node, e),
                child: TextField(
                  controller: widget.controllers[i],
                  focusNode: widget.focusNodes[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  autofillHints: i == 0 ? const [AutofillHints.oneTimeCode] : null,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) => _onChanged(i, v),
                  style: mono(size: rem(1.25), w: FontWeight.w700, color: filled ? K.t7 : K.ink),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '0',
                    hintStyle: mono(size: rem(1.25), w: FontWeight.w700, color: K.ink4),
                    filled: true,
                    fillColor: filled ? K.t0 : K.white,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: filled ? K.t6 : K.bd2, width: 2)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: filled ? K.t6 : K.bd2, width: 2)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: K.t6, width: 2)),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
