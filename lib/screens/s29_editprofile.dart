import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../session.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

const _email = '<rect x="2" y="4" width="20" height="16" rx="2"/><path d="m22 7-10 5L2 7"/>';
const _sparkleReligion =
    '<path d="M12 3l1.9 5.8a2 2 0 0 0 1.3 1.3L21 12l-5.8 1.9a2 2 0 0 0-1.3 1.3L12 21l-1.9-5.8a2 2 0 0 0-1.3-1.3L3 12l5.8-1.9a2 2 0 0 0 1.3-1.3z"/>';
const _camera =
    '<path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/>';
const _users =
    '<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>';

class S29 extends StatefulWidget {
  const S29({super.key});
  @override
  State<S29> createState() => _S29State();
}

class _S29State extends State<S29> {
  late final TextEditingController _name;
  late final TextEditingController _family;
  late final TextEditingController _mobile;
  late final TextEditingController _city;

  @override
  void initState() {
    super.initState();
    final s = Session.I;
    _name = TextEditingController(text: s.fullName);
    _family = TextEditingController(text: s.familyName);
    _mobile = TextEditingController(text: s.mobile);
    _city = TextEditingController(text: s.city);
  }

  @override
  void dispose() {
    _name.dispose();
    _family.dispose();
    _mobile.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await Session.I.signIn(
      name: _name.text,
      family: _family.text,
      mobile: _mobile.text,
      city: _city.text,
    );
    await AppData.I.syncProfileToCloud(); // follow the account across devices
    if (!mounted) return;
    go('s30');
  }

  @override
  Widget build(BuildContext context) {
    final s = Session.I;
    return Container(
      color: K.cream,
      child: Column(
        children: [
          // Header with avatar + change photo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
            decoration: const BoxDecoration(gradient: K.gHeader),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  bottom: -30,
                  right: -20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5A623).withOpacity(.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        BackBtn(onTap: () => go('s22'), dark: false),
                        const SizedBox(width: 9),
                        Text('Edit Profile',
                            style: fd(size: rem(1.15), w: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.16),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(.3), width: 3),
                                ),
                                child: Text(s.initials,
                                    style: fd(size: rem(1.7), w: FontWeight.w800, color: Colors.white)),
                              ),
                              Positioned(
                                bottom: -2,
                                right: -2,
                                child: Press(
                                  scale: .9,
                                  onTap: () => toast('Open photo picker / camera'),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: K.gGold,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: K.t8, width: 3),
                                      boxShadow: [
                                        BoxShadow(
                                            color: const Color(0xFFF5A623).withOpacity(.45),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3))
                                      ],
                                    ),
                                    child: Ico(_camera, size: 14, stroke: Colors.white, sw: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Press(
                            onTap: () => toast('Change profile photo'),
                            child: Text('Change Profile Photo',
                                style: ff(size: rem(.66), w: FontWeight.w700, color: K.g3)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Sc(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            [
              const Sec('Personal Details', padding: EdgeInsets.fromLTRB(0, 0, 0, 8)),
              const Lbl('Full Name'),
              Inp(controller: _name, hint: 'Your full name', leadingIcon: P.user, margin: 10),
              const Lbl('Family Name'),
              Inp(controller: _family, hint: 'Family name', leadingIcon: _users, margin: 10),
              const Lbl('Mobile Number'),
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  Inp(controller: _mobile, hint: '+91 00000 00000', leadingIcon: P.phone, mono_: true, margin: 4),
                  Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 4),
                    child: Press(
                      onTap: () => toast('OTP sent to verify new number'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: K.t1,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Verify',
                            style: ff(size: rem(.58), w: FontWeight.w700, color: K.t7)),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 0, 0, 10),
                child: Text('Changing your number needs OTP verification.',
                    style: ff(size: rem(.56), color: K.ink4)),
              ),
              const Lbl('Email Address'),
              const Inp(hint: 'you@email.com', leadingIcon: _email, margin: 10),
              const Lbl('Additional Number'),
              const Inp(hint: 'Alternate mobile (optional)', leadingIcon: P.phone, mono_: true, margin: 10),
              const Lbl('Religion'),
              const _SelectField(value: 'Jain', leadingIcon: _sparkleReligion),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [Lbl('Gender'), _SelectField(value: 'Male')],
                    ),
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [_DobLabel(), Inp(hint: 'YYYY-MM-DD', mono_: true, margin: 0)],
                    ),
                  ),
                ],
              ),
              const Sec('Address', padding: EdgeInsets.fromLTRB(0, 8, 0, 8)),
              const Lbl('Address Line'),
              const Inp(hint: 'House / Flat, Street, Area', leadingIcon: P.pin, margin: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [const Lbl('City'), Inp(controller: _city, hint: 'City', margin: 9)],
                    ),
                  ),
                  const SizedBox(width: 9),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [Lbl('Pincode'), Inp(hint: '000000', mono_: true, margin: 9)],
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [Lbl('District'), Inp(hint: 'District', margin: 9)],
                    ),
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [Lbl('State'), Inp(hint: 'State', margin: 9)],
                    ),
                  ),
                ],
              ),
              const Sec('Preferences', padding: EdgeInsets.fromLTRB(0, 8, 0, 8)),
              const Lbl('Preferred Language'),
              const _SelectField(value: 'English'),
              const SizedBox(height: 6),
              Btn('Save Changes', kind: BtnKind.p, leading: P.check, onTap: _save),
              Btn('Cancel', kind: BtnKind.s, onTap: () => go('s22')),
              const SizedBox(height: 14),
            ],
          ),
        ],
      ),
    );
  }
}

class _DobLabel extends StatelessWidget {
  const _DobLabel();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: RichText(
        text: TextSpan(
          text: 'DATE OF BIRTH ',
          style: ff(size: rem(.58), w: FontWeight.w700, color: K.ink3, ls: .7),
          children: [
            TextSpan(text: '(type or pick)', style: ff(size: rem(.54), w: FontWeight.w500, color: K.ink4)),
          ],
        ),
      ),
    );
  }
}

/// Mirrors a `<select class="inp">` — read-only styled box with chevron.
class _SelectField extends StatelessWidget {
  final String value;
  final String? leadingIcon;
  const _SelectField({required this.value, this.leadingIcon});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: K.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: K.bd2, width: 1.5),
      ),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            Ico(leadingIcon!, size: 16, stroke: K.ink4, sw: 1.9),
            const SizedBox(width: 10),
          ],
          Expanded(child: Text(value, style: ff(size: rem(.81), color: K.ink))),
          Ico(P.chevDown, size: 16, stroke: K.ink4, sw: 1.9),
        ],
      ),
    );
  }
}
