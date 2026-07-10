import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../session.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

const _edit =
    '<path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>';
const _chevR = '<polyline points="9 18 15 12 9 6"/>';
const _star =
    '<path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>';
const _flower =
    '<circle cx="12" cy="12" r="2.5"/><path d="M12 9.5c0-2 1.5-3.5 0-5.5-1.5 2-1.5 3.5 0 5.5M12 14.5c0 2-1.5 3.5 0 5.5 1.5-2 1.5-3.5 0-5.5M9.5 12c-2 0-3.5 1.5-5.5 0 2-1.5 3.5-1.5 5.5 0M14.5 12c2 0 3.5-1.5 5.5 0-2 1.5-3.5 1.5-5.5 0"/>';
const _heart =
    '<path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"/>';
const _arrowRight = '<line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/>';
const _fileLines =
    '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/>';
const _venue = '<path d="M3 21h18M5 21V7l8-4v18M19 21V11l-6-3"/>';
const _bookmark = '<path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/>';
const _chat = '<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>';
const _settings =
    '<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>';

class S20 extends StatelessWidget {
  const S20({super.key});
  @override
  Widget build(BuildContext context) {
    final s = Session.I;
    final mobile = s.mobile.trim();
    return Container(
      color: K.cream,
      child: Column(
        children: [
          // ── Dark gradient header ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
            decoration: const BoxDecoration(gradient: K.gHeader),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: BackBtn(dark: false, onTap: () => go('s03')),
                  ),
                ),
                Container(
                  width: 72,
                  height: 72,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.16),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(.25), width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(s.initials, style: fd(size: rem(1.3), w: FontWeight.w800, color: Colors.white)),
                ),
                Text(s.displayName,
                    style: fd(size: rem(1.2), w: FontWeight.w800, color: Colors.white)),
                Text(mobile.isEmpty ? 'Add your mobile number' : mobile,
                    style: ff(size: rem(.66), color: Colors.white.withOpacity(.5))),
              ],
            ),
          ),
          Sc(
            padding: const EdgeInsets.symmetric(vertical: 14),
            [
              // ── Stats grid ──
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                child: Row(
                  children: [
                    _StatBox(value: '${AppData.I.subscriptions.length}', label: 'Venues'),
                    const SizedBox(width: 8),
                    _StatBox(value: '${AppData.I.saved.length}', label: 'Saved'),
                    const SizedBox(width: 8),
                    _StatBox(
                        value: '${AppData.I.reminderPrefs.values.where((p) => p['push'] == true && p['muted'] != true).length}',
                        label: 'Reminders'),
                  ],
                ),
              ),

              // ── Profile ──
              const Sec('Profile'),
              _EditProfileRow(),

              // ── Become a Host ──
              const Sec('Become a Host'),
              _HostCta(),

              // ── Activity ──
              const Sec('Activity'),
              _ActivityRow(icon: _fileLines, label: 'My Attendance', to: 's33'),
              _ActivityRow(icon: _venue, label: 'My Communities', to: 's09'),
              _ActivityRow(icon: _bookmark, label: 'Saved Programmes', to: 's14'),
              _ActivityRow(icon: _chat, label: 'Support & Tickets', to: 's18'),
              _ActivityRow(icon: _settings, label: 'Settings', to: 's22'),
              const SizedBox(height: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: K.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: K.bd),
        ),
        child: Column(
          children: [
            Text(value, style: fd(size: rem(1.2), w: FontWeight.w800, color: K.ink)),
            Text(label, style: ff(size: rem(.55), color: K.ink3)),
          ],
        ),
      ),
    );
  }
}

/// Edit Profile row → go('s29'). Highlighted (t0 bg, t1 border) with gradient icon tile.
class _EditProfileRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Press(
      scale: .99,
      onTap: () => go('s29'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: K.t0,
          border: Border.all(color: K.t1),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [K.t6, K.t8],
                ),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: const Color(0xFFA48CDC).withOpacity(.3), width: 2),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF2D1B69).withOpacity(.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3)),
                ],
              ),
              child: Center(child: Ico(_edit, size: 20, stroke: Colors.white, sw: 2)),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Edit Profile', style: ff(size: rem(.78), w: FontWeight.w700, color: K.ink)),
                  Text('Name, photo, address, contact',
                      style: ff(size: rem(.6), color: K.ink3)),
                ],
              ),
            ),
            Ico(_chevR, size: 15, stroke: K.t6, sw: 2.2),
          ],
        ),
      ),
    );
  }
}

/// Activity row (.row) → go(to). Plain .ib icon tile.
class _ActivityRow extends StatelessWidget {
  final String icon;
  final String label;
  final String to;
  const _ActivityRow({required this.icon, required this.label, required this.to});
  @override
  Widget build(BuildContext context) {
    return Press(
      scale: .99,
      onTap: () => go(to),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: K.white,
          border: Border(bottom: BorderSide(color: K.bd)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: K.t0,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: K.t1),
              ),
              child: Center(child: Ico(icon, size: 16, stroke: K.t7, sw: 1.8)),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(label, style: ff(size: rem(.78), w: FontWeight.w600, color: K.ink)),
            ),
            Ico(_chevR, size: 15, stroke: K.ink4, sw: 2.2),
          ],
        ),
      ),
    );
  }
}

/// Premium "Become a Host" CTA → go('s23').
class _HostCta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Press(
      scale: .98,
      onTap: () => go('s23'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [K.t9, K.t7, K.t6],
            stops: [0.0, 0.45, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFC4AEE8).withOpacity(.18)),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF2D1B69).withOpacity(.4),
                blurRadius: 30,
                offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top: icon + title
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: K.gGold,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFFF5A623).withOpacity(.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Center(child: Ico(_star, size: 27, stroke: Colors.white, sw: 2.1)),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5A623).withOpacity(.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFF5A623).withOpacity(.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                    color: K.g3, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 4),
                              Text('PREMIUM',
                                  style: ff(
                                      size: rem(.5),
                                      w: FontWeight.w800,
                                      color: K.g2,
                                      ls: .5)),
                            ],
                          ),
                        ),
                        Text('Become a Host',
                            style: fd(
                                size: rem(1.22),
                                w: FontWeight.w800,
                                color: Colors.white,
                                ls: -.3,
                                height: 1.1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Subtitle
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: RichText(
                text: TextSpan(
                  style: ff(
                      size: rem(.76),
                      w: FontWeight.w600,
                      color: Colors.white.withOpacity(.82),
                      height: 1.4),
                  children: [
                    const TextSpan(text: 'Apply to host your own '),
                    TextSpan(
                        text: 'community events',
                        style: ff(size: rem(.76), w: FontWeight.w800, color: K.g2, height: 1.4)),
                    const TextSpan(text: ' or '),
                    TextSpan(
                        text: 'weddings',
                        style: ff(size: rem(.76), w: FontWeight.w800, color: K.g2, height: 1.4)),
                    const TextSpan(text: ' — all in one place.'),
                  ],
                ),
              ),
            ),
            // Two track chips
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                children: [
                  _trackChip(_flower, 'Community', const Color(0xFFC4AEE8),
                      const Color(0xFFC4AEE8).withOpacity(.3)),
                  const SizedBox(width: 10),
                  _trackChip(_heart, 'Wedding', const Color(0xFFF0ABFC),
                      const Color(0xFFF0ABFC).withOpacity(.35)),
                ],
              ),
            ),
            // Gold CTA button
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: K.gGold,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFFF5A623).withOpacity(.45),
                      blurRadius: 18,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Apply Now',
                      style: ff(size: rem(.9), w: FontWeight.w800, color: Colors.white, ls: .2)),
                  const SizedBox(width: 9),
                  Ico(_arrowRight, size: 16, stroke: Colors.white, sw: 2.8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _trackChip(String icon, String label, Color iconColor, Color borderColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.08),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Ico(icon, size: 22, stroke: iconColor, sw: 2),
            ),
            Text(label,
                style: ff(size: rem(.74), w: FontWeight.w800, color: Colors.white, height: 1.2)),
          ],
        ),
      ),
    );
  }
}
