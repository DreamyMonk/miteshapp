import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme.dart';
import '../app_state.dart';
import '../session.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

const _bg = Color(0xFF0A0712);
const _cam =
    '<path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/>';

class S31 extends StatefulWidget {
  const S31({super.key});
  @override
  State<S31> createState() => _S31State();
}

enum _Perm { checking, granted, denied, permanentlyDenied }

class _S31State extends State<S31> {
  bool _handled = false;
  _Perm _perm = _Perm.checking;

  @override
  void initState() {
    super.initState();
    _ensurePermission();
  }

  Future<void> _ensurePermission() async {
    setState(() => _perm = _Perm.checking);
    var status = await Permission.camera.status;
    if (!status.isGranted) status = await Permission.camera.request();
    if (!mounted) return;
    setState(() {
      if (status.isGranted) {
        _perm = _Perm.granted;
      } else if (status.isPermanentlyDenied || status.isRestricted) {
        _perm = _Perm.permanentlyDenied;
      } else {
        _perm = _Perm.denied;
      }
    });
  }

  void _onScan(Code code) {
    if (_handled) return;
    final text = code.text;
    if (code.isValid != true || text == null || text.isEmpty) return;
    _handled = true;
    Session.I.lastScan = text;
    AppData.I.checkInFromScan(text);
    toast('QR detected');
    Future.delayed(const Duration(milliseconds: 300), () => go('s32'));
  }

  void _manual() {
    if (_handled) return;
    _handled = true;
    Session.I.lastScan = 'MANUAL-CHECKIN';
    AppData.I.checkInFromScan('MANUAL-CHECKIN');
    go('s32');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  BackBtn(onTap: () => go('s03'), dark: false),
                  Expanded(
                    child: Column(
                      children: [
                        Text('Scan Event QR', style: fd(size: rem(1), w: FontWeight.w700, color: Colors.white)),
                        Text('Point at the hall QR code',
                            style: ff(size: rem(.58), color: Colors.white.withOpacity(.45))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 34),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
                child: Column(
                  children: [
                    // Large preview → captures the QR at higher resolution so
                    // ZXing can actually decode it.
                    Expanded(child: _viewport()),
                    const SizedBox(height: 16),
                    if (_perm == _Perm.granted)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Ico(P.qr, size: 15, stroke: K.g3, sw: 1.8),
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text('Point your camera at the hall QR code',
                                style: ff(size: rem(.78), color: Colors.white.withOpacity(.7))),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Btn('Mark Attendance', kind: BtnKind.gold, leading: P.check, onTap: _manual),
                  Press(
                    onTap: () => toast('Enter event code manually'),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text('Enter code manually instead',
                          style: ff(size: rem(.68), w: FontWeight.w600, color: Colors.white.withOpacity(.45))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _viewport() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF161020), Color(0xFF241634)],
        ),
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_perm == _Perm.granted)
              // ZXing (C++) scanner — no Google ML Kit / Play Services needed,
              // so it works even where the ML-Kit-based scanner crashed.
              ReaderWidget(
                onScan: _onScan,
                codeFormat: Format.qrCode,
                tryHarder: true,
                tryInverted: true,
                showScannerOverlay: false,
                showFlashlight: true,
                showToggleCamera: false,
                showGallery: false,
                allowPinchZoom: true,
                scanDelay: const Duration(milliseconds: 250),
                cropPercent: 1.0, // scan the whole frame (don't miss the QR)
                resolution: ResolutionPreset.high,
                actionButtonsAlignment: Alignment.bottomRight,
                actionButtonsBackgroundColor: Colors.black54,
                flashOnIcon: const Icon(Icons.flash_on, size: 18),
                flashOffIcon: const Icon(Icons.flash_off, size: 18),
                loading: const DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xFF161020)),
                  child: Center(
                    child: SizedBox(width: 26, height: 26, child: CircularProgressIndicator(color: K.g3, strokeWidth: 2.5)),
                  ),
                ),
              )
            else
              _permissionState(),
            if (_perm == _Perm.granted) ...[
              _corner(top: 12, left: 12, tl: true),
              _corner(top: 12, right: 12, tr: true),
              _corner(bottom: 12, left: 12, bl: true),
              _corner(bottom: 12, right: 12, br: true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _permissionState() {
    if (_perm == _Perm.checking) {
      return const Center(
        child: SizedBox(width: 26, height: 26, child: CircularProgressIndicator(color: K.g3, strokeWidth: 2.5)),
      );
    }
    final permanent = _perm == _Perm.permanentlyDenied;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Ico(_cam, size: 30, stroke: Colors.white.withOpacity(.55), sw: 1.6),
            const SizedBox(height: 10),
            Text(permanent ? 'Camera access is off' : 'Camera permission needed',
                textAlign: TextAlign.center,
                style: ff(size: rem(.72), w: FontWeight.w700, color: Colors.white.withOpacity(.85))),
            const SizedBox(height: 4),
            Text(
              permanent
                  ? 'Enable Camera for Invite Karoo in Settings to scan the QR.'
                  : 'Allow camera access to scan the hall QR code.',
              textAlign: TextAlign.center,
              style: ff(size: rem(.6), color: Colors.white.withOpacity(.5), height: 1.4),
            ),
            const SizedBox(height: 12),
            Press(
              onTap: permanent ? () => openAppSettings() : _ensurePermission,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: K.g3.withOpacity(.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: K.g3.withOpacity(.5)),
                ),
                child: Text(permanent ? 'Open Settings' : 'Allow Camera',
                    style: ff(size: rem(.68), w: FontWeight.w800, color: K.g3)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _corner({
    double? top,
    double? left,
    double? right,
    double? bottom,
    bool tl = false,
    bool tr = false,
    bool bl = false,
    bool br = false,
  }) {
    const w = 3.0;
    final side = BorderSide(color: K.g3, width: w);
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border(
            top: (tl || tr) ? side : BorderSide.none,
            bottom: (bl || br) ? side : BorderSide.none,
            left: (tl || bl) ? side : BorderSide.none,
            right: (tr || br) ? side : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: tl ? const Radius.circular(7) : Radius.zero,
            topRight: tr ? const Radius.circular(7) : Radius.zero,
            bottomLeft: bl ? const Radius.circular(7) : Radius.zero,
            bottomRight: br ? const Radius.circular(7) : Radius.zero,
          ),
        ),
      ),
    );
  }
}
