import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

const _arrowLeft =
    '<line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/>';
const _camera =
    '<path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/>';
const _upload =
    '<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/>';
const _sparkle =
    '<path d="M12 3l1.9 5.8a2 2 0 0 0 1.3 1.3L21 12l-5.8 1.9a2 2 0 0 0-1.3 1.3L12 21l-1.9-5.8a2 2 0 0 0-1.3-1.3L3 12l5.8-1.9a2 2 0 0 0 1.3-1.3z"/>';
const _pencil =
    '<path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>';

// The AI-scan backend (Mistral OCR) lives on the host dashboard's Vercel app.
// Set this to your host-dashboard domain if different.
const String _ocrEndpoint = 'https://host.invitekaroo.com/api/ocr';

const Map<String, String> _typeLabels = {
  'wedding': 'Wedding',
  'meeting': 'Meeting',
  'birthday': 'Birthday',
  'appointment': 'Appointment',
  'travel': 'Travel',
  'other': 'Other',
};

/// AI Scan — snap/upload an invitation card, OCR it with Mistral, and pre-fill
/// the manual form with the extracted event details.
class S38 extends StatefulWidget {
  const S38({super.key});
  @override
  State<S38> createState() => _S38State();
}

const List<String> _scanTips = [
  'Tip: Hold the card flat and fill the frame.',
  'Tip: Good lighting gives the best reads.',
  'Tip: Avoid glare and shadows on the card.',
  'Tip: Keep the text sharp and in focus.',
  'Tip: You can edit every detail after scanning.',
  'Tip: Works for weddings, appointments, travel & more.',
  'Tip: Crop out clutter around the invitation.',
  'Tip: A clear photo scans faster than a screenshot.',
];

class _S38State extends State<S38> {
  bool _busy = false;
  String _status = '';
  static int _tipCounter = 0; // rotates the tip on each scan
  String _tip = _scanTips.first;

  Future<void> _scan(ImageSource source) async {
    if (_busy) return;
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (file == null) return;
      setState(() {
        _busy = true;
        _status = 'Reading your invitation…';
        _tip = _scanTips[_tipCounter++ % _scanTips.length];
      });
      final bytes = await file.readAsBytes();
      final dataUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      final res = await http
          .post(
            Uri.parse(_ocrEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'image': dataUrl}),
          )
          .timeout(const Duration(seconds: 45));

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200 || body['ok'] != true) {
        throw Exception('${body['error'] ?? 'Scan failed (${res.statusCode})'}');
      }
      final fields = (body['fields'] as Map?)?.cast<String, dynamic>() ?? {};
      _openPrefilled(fields);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _status = '';
      });
      toast('Couldn’t scan: ${_short(e)}');
    }
  }

  String _short(Object e) {
    var s = e.toString().replaceFirst('Exception: ', '');
    if (s.length > 80) s = '${s.substring(0, 80)}…';
    return s;
  }

  void _openPrefilled(Map<String, dynamic> f) {
    String s(String k) => '${f[k] ?? ''}'.trim();
    final t = s('type').toLowerCase();
    final isWed = t == 'wedding';
    final label = _typeLabels[t] ?? 'Other';
    final title = s('title');

    // Wedding functions (Haldi/Sangeet/…) if the card listed them.
    final fnList = <UserFn>[];
    final rawFns = f['functions'];
    if (rawFns is List) {
      for (final rf in rawFns) {
        if (rf is Map) {
          final m = rf.cast<String, dynamic>();
          final nm = '${m['name'] ?? ''}'.trim();
          if (nm.isEmpty) continue;
          fnList.add(UserFn(
            name: nm,
            dateLabel: '${m['date'] ?? ''}'.trim(), // ISO; the form parses it back
            time: '${m['time'] ?? ''}'.trim(),
            reminders: const ['60'],
          ));
        }
      }
    }

    AppData.I.editingEvent = UserEvent(
      id: '', // empty → the form treats this as a new add, just pre-filled
      name: title.isEmpty ? 'Scanned event' : title,
      type: label,
      dateIso: s('date'),
      day: 0,
      time: s('time'),
      loc: s('venue'),
      host: s('host'),
      bride: s('bride'),
      groom: s('groom'),
      family: s('family'),
      source: 'ai',
      isWedding: isWed,
      reminders: const ['60'],
      functions: fnList,
    );
    if (mounted) setState(() => _busy = false);
    toast('Scanned — review the details');
    go('s37');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: K.t9,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                color: Colors.black.withOpacity(.4),
                child: Row(
                  children: [
                    Press(
                      dx: -3,
                      onTap: () => go('s36'),
                      child: Ico(_arrowLeft, size: 18, stroke: Colors.white, sw: 2),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Scan', style: fd(size: rem(1.05), w: FontWeight.w700, color: Colors.white)),
                          Text('Upload an invitation card or photo',
                              style: ff(size: rem(.58), color: Colors.white.withOpacity(.6))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Sc(
                padding: const EdgeInsets.all(18),
                [
                  // Hero
                  Container(
                    margin: const EdgeInsets.only(bottom: 13),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(.22), width: 2),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [K.t7, K.t5]),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(child: Ico(_camera, size: 32, stroke: Colors.white, sw: 1.8)),
                            ),
                            Positioned(
                              right: -6,
                              top: -6,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  gradient: K.gGold,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: K.t9, width: 2),
                                ),
                                child: Center(child: Ico(_sparkle, size: 12, stroke: Colors.white, sw: 2)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text('Scan Invitation Card',
                            style: fd(size: rem(1.05), w: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 260,
                          child: Text(
                              'Snap or upload an event invite and we\'ll auto-fill the name, date, time & venue for you to review.',
                              textAlign: TextAlign.center,
                              style: ff(
                                  size: rem(.62),
                                  w: FontWeight.w500,
                                  color: Colors.white.withOpacity(.7),
                                  height: 1.6)),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _captureBtn(_camera, 'Camera', () => _scan(ImageSource.camera)),
                            const SizedBox(width: 8),
                            _captureBtn(_upload, 'Upload', () => _scan(ImageSource.gallery)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Manual alternative
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.06),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: Colors.white.withOpacity(.12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Prefer to type it?',
                            style: ff(size: rem(.7), w: FontWeight.w700, color: Colors.white)),
                        const SizedBox(height: 3),
                        Text('Add your event by hand — it only takes a minute.',
                            style: ff(size: rem(.6), color: Colors.white.withOpacity(.6), height: 1.5)),
                        const SizedBox(height: 11),
                        Press(
                          scale: .98,
                          onTap: () => go('s37'),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(gradient: K.gGold, borderRadius: BorderRadius.circular(11)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Ico(_pencil, size: 14, stroke: Colors.white, sw: 2),
                                const SizedBox(width: 7),
                                Text('Add Event Manually',
                                    style: ff(size: rem(.74), w: FontWeight.w800, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Loading overlay while OCR runs.
        if (_busy)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(.72),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                        width: 34, height: 34, child: CircularProgressIndicator(color: K.g3, strokeWidth: 3)),
                    const SizedBox(height: 16),
                    Text(_status.isEmpty ? 'Working…' : _status,
                        style: ff(size: rem(.76), w: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 240,
                      child: Text(_tip,
                          textAlign: TextAlign.center,
                          style: ff(size: rem(.6), color: Colors.white.withOpacity(.6), height: 1.5)),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _captureBtn(String icon, String label, VoidCallback onTap) {
    return Press(
      scale: .97,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: label == 'Camera' ? K.gGold : null,
          color: label == 'Camera' ? null : Colors.white.withOpacity(.12),
          borderRadius: BorderRadius.circular(11),
          border: label == 'Camera' ? null : Border.all(color: Colors.white.withOpacity(.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Ico(icon, size: 14, stroke: Colors.white, sw: 2.2),
            const SizedBox(width: 6),
            Text(label, style: ff(size: rem(.72), w: FontWeight.w800, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
