import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

// Bell icon without the clapper (exact inner markup from the HTML).
const _bell = '<path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>';

// Simplified calendar (exact inner markup from the HTML — rect + single divider line).
const _calendarIcon =
    '<rect x="3" y="4" width="18" height="18" rx="2"/><line x1="3" y1="10" x2="21" y2="10"/>';

class S07 extends StatefulWidget {
  const S07({super.key});
  @override
  State<S07> createState() => _S07State();
}

class _S07State extends State<S07> {
  bool _calendar = true;
  bool _push = true;

  @override
  Widget build(BuildContext context) {
    final c = AppData.I.selectedCommunity;
    final name = c != null ? '${c['name'] ?? ''}' : '';
    final venue = c != null ? '${c['venue'] ?? ''}' : '';
    final venueTitle = venue.isNotEmpty ? venue : (name.isNotEmpty ? name : 'This community');
    return Container(
      color: K.cream,
      child: Column(
        children: [
          AppBarX(
            title: 'Subscribe',
            sub: name.isNotEmpty ? name : 'Community',
            onBack: () => go('s34'),
          ),
          Sc(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            [
              // Venue summary card
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: K.t0,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: K.t1),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [K.t7, K.t5], // #3D2582 -> #7C5CBF
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                          child: Ico(P.venue, size: 24, stroke: Colors.white, sw: 1.8)),
                    ),
                    Text(venueTitle,
                        textAlign: TextAlign.center,
                        style: fd(size: rem(1.05), w: FontWeight.w800, color: K.ink)),
                    const SizedBox(height: 3),
                    Text("You'll get all programme updates here.",
                        textAlign: TextAlign.center,
                        style: ff(size: rem(.68), color: K.ink3)),
                  ],
                ),
              ),
              const Sec("What you'll receive", padding: EdgeInsets.fromLTRB(0, 4, 0, 8)),
              _ToggleRow(
                icon: _calendarIcon,
                label: 'Auto-add to my calendar',
                on: _calendar,
                onChanged: (v) => setState(() => _calendar = v),
              ),
              _ToggleRow(
                icon: _bell,
                label: 'Push notifications for updates',
                on: _push,
                onChanged: (v) => setState(() => _push = v),
              ),
              Btn('Confirm Subscribe', kind: BtnKind.p, onTap: () => go('s08')),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String icon;
  final String label;
  final bool on;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.on,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CardX(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Ico(icon, size: 17, stroke: K.t6, sw: 1.8),
                const SizedBox(width: 9),
                Flexible(
                  child: Text(label,
                      style: ff(size: rem(.76), w: FontWeight.w600, color: K.ink2)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          Toggle(on: on, onChanged: onChanged),
        ],
      ),
    );
  }
}
