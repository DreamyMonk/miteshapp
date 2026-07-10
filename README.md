# Invite Karoo — Flutter app

A faithful Flutter port of the **"Invite Karoo"** prototype (`INVITE KAROO VERSION 01 FINAL.html`)
— a community-events phone app: discover venues/communities, subscribe,
view programmes, manage your calendar, QR attendance, add events (manual + AI scan),
and more. All **39 screens** (S01–S39) with their navigation and interactivity.

## Run it

Flutter SDK used: `C:\Users\saptr\OneDrive\Desktop\flutter_windows_3.44.0-stable`

```powershell
$env:Path += ";C:\Users\saptr\OneDrive\Desktop\flutter_windows_3.44.0-stable\bin"
cd C:\Users\saptr\Videos\invitekaroo

# Run in Chrome (debug, hot reload):
flutter run -d chrome

# Or build an optimized web bundle and serve it:
flutter build web --release
dart tool/serve.dart 8090      # then open http://127.0.0.1:8090
```

Also runs on Windows desktop (`flutter run -d windows`) and Android/iOS
(`flutter run` with a device) — one codebase, all platforms.

> Tip: enable Windows **Developer Mode** if `flutter run -d windows` complains
> about symlinks. Web does not need it.

## How it's built

- `lib/main.dart` — app root; phone frame + animated screen switcher + toast layer.
- `lib/theme.dart` — exact color tokens, gradients, and Sora/Fraunces/DM Mono
  type scale (via `google_fonts`). `rem(x)` converts CSS rem to px.
- `lib/app_state.dart` — `go('sNN')` router and `toast()` (ports the prototype's `G()` / `T()`).
- `lib/widgets/` — reusable components (`Btn`, `Chip2`, `CardX`, `Toggle`, `TabPill`,
  `BottomNav`, `AppBarX`, `Inp`, `DarkHeader`, `Ico` for inline SVG icons, the phone shell, …).
- `lib/screens/s01_*.dart … s39_*.dart` — one file per screen; `registry.dart` maps ids → widgets.

### Navigation
The app starts at the Splash screen and you navigate by tapping in-app (exactly
like the prototype). For testing, you can deep-link to any screen via the URL
fragment, e.g. `http://127.0.0.1:8090/#s12`.

`AGENT_SPEC.md` documents the widget API (kept for reference).
