import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../session.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

// Show a value if present, otherwise leave the field empty (hint takes over).

const _arrowLeft =
    '<line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/>';
const _arrowRight =
    '<line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/>';
const _flower =
    '<circle cx="12" cy="12" r="2.5"/><path d="M12 9.5c0-2 1.5-3.5 0-5.5-1.5 2-1.5 3.5 0 5.5M12 14.5c0 2-1.5 3.5 0 5.5 1.5-2 1.5-3.5 0-5.5M9.5 12c-2 0-3.5 1.5-5.5 0 2-1.5 3.5-1.5 5.5 0M14.5 12c2 0 3.5-1.5 5.5 0-2 1.5-3.5 1.5-5.5 0"/>';
const _heart =
    '<path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"/>';
const _chevR = '<polyline points="9 18 15 12 9 6"/>';
const _info =
    '<circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/>';
const _user =
    '<path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>';
const _mail = '<rect x="2" y="4" width="20" height="16" rx="2"/><path d="m22 7-10 5L2 7"/>';
const _pin =
    '<path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/>';
const _briefcase =
    '<rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/>';
const _users =
    '<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>';
const _phone =
    '<path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/>';
const _wa =
    '<path d="M17.47 14.38c-.3-.15-1.74-.86-2-.96-.27-.1-.46-.15-.66.15-.19.3-.76.95-.93 1.15-.17.2-.34.22-.64.07-.3-.15-1.25-.46-2.38-1.47-.88-.78-1.47-1.75-1.64-2.05-.17-.3-.02-.46.13-.61.13-.13.3-.34.45-.51.15-.17.2-.3.3-.5.1-.2.05-.37-.02-.52-.08-.15-.66-1.6-.91-2.18-.24-.57-.48-.5-.66-.5-.17 0-.37-.02-.56-.02-.2 0-.52.07-.79.37-.27.3-1.04 1.01-1.04 2.47 0 1.46 1.06 2.87 1.21 3.07.15.2 2.1 3.2 5.08 4.49.71.31 1.26.49 1.69.63.71.23 1.36.19 1.87.12.57-.09 1.74-.71 1.99-1.4.24-.69.24-1.28.17-1.4-.07-.12-.27-.2-.56-.34zM12 2a10 10 0 0 0-8.6 15.06L2 22l5.06-1.33A10 10 0 1 0 12 2z"/>';
const _venue = '<path d="M3 21h18M5 21V7l8-4v18M19 21V11l-6-3"/>';
const _file =
    '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/>';
const _couple =
    '<circle cx="9" cy="7" r="4"/><path d="M3 21v-2a4 4 0 0 1 4-4h4a4 4 0 0 1 4 4v2"/><circle cx="17" cy="11" r="3"/>';
const _calendar =
    '<rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>';
const _list =
    '<line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/>';
const _invite = '<path d="M21 8v13H3V8M1 3h22v5H1zM10 12h4"/>';
const _send =
    '<line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/>';

const _pink = Color(0xFFA21CAF);
const _pinkLight = Color(0xFFE879F9);
const _pinkBorder = Color(0xFFF0ABFC);
const _pinkBg = Color(0xFFFAE8FF);

class S23 extends StatefulWidget {
  const S23({super.key});
  @override
  State<S23> createState() => _S23State();
}

class _S23State extends State<S23> {
  String _track = 'community'; // 'community' | 'wedding'
  int _step = 0; // 0 = track selector, 1..3 = steps
  bool _picked = false;

  // Select-field state (HTML <select> defaults = first option).
  static const List<String> _eventTypeOpts = [
    'Community Sammelan',
    'Religious Pravachan',
    'Cultural Event',
    'Garba / Festival',
    'Social Gathering',
    'Other',
  ];
  static const List<String> _funcCountOpts = [
    '2 – 3 functions',
    '4 – 5 functions',
    '6 – 8 functions',
    'More than 8',
  ];
  static const List<String> _invitesOpts = [
    'Yes — send invites via Invite Karoo',
    'No — managing invites myself',
    'Not sure yet',
  ];
  String _eventType = _eventTypeOpts.first;
  String _funcCount = _funcCountOpts.first;
  String _invites = _invitesOpts.first;

  // Form field controllers, created lazily and keyed by field name. Initial
  // values (name/mobile/city) come from the signed-in Session on first build.
  final Map<String, TextEditingController> _fc = {};
  TextEditingController _c(String key, [String initial = '']) =>
      _fc.putIfAbsent(key, () => TextEditingController(text: initial));

  @override
  void dispose() {
    for (final c in _fc.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _launch(String url, String fallback) async {
    try {
      final ok = await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
      if (!ok) toast(fallback);
    } catch (_) {
      toast(fallback);
    }
  }

  void _selectTrack(String track) {
    setState(() {
      _track = track;
      _picked = true;
      _step = 1;
    });
  }

  void _go(int n) => setState(() => _step = n);

  void _submit() {
    // Collect the form + persist the application to Firestore for admin review.
    final f = <String, dynamic>{
      'name': _c('name').text.trim(),
      'mobile': _c('mobile').text.trim(),
      'email': _c('email').text.trim(),
      'cityState': _c('cityState').text.trim(),
      'role': _c('role').text.trim(),
    };
    if (!_isWed) {
      f.addAll({
        'orgName': _c('orgName').text.trim(),
        'communityName': _c('communityName').text.trim(),
        'venueName': _c('venueName').text.trim(),
        'landmarkArea': _c('landmarkArea').text.trim(),
        'venueAddress': _c('venueAddress').text.trim(),
        'dailyAttendance': _c('dailyAttendance').text.trim(),
        'eventType': _eventType,
        'guru': _c('guru').text.trim(),
      });
    } else {
      f.addAll({
        'bride': _c('bride').text.trim(),
        'groom': _c('groom').text.trim(),
        'family': _c('family').text.trim(),
        'weddingVenue': _c('weddingVenue').text.trim(),
        'weddingCityArea': _c('weddingCityArea').text.trim(),
        'weddingDateFrom': _c('wdFrom').text.trim(),
        'weddingDateTo': _c('wdTo').text.trim(),
        'funcCount': _funcCount,
        'mainFunctions': _c('mainFunctions').text.trim(),
        'guestCount': _c('guestCount').text.trim(),
        'needInvites': _invites,
      });
    }
    AppData.I.submitHostApplication(f, track: _track);

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'submitted',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 320),
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween<double>(begin: .94, end: 1).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
      pageBuilder: (ctx, _, __) => _HostSuccess(onClose: () {
        Navigator.of(ctx).pop();
        go('s20');
      }),
    );
  }

  bool get _isWed => _track == 'wedding';

  @override
  Widget build(BuildContext context) {
    final labels = _isWed ? ['You', 'Couple', 'Plan'] : ['You', 'Venue', 'Event'];
    return Container(
      color: K.cream,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
            decoration: const BoxDecoration(gradient: K.gHeader),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Press(
                          dx: -3,
                          onTap: () => go('s20'),
                          child: Ico(_arrowLeft, size: 18, stroke: Colors.white, sw: 2),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Host on Invite Karoo',
                                  style: fd(size: rem(1.05), w: FontWeight.w800, color: Colors.white, height: 1.2)),
                              const SizedBox(height: 3),
                              Text(
                                  'Apply to host community events or weddings — manage everything from one dashboard.',
                                  style: ff(size: rem(.6), color: Colors.white.withOpacity(.55), height: 1.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_picked && _step != 0) ...[
                      const SizedBox(height: 10),
                      _StepIndicator(step: _step, labels: labels, onTap: _go),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Body
          Sc(
            padding: const EdgeInsets.all(18),
            [
              if (_step == 0) _trackSelector(),
              if (_step == 1) _step1(),
              if (_step == 2) _step2(),
              if (_step == 3) _step3(),
            ],
          ),
        ],
      ),
    );
  }

  // ── STEP 0 : Choose Track ──
  Widget _trackSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What would you like to host?',
            style: fd(size: rem(1.05), w: FontWeight.w800, color: K.ink)),
        const SizedBox(height: 2),
        Text("Choose a track — we'll tailor the form for you.",
            style: ff(size: rem(.68), color: K.ink3)),
        const SizedBox(height: 18),
        _trackCard(
          onTap: () => _selectTrack('community'),
          grad: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [K.white, K.t1]),
          border: K.t2,
          iconGrad: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [K.t6, K.t5]),
          icon: _flower,
          title: 'Community Events',
          desc: 'Sammelans, pravachans, festivals & daily programmes at your venue.',
          chevBg: K.t6,
          margin: 13,
        ),
        _trackCard(
          onTap: () => _selectTrack('wedding'),
          grad: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [K.white, _pinkBg]),
          border: _pinkBorder,
          iconGrad: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_pink, _pinkLight]),
          icon: _heart,
          title: 'Wedding',
          desc: 'Host a wedding & manage all functions, guests & invites in one place.',
          chevBg: _pink,
          margin: 0,
        ),
        const SizedBox(height: 16),
        _infoBox('Not sure? You can always reach our team on WhatsApp before applying.'),
      ],
    );
  }

  Widget _trackCard({
    required VoidCallback onTap,
    required Gradient grad,
    required Color border,
    required Gradient iconGrad,
    required String icon,
    required String title,
    required String desc,
    required Color chevBg,
    required double margin,
  }) {
    return Press(
      scale: .98,
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: margin),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: grad,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(gradient: iconGrad, borderRadius: BorderRadius.circular(15)),
              child: Center(child: Ico(icon, size: 27, stroke: Colors.white, sw: 1.9)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: fd(size: rem(1.02), w: FontWeight.w800, color: K.ink, height: 1.15)),
                  const SizedBox(height: 3),
                  Text(desc, style: ff(size: rem(.66), w: FontWeight.w600, color: K.ink3, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 13),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: chevBg, shape: BoxShape.circle),
              child: Center(child: Ico(_chevR, size: 13, stroke: Colors.white, sw: 2.6, round: false)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: K.t0,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: K.t1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Ico(_info, size: 16, stroke: K.t7, sw: 1.7, round: false),
          ),
          const SizedBox(width: 9),
          Expanded(child: Text(text, style: ff(size: rem(.64), color: K.t7, height: 1.55))),
        ],
      ),
    );
  }

  // ── STEP 1 : Your Details ──
  Widget _step1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About You', style: fd(size: rem(1), w: FontWeight.w800, color: K.ink)),
        const SizedBox(height: 2),
        Text('Tell us who you are so we can verify your application.',
            style: ff(size: rem(.68), color: K.ink3)),
        const SizedBox(height: 14),
        // Quick contact card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: K.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: K.bd, width: 1.5),
            boxShadow: K.sh,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Prefer to talk first? Reach us directly',
                  style: ff(size: rem(.68), w: FontWeight.w700, color: K.ink)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _contactTile(
                      bg: const Color(0xFFF0FDF4),
                      border: const Color(0xFFBBF7D0),
                      iconBg: const Color(0xFF25D366),
                      icon: _wa,
                      iconFill: Colors.white,
                      title: 'WhatsApp Us',
                      titleColor: const Color(0xFF15803D),
                      sub: 'Chat with our team',
                      subColor: K.ok,
                      onTap: () => _launch(
                          'https://wa.me/919000012345?text=Hi%2C%20I%20want%20to%20join%20as%20a%20SuperHost%20on%20Invite%20Karoo',
                          'Opening WhatsApp…'),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _contactTile(
                      bg: K.t0,
                      border: K.t1,
                      iconBg: null,
                      iconGrad: const LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [K.t6, K.t7]),
                      icon: _phone,
                      title: 'Call Us',
                      titleColor: K.t7,
                      sub: 'Opens your dialer',
                      subColor: K.t6,
                      onTap: () => _launch('tel:+919000012345', 'Opening dialer…'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Container(height: 1, color: K.bd)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text('or fill the form below',
                        style: ff(size: rem(.58), w: FontWeight.w600, color: K.ink4)),
                  ),
                  Expanded(child: Container(height: 1, color: K.bd)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Lbl('Full Name'),
        Inp(controller: _c('name', Session.I.displayName == 'Guest' ? '' : Session.I.displayName), hint: 'Your full name', leadingIcon: _user, margin: 10),
        const Lbl('Mobile Number'),
        Inp(controller: _c('mobile', Session.I.mobile), hint: '+91 00000 00000', leadingIcon: _phone, mono_: true, margin: 10),
        const Lbl('Email Address'),
        Inp(controller: _c('email'), hint: 'you@email.com', leadingIcon: _mail, margin: 10),
        const Lbl('City & State'),
        Inp(controller: _c('cityState', Session.I.city), hint: 'City, State', leadingIcon: _pin, margin: 10),
        const Lbl('Your Role / Designation'),
        Inp(controller: _c('role'), hint: 'e.g. Venue Manager, Event Coordinator', leadingIcon: _briefcase, margin: 10),
        if (!_isWed) ...[
          const Lbl('Organisation Name'),
          Inp(controller: _c('orgName'), hint: 'e.g. Jain Community Trust, Sabha', leadingIcon: _users, margin: 10),
          const Lbl('Community Name'),
          Inp(controller: _c('communityName'), hint: 'e.g. Jain Samaj, Marwadi Samaj', leadingIcon: _flower, margin: 18),
        ],
        _navRow(backTo: 0, nextTo: 2, nextLabel: 'Next'),
      ],
    );
  }

  Widget _contactTile({
    required Color bg,
    required Color border,
    Color? iconBg,
    Gradient? iconGrad,
    required String icon,
    Color iconFill = Colors.white,
    required String title,
    required Color titleColor,
    required String sub,
    required Color subColor,
    required VoidCallback onTap,
  }) {
    return Press(
      scale: .98,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBg,
                gradient: iconGrad,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: icon == _wa
                    ? Ico(icon, size: 18, stroke: Colors.transparent, fill: Colors.white, sw: 0)
                    : Ico(icon, size: 16, stroke: Colors.white, sw: 2.2),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: ff(size: rem(.74), w: FontWeight.w700, color: titleColor)),
                  Text(sub, style: ff(size: rem(.58), color: subColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── STEP 2 : Venue / Couple Details ──
  Widget _step2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_isWed) ..._step2Community() else ..._step2Wedding(),
        const SizedBox(height: 0),
        _navRow(backTo: 1, nextTo: 3, nextLabel: 'Next'),
      ],
    );
  }

  List<Widget> _step2Community() {
    return [
      Text('Venue Details', style: fd(size: rem(1), w: FontWeight.w800, color: K.ink)),
      const SizedBox(height: 2),
      Text('Where will the events be hosted?', style: ff(size: rem(.68), color: K.ink3)),
      const SizedBox(height: 16),
      const Lbl('Venue Name'),
      Inp(controller: _c('venueName'), hint: 'e.g. Chennai Convention Centre', leadingIcon: _venue, margin: 10),
      const Lbl('Landmark & Area'),
      Inp(controller: _c('landmarkArea'), hint: 'e.g. Near Anna Nagar Metro, T. Nagar', leadingIcon: _pin, margin: 10),
      const Lbl('Full Venue Address'),
      Inp(controller: _c('venueAddress'), hint: 'Street, Area, City, Pincode', leadingIcon: _file, margin: 10),
      const Lbl('Estimated Daily Attendance'),
      Inp(controller: _c('dailyAttendance'), hint: 'e.g. 500 – 2500 people per day', leadingIcon: _users, mono_: true, margin: 18),
    ];
  }

  List<Widget> _step2Wedding() {
    return [
      Text('Couple & Venue', style: fd(size: rem(1), w: FontWeight.w800, color: K.ink)),
      const SizedBox(height: 2),
      Text('Tell us about the couple and where the wedding happens.',
          style: ff(size: rem(.68), color: K.ink3)),
      const SizedBox(height: 16),
      // Couple card
      Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment(-0.7, -1), end: Alignment(0.7, 1), colors: [K.white, _pinkBg]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _pinkBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_pink, _pinkLight]),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(child: Ico(_couple, size: 12, stroke: Colors.white, sw: 2.2, round: false)),
                ),
                const SizedBox(width: 6),
                Text('Couple Details', style: fd(size: rem(.78), w: FontWeight.w800, color: _pink)),
              ],
            ),
            const SizedBox(height: 11),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _miniField('Bride Name', 'e.g. Manisha Das', 'bride')),
                const SizedBox(width: 9),
                Expanded(child: _miniField('Groom Name', 'e.g. Amarjit Singh', 'groom')),
              ],
            ),
            const SizedBox(height: 9),
            _miniField('Family Name', 'e.g. Das & Singh Families', 'family'),
          ],
        ),
      ),
      const Lbl('Primary Wedding Venue'),
      Inp(controller: _c('weddingVenue'), hint: 'e.g. Marriott Banquet, Lokhra', leadingIcon: _venue, margin: 10),
      const Lbl('City & Area'),
      Inp(controller: _c('weddingCityArea'), hint: 'e.g. Lokhra Road, Guwahati', leadingIcon: _pin, margin: 10),
      const Lbl('Wedding Dates (From – To)'),
      Row(
        children: [
          Expanded(child: Inp(controller: _c('wdFrom'), hint: AppData.todayIso, mono_: true, margin: 18)),
          const SizedBox(width: 9),
          Expanded(
              child: Inp(
                  controller: _c('wdTo'),
                  hint: AppData.isoOf(AppData.todayDate.add(const Duration(days: 5))),
                  mono_: true,
                  margin: 18)),
        ],
      ),
    ];
  }

  Widget _miniField(String label, String hint, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 0),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(label.toUpperCase(), style: ff(size: rem(.58), w: FontWeight.w700, color: K.ink3, ls: .7)),
        ),
        Inp(controller: _c(key), hint: hint, margin: 0),
      ],
    );
  }

  // ── STEP 3 : Event / Wedding Plan ──
  Widget _step3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_isWed) ..._step3Community() else ..._step3Wedding(),
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: K.t0,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: K.t1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Ico(_info, size: 16, stroke: K.t7, sw: 1.7, round: false),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: ff(size: rem(.64), color: K.t7, height: 1.55),
                    children: [
                      const TextSpan(text: 'Invite Karoo team reviews your application in '),
                      TextSpan(text: '24–48 hrs', style: ff(size: rem(.64), w: FontWeight.w700, color: K.t7, height: 1.55)),
                      const TextSpan(text: ' and reaches you on your registered mobile.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Btn('Back', kind: BtnKind.s, leading: _arrowLeft, onTap: () => _go(2), margin: 0),
            ),
            const SizedBox(width: 9),
            Expanded(
              flex: 2,
              child: Btn('Submit Application',
                  kind: BtnKind.gold,
                  leading: _send,
                  onTap: _submit,
                  margin: 0),
            ),
          ],
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  List<Widget> _step3Community() {
    return [
      Text('Event Information', style: fd(size: rem(1), w: FontWeight.w800, color: K.ink)),
      const SizedBox(height: 2),
      Text('Tell us about the events you want to host.', style: ff(size: rem(.68), color: K.ink3)),
      const SizedBox(height: 16),
      const Lbl('Type of Event'),
      _SelectField(
        leadingIcon: _calendar,
        value: _eventType,
        options: _eventTypeOpts,
        margin: 10,
        onChanged: (v) => setState(() => _eventType = v),
      ),
      const Lbl('Hosting Which Guru / Speaker'),
      Inp(controller: _c('guru'), hint: 'e.g. Muni Tarun Sagar Ji, Pujya Gurudev', leadingIcon: _users, margin: 16),
    ];
  }

  List<Widget> _step3Wedding() {
    return [
      Text('Wedding Plan', style: fd(size: rem(1), w: FontWeight.w800, color: K.ink)),
      const SizedBox(height: 2),
      Text('How many functions and guests are you planning?', style: ff(size: rem(.68), color: K.ink3)),
      const SizedBox(height: 16),
      const Lbl('Number of Functions'),
      _SelectField(
        leadingIcon: _list,
        value: _funcCount,
        options: _funcCountOpts,
        margin: 10,
        onChanged: (v) => setState(() => _funcCount = v),
      ),
      const Lbl('Main Functions Planned'),
      Inp(controller: _c('mainFunctions'), hint: 'e.g. Haldi, Sangeet, Wedding, Reception', leadingIcon: _heart, margin: 10),
      const Lbl('Estimated Guest Count'),
      Inp(controller: _c('guestCount'), hint: 'e.g. 200 – 800 guests', leadingIcon: _users, mono_: true, margin: 10),
      const Lbl('Need digital invites for guests?'),
      _SelectField(
        leadingIcon: _invite,
        value: _invites,
        options: _invitesOpts,
        margin: 16,
        onChanged: (v) => setState(() => _invites = v),
      ),
    ];
  }

  Widget _navRow({required int backTo, required int nextTo, required String nextLabel}) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Btn('Back', kind: BtnKind.s, leading: _arrowLeft, onTap: () => _go(backTo), margin: 0),
        ),
        const SizedBox(width: 9),
        Expanded(
          flex: 2,
          child: Btn(nextLabel, kind: BtnKind.p, trailing: _arrowRight, onTap: () => _go(nextTo), margin: 0),
        ),
      ],
    );
  }
}

/// Dropdown styled to match the .inp form field (leading icon + chevron).
class _SelectField extends StatelessWidget {
  final String leadingIcon;
  final String value;
  final List<String> options;
  final double margin;
  final ValueChanged<String> onChanged;
  const _SelectField({
    required this.leadingIcon,
    required this.value,
    required this.options,
    required this.onChanged,
    this.margin = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: margin),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        isDense: true,
        icon: Ico('<polyline points="6 9 12 15 18 9"/>',
            size: 16, stroke: K.ink4, sw: 1.9),
        style: ff(size: rem(.81), color: K.ink),
        dropdownColor: K.white,
        borderRadius: BorderRadius.circular(11),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: K.white,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Ico(leadingIcon, size: 16, stroke: K.ink4, sw: 1.9),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide(color: K.bd2, width: 1.5)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide(color: K.bd2, width: 1.5)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: K.t6, width: 1.5)),
        ),
        items: [
          for (final o in options)
            DropdownMenuItem<String>(
              value: o,
              child: Text(o, style: ff(size: rem(.81), color: K.ink)),
            ),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int step; // 1..3
  final List<String> labels;
  final void Function(int) onTap;
  const _StepIndicator({required this.step, required this.labels, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget bubble(int n) {
      final done = n < step; // completed step → green
      final on = n == step; // current step → white
      // Bubble fill: white (current), green gradient (done), transparent (upcoming).
      final Gradient? grad = done
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF16A34A), Color(0xFF15803D)])
          : null;
      final Color? fill = on ? Colors.white : null;
      final Color borderColor =
          done ? const Color(0xFF16A34A) : (on ? Colors.white : Colors.white.withOpacity(.35));
      final Color numColor = on
          ? K.t7
          : done
              ? Colors.white
              : Colors.white.withOpacity(.6);
      final active = done || on;
      return Press(
        scale: .96,
        onTap: () => onTap(n),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: fill,
                gradient: grad,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Center(
                child: Text('$n',
                    style: mono(size: rem(.72), w: FontWeight.w700, color: numColor)),
              ),
            ),
            const SizedBox(height: 4),
            Text(labels[n - 1].toUpperCase(),
                style: ff(
                    size: rem(.52),
                    w: FontWeight.w700,
                    ls: .4,
                    color: active ? Colors.white.withOpacity(.9) : Colors.white.withOpacity(.5))),
          ],
        ),
      );
    }

    // .sh-line: 2px, green when the step before it is done, else faint white.
    // Sits vertically centred on the 30px bubble (top:-12px in HTML).
    Widget line(int k) => Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.only(bottom: 18, left: 4, right: 4),
            color: k < step ? const Color(0xFF16A34A).withOpacity(.7) : Colors.white.withOpacity(.2),
          ),
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        bubble(1),
        line(1),
        bubble(2),
        line(2),
        bubble(3),
      ],
    );
  }
}

/// Full-screen success overlay shown after the host application is submitted.
class _HostSuccess extends StatelessWidget {
  final VoidCallback onClose;
  const _HostSuccess({required this.onClose});

  Widget _circle(double s, Color c) =>
      Container(width: s, height: s, decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF052E16), Color(0xFF166534), Color(0xFF16A34A)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: -60, right: -60, child: _circle(200, Colors.white.withOpacity(.05))),
            Positioned(bottom: -80, left: -50, child: _circle(230, Colors.white.withOpacity(.04))),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Check ring
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(.14),
                        border: Border.all(color: Colors.white.withOpacity(.25), width: 2),
                      ),
                      child: const Center(
                          child: Ico(P.check, size: 44, stroke: Colors.white, sw: 2.4)),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Congratulations!',
                            style: fd(size: rem(1.7), w: FontWeight.w800, color: Colors.white)),
                        const SizedBox(width: 8),
                        const Ico(P.sparkle, size: 22, stroke: Color(0xFFFDE68A), sw: 2),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Form Has been Submitted Successfully',
                        textAlign: TextAlign.center,
                        style: ff(size: rem(.92), w: FontWeight.w700, color: Colors.white, height: 1.4)),
                    const SizedBox(height: 10),
                    Text(
                        'Our team reviews your application in 24–48 hrs and reaches you on your registered mobile.',
                        textAlign: TextAlign.center,
                        style: ff(size: rem(.74), color: Colors.white.withOpacity(.6), height: 1.55)),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: Btn('Done',
                          kind: BtnKind.white, trailing: P.arrowRight, onTap: onClose, margin: 0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
