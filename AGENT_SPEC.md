# Invite Karoo — Flutter port spec (READ FULLY before coding)

You are porting screens of a phone-app prototype from HTML/CSS/JS into Flutter.
**Goal: faithful visual + behavioral replica.** Match layout, text (verbatim),
colors, font sizes, spacing, icons, and interactivity.

## Source
`C:\Users\saptr\Downloads\INVITE KAROO VERSION 01 FINAL.html`
- Each screen is `<div class="pg" id="pg-sXX"> … </div>`. Find yours by that id.
- Dynamic content is rendered by JS functions (`<script>` from line ~2174).
  Read the JS functions named in your task and reproduce their output as static
  Flutter widgets driven by the same demo data (transcribe the data verbatim).

## What you OUTPUT
One Dart file per screen at `lib/screens/sXX_name.dart` exposing a public widget
**class `SXX`** (e.g. `class S12 extends StatelessWidget`). Use a `const`
constructor when possible; use `StatefulWidget` when the screen has local state
(tabs, toggles, steppers, countdowns, expand/collapse, filters).
- The class returns ONLY the screen body. The phone frame, notch, and status bar
  are added by the shell — DO NOT add them.
- The body must fill height. Pattern:
  ```dart
  return Container(color: K.cream, child: Column(children: [ header…, Sc([...]) ]));
  ```
  `Sc(children, padding:…)` is an Expanded scroll area (see below). Screens that
  are a single full-bleed gradient (success screens) just return that Container.
- DO NOT edit `registry.dart`, `main.dart`, or shared widget files. Only create
  your screen file(s). Report the class name + file path in your final message.
- Put screen-specific demo data and render helpers as private top-level
  funcs/consts in the same file.

## Available imports (use these; do not reinvent)
```dart
import '../theme.dart';
import '../app_state.dart';
import '../widgets/common.dart';
import '../widgets/header.dart';
import '../widgets/svg.dart';
```

### theme.dart
- `class K` color tokens (Color):
  t9 #1A0E3D, t8 #2D1B69, t7 #3D2582, t6 #5B3E9E, t5 #7C5CBF, t4 #A07ED4,
  t3 #C4AEE8, t2 #D4C4EE, t1 #EDE6F7, t0 #F7F4FC,
  g5 #B45309, g4 #D97706, g3 #F5A623, g2 #FDE68A, g1 #FEF3D5,
  ok #16A34A, ok1 #DCFCE7, er #DC2626, er1 #FEE2E2, inC #1D4ED8, in1 #DBEAFE,
  ink #1A1028, ink2 #3D2D5C, ink3 #6B5A8A, ink4 #A89BC0,
  cream #F5EFE8, cream2 #EDE5DB, white, phoneBg.
  `K.bd` / `K.bd2` = purple border colors. `K.sh` = standard card shadow (List<BoxShadow>).
  Gradients: `K.gPurple` (135° t5→t7), `K.gPurpleDeep` (t9→t7), `K.gGold` (g3→g4),
  `K.gOk` (ok→dark green), `K.gHeader` (155° t9→t7→t5).
- `rem(double)` → px (CSS rem×16). Use for ALL font sizes: e.g. `.78rem` → `rem(.78)`.
- Text styles: `ff(size,w,color,height,ls)` = Sora (body); `fd(...)` = Fraunces
  (display/headings, weights 700-900); `mono(...)` = DM Mono (numbers/times).
  Defaults exist; pass what you need. `w` is FontWeight, `ls` letterSpacing.
- For CSS `rgba(r,g,b,a)` use `Color(0xFFRRGGBB).withOpacity(a)` or `Colors.white.withOpacity(a)`.

### widgets/common.dart
- `Press(child:, onTap:, scale: .97, dx: 0)` — tap wrapper w/ press-scale.
- `AppBarX(title:, sub:, back:'sYY'?, onBack:?, actions: [Widget])` — white top bar
  with back chevron + Fraunces title + optional subtitle + trailing actions.
  If you pass `back:'sYY'` it shows a back button — BUT it does not auto-navigate;
  prefer `onBack: () => go('sYY')`. (If only `back` is set, also set onBack.)
- `BackBtn(onTap:, dark: true, label:?)` — chevron-left; dark=false → white (on dark headers).
- `IbBtn(iconPathString, onTap:, iconSize:16)` — 34×34 rounded icon button (.ib).
- `Btn(label, kind: BtnKind.p, leading:?, trailing:?, onTap:, padding:?, fontSize:?, margin:8)`
  full-width button. `leading`/`trailing` are SVG inner strings (e.g. P.arrowRight).
  Kinds: p (purple grad), ok (green grad), s (outline), o (light outline small),
  er (red grad), gold (gold grad), white.
- `Chip2(text, kind: ChipKind.p, leading:?, fontSize:?)` — status chip.
  Kinds: p (purple t1/t7), g (green), a (amber/gold), e (red), i (blue).  ".chip cp"=p, cg=g, ca=a, ce=e, ci=i.
- `CardX(child:, padding: EdgeInsets.all(13), margin: 10, onTap:?, bg:?, border:?, radius:?)` — `.card`.
- `Sec(text, padding: fromLTRB(18,12,18,6))` — uppercase section label `.sec`.
- `Lbl(text)` — uppercase field label `.lbl`.
- `Inp(hint:?, value:?, leadingIcon:? (svg string), controller:?, mono_: false, margin: 9, onChanged:?, onSubmitted:?)` — `.inp` text field.
- `Toggle(on: bool, onChanged: (bool){})` — `.tog` switch (40×23).
- `TabPill(label, on: bool, onTap:)` — `.tab` pill.
- `BottomNav(active: 0|1|2|3)` — bottom nav (Home/Logs/Communities/Profile). It
  navigates via go(). Use on screens that show `.bnav` (e.g. S03).
- `Sc(List<Widget> children, padding:?, controller:?, cross: CrossAxisAlignment.stretch)`
  — Expanded, scrollable column with hidden scrollbar (`.sc`). Use inside a Column.
- `GBox(size:, gradient:?, color:?, radius: 11, child:, shadow:?, border:?)` — rounded box/avatar.

### widgets/header.dart
- `DarkHeader(child:, padding: fromLTRB(22,28,22,36), blobs: [Blob…], gradient:?)` —
  dark 155° gradient header band; `blobs` are decorative circles.
- `Blob(size, color, {top,left,right,bottom})` — positioned circle (use inside DarkHeader.blobs).

### widgets/svg.dart
- `Ico(innerSvgString, size: 18, stroke: Colors.white, fill:?, sw: 1.8, round: true)` —
  renders inline SVG. Pass the EXACT inner markup from the HTML icon (the part
  inside `<svg …>` … `</svg>`), e.g. `Ico('<circle cx="12" cy="12" r="10"/>', size:11, stroke:K.t6, sw:1.8)`.
  `fill` null → fill:none. Copy stroke color + stroke-width from the HTML svg attributes.
- `class P` has common path bodies: bell, search, arrowRight, arrowLeft, chevR,
  chevL, chevDown, check, x, plus, user, userNav, home, flower, venue, pin,
  calendar, clock, phone, file, qr, grid, directions, heart, bookmark, share,
  settings, sparkle. Use these instead of retyping when they match.

### app_state.dart
- `go('sXX')` — navigate to a screen (the prototype's `G()`). Use for every tap nav.
- `toast('msg')` — show a toast (the prototype's `T()`).
- `gmaps(venue, address)` — opens maps (shows toast on web).

## Conventions
- Font size: CSS `.62rem` → `rem(.62)`. Icon px sizes: copy the `width:` from the
  HTML svg style (e.g. `width:13px` → `size: 13`).
- Spacing: copy px paddings/margins/gaps directly (CSS px == logical px here; phone
  renders at 390 logical width).
- Gaps in a Row/Column → `SizedBox(width/height: n)` between children or use spacing.
- `border-radius` px → `BorderRadius.circular(n)`.
- Linear gradients: `135deg` → begin topLeft / end bottomRight; `155deg` →
  begin Alignment(-0.7,-1) end Alignment(0.7,1) (matches K.gHeader); vertical
  `160deg`/`180deg` → topCenter→bottomCenter approx.
- For `onclick="G('sXX')"` → `go('sXX')`. For `onclick="T('…')"` → `toast('…')`.
  For functions that just mutate UI (toggles/tabs/steps), implement with setState.
- Reproduce text EXACTLY including emoji and `·` separators (use the real char ·).
- Keep code clean and self-contained; no external packages beyond those imported.

## Reference
See `lib/screens/s01_splash.dart` and `lib/screens/s02_login.dart` for the exact
style/patterns to follow.
