import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app_state.dart';
import 'session.dart';
import 'data_store.dart';
import 'auth_service.dart';
import 'notif_service.dart';
import 'widgets/shell.dart';
import 'widgets/common.dart';
import 'screens/registry.dart';

/// Screens that are full-bleed (centered content over a dark gradient). These
/// fill the whole device (edge to edge, under the status/gesture bars).
const _fullBleed = {'s01', 's08', 's30', 's32'};

/// Onboarding screens that should NOT show the global bottom nav.
const _noNav = {'s01', 's02', 's08', 's30', 's32'};

/// Show the persistent bottom nav on every screen except onboarding/success.
bool _showNav(String id) => !_noNav.contains(id);

/// Which nav tab is highlighted for the current screen (-1 = none).
int _navIndex(String id) {
  switch (id) {
    case 's03':
      return 0; // Home
    case 's39':
      return 1; // Logs
    case 's09':
      return 2; // Communities
    case 's20':
      return 3; // Profile
    default:
      return -1;
  }
}

// Runs in a separate isolate when a push arrives with the app backgrounded or
// killed. Notification-payload messages are drawn by the OS automatically; this
// only surfaces data-only messages so nothing is silently dropped.
@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  await NotifService.showFromRemote(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  navTo = go; // wire bottom-nav to the global router
  try {
    await Firebase.initializeApp();
  } catch (_) {/* keep app usable if Firebase init fails (e.g. offline/web) */}
  FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);
  await NotifService.init(); // device notifications + FCM
  await Session.I.load();
  await AppData.I.load();
  AppData.I.startProgramsStream(); // live host-published programmes
  AppData.I.startCommunitiesStream(); // live host community profiles
  // Always open on the flash splash (s01). It shows on every launch, then
  // routes to Home (signed in) or the Get Started screen (logged out) itself.
  if (AuthService.isSignedIn) {
    AppData.I.bindUser(AuthService.uid!); // pull cloud data early (non-blocking)
  }
  // Optional deep-link: load a specific screen via URL fragment (e.g. /#s12).
  final frag = Uri.base.fragment.replaceAll('/', '');
  if (RegExp(r'^s\d{2}$').hasMatch(frag)) AppController.I.current = frag;
  runApp(const InviteKarooApp());
}

class InviteKarooApp extends StatelessWidget {
  const InviteKarooApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invite Karoo',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const _Root(),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppController.I,
      builder: (context, _) {
        final id = AppController.I.current;
        final full = _fullBleed.contains(id);
        // The splash (s01) is full-bleed but sits on a light cream artwork, so
        // it needs dark bars like a normal screen.
        final lightBg = id == 's01';
        final darkFull = full && !lightBg;
        final screen = buildScreen(id);
        // Full-bleed dark screens → light status-bar icons; everything else
        // (normal screens + the cream splash) → dark icons on cream.
        final overlay = (darkFull ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: darkFull ? const Color(0xFF1A0E3D) : K.cream,
          systemNavigationBarIconBrightness: darkFull ? Brightness.light : Brightness.dark,
        );
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (AppController.I.onSystemBack()) SystemNavigator.pop();
          },
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: overlay,
            child: Scaffold(
            backgroundColor: darkFull ? const Color(0xFF1A0E3D) : K.cream,
            // Center on very wide canvases (desktop web) so it still reads as a
            // phone app; on an actual phone this is a no-op (fills the screen).
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOutCubic,
                        transitionBuilder: (child, anim) {
                          return FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(begin: const Offset(.045, 0), end: Offset.zero)
                                  .animate(anim),
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey('${AppController.I.seq}-$id'),
                          child: full
                              ? screen
                              : SafeArea(
                                  child: _showNav(id)
                                      ? Column(
                                          children: [
                                            Expanded(child: screen),
                                            BottomNav(active: _navIndex(id)),
                                          ],
                                        )
                                      : screen,
                                ),
                        ),
                      ),
                    ),
                    const ToastLayer(),
                  ],
                ),
              ),
            ),
          ),
          ),
        );
      },
    );
  }
}
