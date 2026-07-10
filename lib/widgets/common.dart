import 'package:flutter/material.dart';
import '../theme.dart';
import 'svg.dart';

/// Tap wrapper with a press-scale animation (mirrors `:active{transform:scale()}`).
class Press extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final double dx; // horizontal nudge (for back buttons)
  const Press({super.key, required this.child, this.onTap, this.scale = .97, this.dx = 0});
  @override
  State<Press> createState() => _PressState();
}

class _PressState extends State<Press> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        transform: _down
            ? (Matrix4.identity()
              ..translate(widget.dx, 0.0)
              ..scale(widget.scale))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}

/// App bar (.ab) — white bar with back chevron + title/subtitle + optional actions.
class AppBarX extends StatelessWidget {
  final String title;
  final String? sub;
  final String? back; // screen id for back button
  final VoidCallback? onBack;
  final List<Widget> actions;
  const AppBarX({super.key, required this.title, this.sub, this.back, this.onBack, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: BoxDecoration(
        color: K.white,
        border: Border(bottom: BorderSide(color: K.bd)),
      ),
      child: Row(
        children: [
          if (back != null || onBack != null) ...[
            BackBtn(onTap: onBack ?? () {}, dark: true),
            const SizedBox(width: 9),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: fd(size: rem(1.06), w: FontWeight.w700, color: K.ink, ls: -.2)),
                if (sub != null) Text(sub!, style: ff(size: rem(.6), color: K.ink4)),
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

/// Back chevron (.bk). [dark]=true uses t7, false uses white.
class BackBtn extends StatelessWidget {
  final VoidCallback onTap;
  final bool dark;
  final String? label;
  const BackBtn({super.key, required this.onTap, this.dark = true, this.label});
  @override
  Widget build(BuildContext context) {
    final c = dark ? K.t7 : Colors.white.withOpacity(.85);
    return Press(
      dx: -3,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Ico(P.arrowLeft, size: 18, stroke: c, sw: 2.2),
          if (label != null) ...[
            const SizedBox(width: 4),
            Text(label!, style: ff(size: rem(.72), w: FontWeight.w600, color: c)),
          ],
        ],
      ),
    );
  }
}

/// Icon button (.ib)
class IbBtn extends StatelessWidget {
  final String icon;
  final VoidCallback? onTap;
  final double iconSize;
  const IbBtn(this.icon, {super.key, this.onTap, this.iconSize = 16});
  @override
  Widget build(BuildContext context) {
    return Press(
      scale: .9,
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: K.t0,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: K.t1),
        ),
        child: Center(child: Ico(icon, size: iconSize, stroke: K.t7, sw: 1.8)),
      ),
    );
  }
}

enum BtnKind { p, ok, s, o, er, gold, white }

/// Primary action button (.btn variants).
class Btn extends StatelessWidget {
  final String label;
  final BtnKind kind;
  final String? leading; // svg inner
  final String? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final double? fontSize;
  final double margin;
  const Btn(this.label,
      {super.key,
      this.kind = BtnKind.p,
      this.leading,
      this.trailing,
      this.onTap,
      this.padding,
      this.fontSize,
      this.margin = 8});

  @override
  Widget build(BuildContext context) {
    Gradient? grad;
    Color? bg;
    Color fg;
    Border? border;
    List<BoxShadow>? shadow;
    switch (kind) {
      case BtnKind.p:
        grad = K.gPurple;
        fg = Colors.white;
        shadow = [BoxShadow(color: const Color(0xFF5C3E9E).withOpacity(.32), blurRadius: 16, offset: const Offset(0, 4))];
        break;
      case BtnKind.ok:
        grad = K.gOk;
        fg = Colors.white;
        break;
      case BtnKind.s:
        bg = Colors.transparent;
        fg = K.t7;
        border = Border.all(color: K.t5, width: 1.5);
        break;
      case BtnKind.o:
        bg = K.t0;
        fg = K.ink2;
        border = Border.all(color: K.t1, width: 1.5);
        break;
      case BtnKind.er:
        grad = const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [K.er, Color(0xFF991B1B)]);
        fg = Colors.white;
        break;
      case BtnKind.gold:
        grad = K.gGold;
        fg = Colors.white;
        break;
      case BtnKind.white:
        bg = Colors.white;
        fg = K.t7;
        break;
    }
    final pad = padding ??
        (kind == BtnKind.o
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 9)
            : const EdgeInsets.symmetric(horizontal: 18, vertical: 13));
    final fs = fontSize ?? (kind == BtnKind.o ? rem(.75) : rem(.82));
    return Press(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: margin),
        padding: pad,
        decoration: BoxDecoration(
          gradient: grad,
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: border,
          boxShadow: shadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[Ico(leading!, size: 16, stroke: fg, sw: 2), const SizedBox(width: 8)],
            Flexible(child: Text(label, style: ff(size: fs, w: FontWeight.w700, color: fg), textAlign: TextAlign.center)),
            if (trailing != null) ...[const SizedBox(width: 8), Ico(trailing!, size: 16, stroke: fg, sw: 2.2)],
          ],
        ),
      ),
    );
  }
}

enum ChipKind { p, g, a, e, i }

/// Status chip (.chip cp/cg/ca/ce/ci)
class Chip2 extends StatelessWidget {
  final String text;
  final ChipKind kind;
  final String? leading;
  final double? fontSize;
  const Chip2(this.text, {super.key, this.kind = ChipKind.p, this.leading, this.fontSize});
  @override
  Widget build(BuildContext context) {
    Color bg, fg, bd;
    switch (kind) {
      case ChipKind.p:
        bg = K.t1; fg = K.t7; bd = K.t2; break;
      case ChipKind.g:
        bg = K.ok1; fg = K.ok; bd = const Color(0xFF16A34A).withOpacity(.18); break;
      case ChipKind.a:
        bg = K.g1; fg = K.g5; bd = const Color(0xFFF5A623).withOpacity(.22); break;
      case ChipKind.e:
        bg = K.er1; fg = K.er; bd = const Color(0xFFDC2626).withOpacity(.15); break;
      case ChipKind.i:
        bg = K.in1; fg = K.inC; bd = const Color(0xFF1D4ED8).withOpacity(.15); break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(17), border: Border.all(color: bd)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[Ico(leading!, size: 9, stroke: fg, sw: 2), const SizedBox(width: 3)],
          Text(text, style: ff(size: fontSize ?? rem(.6), w: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}

/// Card (.card)
class CardX extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double margin;
  final VoidCallback? onTap;
  final Color? bg;
  final Border? border;
  final BorderRadius? radius;
  const CardX(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(13),
      this.margin = 10,
      this.onTap,
      this.bg,
      this.border,
      this.radius});
  @override
  Widget build(BuildContext context) {
    final w = Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: margin),
      padding: padding,
      decoration: BoxDecoration(
        color: bg ?? K.white,
        borderRadius: radius ?? BorderRadius.circular(14),
        border: border ?? Border.all(color: K.bd),
        boxShadow: K.sh,
      ),
      child: child,
    );
    return onTap == null ? w : Press(scale: .98, onTap: onTap, child: w);
  }
}

/// Section label (.sec)
class Sec extends StatelessWidget {
  final String text;
  final EdgeInsets padding;
  const Sec(this.text, {super.key, this.padding = const EdgeInsets.fromLTRB(18, 12, 18, 6)});
  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: Text(text.toUpperCase(),
            style: ff(size: rem(.56), w: FontWeight.w700, color: K.ink4, ls: 2)),
      );
}

/// Field label (.lbl)
class Lbl extends StatelessWidget {
  final String text;
  const Lbl(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Text(text.toUpperCase(), style: ff(size: rem(.58), w: FontWeight.w700, color: K.ink3, ls: .7)),
      );
}

/// Text input (.inp)
class Inp extends StatelessWidget {
  final String? hint;
  final String? value;
  final String? leadingIcon;
  final TextEditingController? controller;
  final bool mono_;
  final double margin;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  const Inp(
      {super.key,
      this.hint,
      this.value,
      this.leadingIcon,
      this.controller,
      this.mono_ = false,
      this.margin = 9,
      this.onChanged,
      this.onSubmitted});
  @override
  Widget build(BuildContext context) {
    final ctl = controller ?? (value != null ? TextEditingController(text: value) : null);
    return Container(
      margin: EdgeInsets.only(bottom: margin),
      child: TextField(
        controller: ctl,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: mono_ ? mono(size: rem(.88), w: FontWeight.w500, color: K.ink) : ff(size: rem(.81), color: K.ink),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: ff(size: rem(.81), color: K.ink4),
          filled: true,
          fillColor: K.white,
          prefixIcon: leadingIcon == null
              ? null
              : Padding(padding: const EdgeInsets.only(left: 12, right: 8), child: Ico(leadingIcon!, size: 16, stroke: K.ink4, sw: 1.9)),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide(color: K.bd2, width: 1.5)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide(color: K.bd2, width: 1.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: K.t6, width: 1.5)),
        ),
      ),
    );
  }
}

/// Toggle (.tog)
class Toggle extends StatelessWidget {
  final bool on;
  final ValueChanged<bool>? onChanged;
  const Toggle({super.key, required this.on, this.onChanged});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!on),
      child: Container(
        width: 40,
        height: 23,
        decoration: BoxDecoration(color: on ? K.t6 : K.cream2, borderRadius: BorderRadius.circular(12)),
        child: Stack(children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: 2,
            left: on ? 22 : 2,
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 3, offset: const Offset(0, 1))],
              ),
            ),
          )
        ]),
      ),
    );
  }
}

/// Pill tab (.tab)
class TabPill extends StatelessWidget {
  final String label;
  final bool on;
  final VoidCallback? onTap;
  const TabPill(this.label, {super.key, this.on = false, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: on ? K.gPurpleDeep : null,
          color: on ? null : K.cream,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: on ? Colors.transparent : K.bd),
        ),
        child: Text(label,
            style: ff(size: rem(.7), w: on ? FontWeight.w700 : FontWeight.w600, color: on ? Colors.white : K.ink3)),
      ),
    );
  }
}

/// Bottom navigation (.bnav)
class BottomNav extends StatelessWidget {
  final int active; // 0 home,1 logs,2 communities,3 profile
  const BottomNav({super.key, required this.active});
  @override
  Widget build(BuildContext context) {
    final items = [
      (P.home, 'Home', 's03'),
      (P.file, 'Logs', 's39'),
      (P.flower, 'Communities', 's09'),
      (P.userNav, 'Profile', 's20'),
    ];
    return Container(
      padding: const EdgeInsets.only(top: 7, bottom: 14),
      decoration: BoxDecoration(
        color: K.cream.withOpacity(.97),
        border: Border(top: BorderSide(color: K.bd)),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final on = i == active;
          final c = on ? K.t6 : K.ink4;
          return Expanded(
            child: Press(
              scale: .95,
              onTap: () { if (!on) navTo(items[i].$3); },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Ico(items[i].$1, size: 20, stroke: c, sw: on ? 2.2 : 1.7),
                  const SizedBox(height: 3),
                  Text(items[i].$2, style: ff(size: rem(.53), w: FontWeight.w600, color: c)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// late-bound nav to avoid import cycle
void Function(String) navTo = (_) {};

/// A scrollable content area (.sc) with hidden scrollbar.
class Sc extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final ScrollController? controller;
  final CrossAxisAlignment cross;
  const Sc(this.children,
      {super.key, this.padding = EdgeInsets.zero, this.controller, this.cross = CrossAxisAlignment.stretch});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ScrollConfiguration(
        behavior: const _NoBar(),
        child: SingleChildScrollView(
          controller: controller,
          padding: padding,
          child: Column(crossAxisAlignment: cross, children: children),
        ),
      ),
    );
  }
}

class _NoBar extends ScrollBehavior {
  const _NoBar();
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) => child;
}

/// Small circular avatar / icon tile.
class GBox extends StatelessWidget {
  final double size;
  final Gradient? gradient;
  final Color? color;
  final double radius;
  final Widget child;
  final List<BoxShadow>? shadow;
  final Border? border;
  const GBox(
      {super.key,
      required this.size,
      this.gradient,
      this.color,
      this.radius = 11,
      required this.child,
      this.shadow,
      this.border});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: gradient,
          color: color,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: shadow,
          border: border,
        ),
        alignment: Alignment.center,
        child: child,
      );
}
