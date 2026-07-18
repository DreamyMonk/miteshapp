import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'data_store.dart';

/// Device notifications (local + scheduled reminders) + Firebase Cloud Messaging.
class NotifService {
  static final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();
  static int _id = 1000;
  static int _nextId() => _id++;
  static String? fcmToken;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'ik_default',
    'Invite Karoo',
    description: 'Event reminders and updates',
    importance: Importance.high,
  );

  static NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          'ik_default',
          'Invite Karoo',
          channelDescription: 'Event reminders and updates',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        // iOS: show the banner even while the app is foregrounded.
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  static Future<void> init() async {
    // Timezone (app is India-centric → schedule in IST).
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    } catch (_) {}

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // iOS: request notification permission + allow local/scheduled alerts.
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );
    try {
      await _fln.initialize(initSettings);
      await _fln
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
      await _fln
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (_) {}

    // Wire the store hooks so in-app events pop device notifications + schedule.
    AppData.onLocalNotify = (title, body) => showNow(title, body);
    AppData.onEventAdded = (e) => scheduleEventReminders(e);
    // Follow/unfollow a community's push topic when the user subscribes/leaves.
    AppData.onCommunityTopic = (cid, on) => setCommunityTopic(cid, on);

    await _initFcm();
    // Subscribe to the topics for communities the user already follows.
    AppData.I.syncCommunityTopics();
  }

  static Future<void> _initFcm() async {
    try {
      final fm = FirebaseMessaging.instance;
      await fm.requestPermission(alert: true, badge: true, sound: true);
      fcmToken = await fm.getToken();
      if (kDebugMode) debugPrint('FCM token: $fcmToken');
      // Legacy: older builds subscribed every install to a global 'programs'
      // topic. Clean that up — host pushes are now scoped per community topic so
      // a user only gets notifications from communities they subscribed to.
      await fm.unsubscribeFromTopic('programs');
      // Universal channel: every install gets platform-wide announcements the
      // admin panel broadcasts (app updates, greetings). Host pushes never use
      // this topic.
      await fm.subscribeToTopic('all_users');

      // Foreground push → show a device notification + add to the in-app center.
      FirebaseMessaging.onMessage.listen((RemoteMessage m) {
        final n = m.notification;
        final title = n?.title ?? m.data['title'] ?? 'Invite Karoo';
        final body = n?.body ?? m.data['body'] ?? '';
        showNow(title, body);
        AppData.I.addNotification(title, body, 'push', popDevice: false);
      });
    } catch (_) {}
  }

  static String _topicOf(String cid) => 'community_$cid';

  /// Follow/unfollow one community's push topic (called when the user
  /// subscribes/unsubscribes that community).
  static Future<void> setCommunityTopic(String cid, bool on) async {
    if (cid.isEmpty) return;
    try {
      final fm = FirebaseMessaging.instance;
      if (on) {
        await fm.subscribeToTopic(_topicOf(cid));
      } else {
        await fm.unsubscribeFromTopic(_topicOf(cid));
      }
    } catch (_) {}
  }

  /// Master push toggle: (un)subscribe every followed community's topic.
  static Future<void> setPushEnabled(bool on) async {
    AppData.I.syncCommunityTopics(on);
  }

  static Future<void> showNow(String title, String body) async {
    try {
      await _fln.show(_nextId(), title, body, _details);
    } catch (_) {}
  }

  /// Background/terminated push handler. The OS already draws messages that
  /// carry a `notification` payload, so we only surface DATA-ONLY messages here
  /// (avoids showing a duplicate notification).
  static Future<void> showFromRemote(RemoteMessage m) async {
    if (m.notification != null) return; // OS shows notification-payload messages
    final title = '${m.data['title'] ?? ''}';
    final body = '${m.data['body'] ?? ''}';
    if (title.isEmpty && body.isEmpty) return;
    try {
      await _fln.initialize(const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ));
      await _fln
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    } catch (_) {}
    await showNow(title.isEmpty ? 'Invite Karoo' : title, body);
  }

  /// Schedule a one-off reminder at [when] (no-op if in the past).
  static Future<void> scheduleAt(String title, String body, DateTime when) async {
    if (when.isBefore(DateTime.now())) return;
    try {
      await _fln.zonedSchedule(
        _nextId(),
        title,
        body,
        tz.TZDateTime.from(when, tz.local),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {}
  }

  /// Schedule reminders for a newly-created event based on its reminder offsets.
  static void scheduleEventReminders(UserEvent e) {
    final base = _eventDateTime(e);
    if (base == null) return;
    final mins = <int>{};
    // Simple (non-wedding) events carry their reminder(s) at the top level;
    // weddings carry per-function reminders.
    for (final r in e.reminders) {
      final v = int.tryParse(r);
      if (v != null && v > 0) mins.add(v);
    }
    for (final f in e.functions) {
      for (final r in f.reminders) {
        final v = int.tryParse(r);
        if (v != null && v > 0) mins.add(v);
      }
    }
    if (mins.isEmpty) mins.addAll([60]); // default: 1 hour before
    for (final m in mins) {
      scheduleAt('Reminder: ${e.name}', 'Starts in ${_fmtMins(m)}', base.subtract(Duration(minutes: m)));
    }
  }

  /// Demo: fire one now + one in 5 seconds so the user can see it working.
  static Future<void> fireTest() async {
    await showNow('Test notification', 'Notifications are working on this device ✓');
    await scheduleAt('Scheduled reminder', 'This reminder was scheduled 5 seconds ago.',
        DateTime.now().add(const Duration(seconds: 5)));
  }

  // ─────────── Push diagnostics (Settings screen) ───────────
  // Base URL of the host dashboard that owns the FCM sender routes.
  static const String apiBase = 'https://host.invitekaroo.com';

  /// Re-fetch this device's FCM registration token. Returns null if FCM
  /// registration is failing (e.g. no Google Play Services / no network) — in
  /// which case no push (topic OR direct) can ever arrive on this device.
  static Future<String?> refreshToken() async {
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (_) {
      fcmToken = null;
    }
    return fcmToken;
  }

  /// Re-run every topic subscription (all_users + each followed community) and
  /// return the topics we (re)subscribed to, so the diagnostic can show exactly
  /// what this device is registered for. Surfaces silently-failed subscriptions.
  static Future<List<String>> resubscribeAll() async {
    final topics = <String>[];
    try {
      final fm = FirebaseMessaging.instance;
      await fm.subscribeToTopic('all_users');
      topics.add('all_users');
      for (final name in AppData.I.subscriptions) {
        final cid = AppData.I.cidForName(name);
        if (cid != null && cid.isNotEmpty) {
          await fm.subscribeToTopic('community_$cid');
          topics.add('community_$cid');
        }
      }
    } catch (_) {}
    return topics;
  }

  /// Ask the server to push straight to THIS device's token — bypassing topics
  /// entirely. If this arrives, FCM delivery works and the problem is topic
  /// subscription; if it doesn't, FCM reception on this device is broken.
  static Future<String> sendTestPushToThisDevice() async {
    final token = fcmToken ?? await refreshToken();
    if (token == null || token.isEmpty) {
      return 'No FCM token — FCM registration is failing on this device (Play Services / network). No push can arrive.';
    }
    try {
      final r = await http.post(
        Uri.parse('$apiBase/api/test-push'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'title': 'Direct test push ✓',
          'body': 'If you see this, FCM delivery to this device works.',
        }),
      );
      Map<String, dynamic> j = {};
      try {
        j = jsonDecode(r.body) as Map<String, dynamic>;
      } catch (_) {}
      if (r.statusCode == 200 && j['ok'] == true) {
        return 'Sent ✓ — watch for the notification now.';
      }
      return 'Server error ${r.statusCode}: ${j['error'] ?? r.body}';
    } catch (e) {
      return 'Request failed: $e';
    }
  }

  static DateTime? _eventDateTime(UserEvent e) {
    // Parse the event's real date (YYYY-MM-DD), fall back to legacy May-2026 day.
    final dm = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(e.dateIso);
    final int y = dm != null ? int.parse(dm.group(1)!) : 2026;
    final int mo = dm != null ? int.parse(dm.group(2)!) : 5;
    final int d = dm != null ? int.parse(dm.group(3)!) : e.day;
    if (d <= 0) return null;
    if (e.time.isEmpty || e.time.toLowerCase() == 'all day') return DateTime(y, mo, d, 9, 0);
    final m = RegExp(r'(\d+):(\d+)\s*(AM|PM)?', caseSensitive: false).firstMatch(e.time);
    if (m == null) return DateTime(y, mo, d, 9, 0);
    var h = int.parse(m.group(1)!);
    final mm = int.parse(m.group(2)!);
    final ap = (m.group(3) ?? '').toUpperCase();
    if (ap == 'PM' && h != 12) h += 12;
    if (ap == 'AM' && h == 12) h = 0;
    return DateTime(y, mo, d, h, mm);
  }

  static String _fmtMins(int m) {
    if (m < 60) return '$m min';
    if (m < 1440) return '${m ~/ 60} hour${m >= 120 ? 's' : ''}';
    if (m < 10080) return '${m ~/ 1440} day${m >= 2880 ? 's' : ''}';
    return '${m ~/ 10080} week${m >= 20160 ? 's' : ''}';
  }
}
