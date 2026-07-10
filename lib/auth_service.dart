import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Wraps Firebase Phone Authentication (real SMS OTP).
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? _verificationId;
  static int? _resendToken;
  static String? _debugCode;

  // ── TEST / BYPASS login (no SMS) ────────────────────────────────────────
  // For testing when real SMS OTP isn't configured. The app generates the code
  // itself, writes it to Firestore `otpDebug` so the admin panel can show it,
  // and signs in anonymously so the app has a real uid (cloud + host features
  // work). NOT for production — gate/remove before shipping.

  /// Generate a code (no SMS), publish it to `otpDebug` for the admin panel,
  /// and sign in anonymously for a uid. Returns the code (also shown in admin).
  static Future<String?> sendDebugCode(String phoneRaw) async {
    final phone = normalize(phoneRaw);
    final code = (1000 + Random().nextInt(9000)).toString(); // 4-digit
    _debugCode = code;
    try {
      if (_auth.currentUser == null) await _auth.signInAnonymously();
    } catch (_) {/* Anonymous provider not enabled → falls back to local session */}
    try {
      await FirebaseFirestore.instance.collection('otpDebug').doc(phone).set({
        'number': phone,
        'code': code,
        'at': FieldValue.serverTimestamp(),
        'used': false,
      });
    } catch (_) {}
    return code;
  }

  /// Verify the entered code against the app-generated one. Returns a uid
  /// (anonymous, if available) or a local sentinel on match; null otherwise.
  static Future<String?> verifyDebugCode(String smsCode, String phoneRaw) async {
    if (_debugCode == null) return null;
    if (smsCode.trim() != _debugCode!.trim()) return null;
    _debugCode = null;
    try {
      await FirebaseFirestore.instance
          .collection('otpDebug')
          .doc(normalize(phoneRaw))
          .set({'used': true, 'usedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    } catch (_) {}
    return _auth.currentUser?.uid ?? 'test-user';
  }

  /// Hidden test path: sign in anonymously (no SMS). Temporary — remove before
  /// production. Returns the anonymous uid (or a local sentinel if the Anonymous
  /// provider isn't enabled).
  static Future<String?> signInAnonymously() async {
    try {
      if (_auth.currentUser == null) await _auth.signInAnonymously();
      return _auth.currentUser?.uid ?? 'test-user';
    } catch (_) {
      return 'test-user';
    }
  }

  /// Sign in with a Firebase custom token (minted by the WhatsApp-OTP verify
  /// server route). Returns the uid.
  static Future<String?> signInWithCustomToken(String token) async {
    final res = await _auth.signInWithCustomToken(token);
    return res.user?.uid;
  }

  static User? get user => _auth.currentUser;
  static bool get isSignedIn => _auth.currentUser != null;
  static String? get uid => _auth.currentUser?.uid;

  /// Normalize to E.164 (default country code +91 if none provided).
  static String normalize(String raw) {
    var s = raw.replaceAll(RegExp(r'[^\d+]'), '');
    if (s.startsWith('+')) return s;
    if (s.length == 10) return '+91$s';
    if (s.startsWith('91') && s.length == 12) return '+$s';
    return '+$s';
  }

  /// Step 1 — send the SMS code.
  static Future<void> sendCode(
    String phoneRaw, {
    required void Function() onCodeSent,
    required void Function(String message) onError,
    void Function()? onAutoVerified,
  }) async {
    final phone = normalize(phoneRaw);
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendToken,
      verificationCompleted: (PhoneAuthCredential cred) async {
        // Android auto-retrieval / instant validation.
        try {
          await _auth.signInWithCredential(cred);
          onAutoVerified?.call();
        } catch (_) {}
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Verification failed (${e.code})');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        onCodeSent();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  /// Step 2 — verify the entered code; returns the signed-in uid or null.
  static Future<String?> verifyCode(String smsCode) async {
    if (_verificationId == null) return null;
    final cred = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );
    final res = await _auth.signInWithCredential(cred);
    return res.user?.uid;
  }

  static Future<void> signOut() async {
    _verificationId = null;
    _resendToken = null;
    await _auth.signOut();
  }
}
