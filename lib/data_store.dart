import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'session.dart';

/// One function of a multi-day (wedding) event.
class UserFn {
  String name, dateLabel, time, notes, loc, colorHex;
  List<String> reminders;
  UserFn({
    required this.name,
    required this.dateLabel,
    required this.time,
    this.notes = '',
    this.loc = '',
    this.colorHex = '#7C5CBF',
    this.reminders = const [],
  });
  Map<String, dynamic> toJson() => {
        'name': name,
        'dateLabel': dateLabel,
        'time': time,
        'notes': notes,
        'loc': loc,
        'colorHex': colorHex,
        'reminders': reminders,
      };
  factory UserFn.fromJson(Map<String, dynamic> j) => UserFn(
        name: j['name'] ?? '',
        dateLabel: j['dateLabel'] ?? '',
        time: j['time'] ?? '',
        notes: j['notes'] ?? '',
        loc: j['loc'] ?? '',
        colorHex: j['colorHex'] ?? '#7C5CBF',
        reminders: (j['reminders'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      );
}

/// A user-created event (manual or AI scan). Persisted across launches.
class UserEvent {
  String id;
  String name;
  String type; // Wedding / Appointment / Meeting / Birthday / ...
  String dateIso; // full date 'YYYY-MM-DD' (production: any real date)
  int day; // legacy day-of-month (derived from dateIso); kept for callers
  String time; // '10:00 AM' or 'All Day'
  String loc;
  String colorHex; // '#A21CAF'
  String icon; // svg inner markup
  String source; // manual | ai
  String createdAt; // ISO8601
  bool isWedding;
  String bride, groom, family, host;
  String wedStart, wedEnd, wedNextFn, wedNextTime;
  List<UserFn> functions;
  List<String> reminders; // reminder offsets in minutes, for simple (non-wedding) events

  UserEvent({
    required this.id,
    required this.name,
    required this.type,
    this.dateIso = '',
    required this.day,
    required this.time,
    this.loc = '',
    this.colorHex = '#7C5CBF',
    this.icon = '<rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>',
    this.source = 'manual',
    this.createdAt = '',
    this.isWedding = false,
    this.bride = '',
    this.groom = '',
    this.family = '',
    this.host = '',
    this.wedStart = '',
    this.wedEnd = '',
    this.wedNextFn = '',
    this.wedNextTime = '',
    this.functions = const [],
    this.reminders = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'dateIso': dateIso,
        'day': day,
        'time': time,
        'loc': loc,
        'colorHex': colorHex,
        'icon': icon,
        'source': source,
        'createdAt': createdAt,
        'isWedding': isWedding,
        'bride': bride,
        'groom': groom,
        'family': family,
        'host': host,
        'wedStart': wedStart,
        'wedEnd': wedEnd,
        'wedNextFn': wedNextFn,
        'wedNextTime': wedNextTime,
        'functions': functions.map((f) => f.toJson()).toList(),
        'reminders': reminders,
      };

  factory UserEvent.fromJson(Map<String, dynamic> j) => UserEvent(
        id: j['id'] ?? '',
        name: j['name'] ?? '',
        type: j['type'] ?? 'Event',
        dateIso: j['dateIso'] ?? '',
        day: j['day'] ?? 0,
        time: j['time'] ?? '',
        loc: j['loc'] ?? '',
        colorHex: j['colorHex'] ?? '#7C5CBF',
        icon: j['icon'] ?? '',
        source: j['source'] ?? 'manual',
        createdAt: j['createdAt'] ?? '',
        isWedding: j['isWedding'] ?? false,
        bride: j['bride'] ?? '',
        groom: j['groom'] ?? '',
        family: j['family'] ?? '',
        host: j['host'] ?? '',
        wedStart: j['wedStart'] ?? '',
        wedEnd: j['wedEnd'] ?? '',
        wedNextFn: j['wedNextFn'] ?? '',
        wedNextTime: j['wedNextTime'] ?? '',
        functions: (j['functions'] as List?)?.map((e) => UserFn.fromJson(Map<String, dynamic>.from(e))).toList() ?? [],
        reminders: (j['reminders'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      );
}

class AttendanceRec {
  final String event, venue, dateLabel, code, time, dateIso;
  AttendanceRec(
      {required this.event,
      required this.venue,
      required this.dateLabel,
      required this.code,
      this.time = '',
      this.dateIso = ''});
  Map<String, dynamic> toJson() =>
      {'event': event, 'venue': venue, 'dateLabel': dateLabel, 'code': code, 'time': time, 'dateIso': dateIso};
  factory AttendanceRec.fromJson(Map<String, dynamic> j) => AttendanceRec(
        event: j['event'] ?? '',
        venue: j['venue'] ?? '',
        dateLabel: j['dateLabel'] ?? '',
        code: j['code'] ?? '',
        time: j['time'] ?? '',
        dateIso: j['dateIso'] ?? '',
      );
}

/// An in-app notification (notification center + bell badge).
class AppNotification {
  final String id, title, body, type, iso;
  bool read;
  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.iso,
    this.read = false,
  });
  Map<String, dynamic> toJson() =>
      {'id': id, 'title': title, 'body': body, 'type': type, 'iso': iso, 'read': read};
  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'] ?? '',
        title: j['title'] ?? '',
        body: j['body'] ?? '',
        type: j['type'] ?? 'system',
        iso: j['iso'] ?? '',
        read: j['read'] ?? false,
      );
}

/// Central reactive, persisted app data store. Single source of truth for the
/// things the user can change at runtime.
class AppData extends ChangeNotifier {
  AppData._();
  static final AppData I = AppData._();

  final List<UserEvent> events = []; // user-created events (manual + ai)
  final Map<String, String?> rsvp = {}; // 'day-idx' -> going|not_going|null
  final Set<String> subscriptions = {}; // community names the user subscribed to
  final Set<String> saved = {}; // saved programme names
  final List<AttendanceRec> checkIns = []; // new attendance from QR/manual
  final List<AppNotification> notifications = []; // in-app notification center
  // Persisted user preferences (settings screen + per-programme reminder prefs).
  final Map<String, bool> settings = {'push': true, 'reminders': true, 'autoCal': true};
  final Map<String, Map<String, dynamic>> reminderPrefs = {}; // progId -> {push,whats,email,muted}

  // Programmes published by hosts via the Next.js dashboard (live from Firestore).
  final List<Map<String, dynamic>> livePrograms = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _progSub;
  final Set<String> _seenProgramIds = {};
  bool _progInitialLoad = true;

  /// Listen to host-published programmes (public collection). Safe to call once.
  void startProgramsStream() {
    try {
      _progSub?.cancel();
      _progSub = FirebaseFirestore.instance
          .collection('programs')
          .where('published', isEqualTo: true)
          .snapshots()
          .listen((snap) {
        livePrograms
          ..clear()
          ..addAll(snap.docs.map((d) => {...d.data(), 'id': d.id}));
        // sort by date then time (string sort is fine for ISO dates)
        livePrograms.sort((a, b) => '${a['date']} ${a['time']}'.compareTo('${b['date']} ${b['time']}'));
        // Notify once per newly-published programme (skip the initial batch on
        // cold start to avoid a flood). Pops a device notification + adds to
        // the in-app notification center.
        final fresh = <Map<String, dynamic>>[];
        for (final p in livePrograms) {
          final id = '${p['id']}';
          if (_seenProgramIds.add(id) && !_progInitialLoad) fresh.add(p);
        }
        if (_progInitialLoad) {
          _progInitialLoad = false;
        } else {
          var added = false;
          for (final p in fresh) {
            final community = '${p['communityName'] ?? ''}';
            // Only record programmes from communities the user follows, and do
            // NOT pop a device notification — the FCM push already does that
            // (popping here caused a duplicate "Invite Karoo" notification).
            if (!isSubscribed(community)) continue;
            final venue = '${p['venue'] ?? ''}';
            final when = '${_fmtProgDate('${p['date'] ?? ''}')} · ${p['time'] ?? ''}';
            addNotification(
              'New programme: ${p['title'] ?? 'Programme'}',
              [if (community.isNotEmpty) community, when, if (venue.isNotEmpty) venue].join(' · '),
              'community',
              popDevice: false,
            );
            added = true;
          }
          if (added) _persist();
        }
        notifyListeners();
      }, onError: (_) {});
    } catch (_) {}
  }

  static String _fmtProgDate(String iso) {
    const mon = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(iso);
    if (m == null) return iso;
    return '${int.parse(m.group(3)!)} ${mon[(int.parse(m.group(2)!) - 1).clamp(0, 11)]}';
  }

  List<Map<String, dynamic>> liveProgramsForDay(int day) =>
      livePrograms.where((p) => _dayOfIso('${p['date']}') == day).toList();

  // ── Community profiles published by hosts (Firestore `communities`) ──
  final List<Map<String, dynamic>> liveCommunities = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _commSub;

  void startCommunitiesStream() {
    try {
      _commSub?.cancel();
      _commSub = FirebaseFirestore.instance.collection('communities').snapshots().listen((snap) {
        liveCommunities
          ..clear()
          ..addAll(snap.docs.map((d) => {...d.data(), 'id': d.id}));
        syncCommunityTopics(); // now that cids are known, follow subscribed topics
        notifyListeners();
      }, onError: (_) {});
    } catch (_) {}
  }

  /// Navigation context: the programme/community the user last tapped
  /// (consumed by the detail screens).
  Map<String, dynamic>? selectedProgram;
  Map<String, dynamic>? selectedCommunity;
  UserEvent? editingEvent; // set before opening s37 to edit an existing event
  AppNotification? selectedNotification; // the notification opened in s17

  Map<String, dynamic>? communityByName(String name) {
    for (final c in liveCommunities) {
      if ('${c['name']}'.toLowerCase() == name.toLowerCase()) return c;
    }
    return null;
  }

  List<Map<String, dynamic>> programsOfCommunity(String name) =>
      livePrograms.where((p) => '${p['communityName']}'.toLowerCase() == name.toLowerCase()).toList();

  // ── Real calendar (production): today is the device date, not a frozen day ──
  static DateTime get todayDate {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static String _2(int v) => v.toString().padLeft(2, '0');
  static String isoOf(DateTime d) => '${d.year}-${_2(d.month)}-${_2(d.day)}';
  static String get todayIso => isoOf(todayDate);

  /// Host programmes on a specific real date ('YYYY-MM-DD').
  List<Map<String, dynamic>> liveProgramsForIso(String iso) =>
      livePrograms.where((p) => '${p['date']}' == iso).toList();

  /// User-created events on a specific real date.
  List<UserEvent> eventsForIso(String iso) =>
      events.where((e) => (e.dateIso.isNotEmpty ? e.dateIso : _isoFromLegacy(e)) == iso).toList();

  // Back-compat: older events stored only `day` (May 2026). Derive an ISO.
  static String _isoFromLegacy(UserEvent e) => e.day > 0 ? '2026-05-${_2(e.day)}' : '';

  // Legacy helper (day-of-month) retained where callers still use it.
  static int _dayOfIso(String iso) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(iso);
    return m == null ? 0 : int.parse(m.group(3)!);
  }

  int _seq = 0;
  String _newId() => 'ue${DateTime.now().microsecondsSinceEpoch}_${_seq++}';

  // Hooks set by NotifService (avoids an import cycle): pop a device
  // notification, and schedule reminders when an event is created.
  static void Function(String title, String body)? onLocalNotify;
  static void Function(UserEvent e)? onEventAdded;
  // (Un)subscribe the FCM topic for a community so a user only receives push
  // notifications from communities they've actually subscribed to.
  static void Function(String cid, bool on)? onCommunityTopic;

  /// Re-subscribe the FCM topics for every community the user follows. Safe to
  /// call repeatedly (FCM topic subscription is idempotent). Needs
  /// liveCommunities populated to resolve names → community ids.
  void syncCommunityTopics([bool on = true]) {
    final cb = onCommunityTopic;
    if (cb == null) return;
    for (final name in subscriptions) {
      final cid = _cidByName(name);
      if (cid != null) cb(cid, on);
    }
  }

  int get unreadCount => notifications.where((n) => !n.read).length;

  /// Internal: append a notification + pop a device notification. Caller persists.
  void _pushNote(String title, String body, String type) {
    notifications.insert(0,
        AppNotification(id: _newId(), title: title, body: body, type: type, iso: DateTime.now().toIso8601String()));
    if (notifications.length > 60) notifications.removeRange(60, notifications.length);
    onLocalNotify?.call(title, body);
  }

  /// Public: add a notification (used by FCM push + the test action).
  AppNotification addNotification(String title, String body, String type, {bool popDevice = true}) {
    // De-dupe: the FCM foreground handler and the Firestore stream can both try
    // to record the same push — skip if an identical one arrived seconds ago.
    if (notifications.isNotEmpty) {
      final last = notifications.first;
      final recent = DateTime.now()
              .difference(DateTime.tryParse(last.iso) ?? DateTime(2000))
              .inSeconds <
          20;
      if (recent && last.title == title && last.body == body) {
        if (popDevice) onLocalNotify?.call(title, body);
        return last;
      }
    }
    notifications.insert(0,
        AppNotification(id: _newId(), title: title, body: body, type: type, iso: DateTime.now().toIso8601String()));
    if (notifications.length > 60) notifications.removeRange(60, notifications.length);
    if (popDevice) onLocalNotify?.call(title, body);
    _persist();
    notifyListeners();
    return notifications.first;
  }

  void markRead(String id) {
    for (final n in notifications) {
      if (n.id == id) n.read = true;
    }
    _persist();
    notifyListeners();
  }

  void markAllRead() {
    if (notifications.every((n) => n.read)) return;
    for (final n in notifications) {
      n.read = true;
    }
    _persist();
    notifyListeners();
  }

  // Firestore binding — when a user is signed in, data also syncs to the cloud
  // under users/{uid}, so it follows the account across devices.
  String? uid;

  static const _kLastUid = 'ad_last_uid';

  Future<void> bindUser(String userId) async {
    // If a DIFFERENT account signs in (incl. after reinstall where a backup may
    // have restored the old user's prefs), wipe the previous user's local data
    // so it never leaks/seeds into the new account.
    try {
      final p = await SharedPreferences.getInstance();
      final last = p.getString(_kLastUid);
      if (last != null && last != userId) {
        _clearUserData();
      }
      await p.setString(_kLastUid, userId);
    } catch (_) {}
    uid = userId;
    await _pullFromCloud();
  }

  /// Wipe all per-user local state (used on account switch / logout).
  void _clearUserData() {
    syncCommunityTopics(false); // unsubscribe the old account's community topics
    subscriptions.clear();
    saved.clear();
    events.clear();
    notifications.clear();
    checkIns.clear();
    reminderPrefs.clear();
    rsvp.clear();
    _seenProgramIds.clear();
    _progInitialLoad = true;
    _persist();
    notifyListeners();
  }

  /// Public reset for logout.
  Future<void> clearForLogout() async {
    _clearUserData();
    uid = null;
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove(_kLastUid);
    } catch (_) {}
  }

  void unbindUser() {
    uid = null;
  }

  DocumentReference<Map<String, dynamic>>? get _doc =>
      uid == null ? null : FirebaseFirestore.instance.collection('users').doc(uid);

  Map<String, dynamic> _toCloudMap() => {
        'events': events.map((e) => e.toJson()).toList(),
        'rsvp': rsvp,
        'subs': subscriptions.toList(),
        'saved': saved.toList(),
        'checkIns': checkIns.map((e) => e.toJson()).toList(),
        'notifs': notifications.map((e) => e.toJson()).toList(),
        'profile': {
          'name': Session.I.fullName,
          'family': Session.I.familyName,
          'mobile': Session.I.mobile,
          'city': Session.I.city,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Future<void> _pushToCloud() async {
    final d = _doc;
    if (d == null) return;
    try {
      await d.set(_toCloudMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  /// Push the current Session profile (name/mobile/city) to the user's cloud
  /// doc. Called after the user edits their profile so it follows the account.
  Future<void> syncProfileToCloud() async {
    await _pushToCloud();
    notifyListeners();
  }

  Future<void> _pullFromCloud() async {
    final d = _doc;
    if (d == null) return;
    try {
      final snap = await d.get();
      if (!snap.exists || snap.data() == null) {
        // First sign-in on this account → seed the cloud with current local data.
        await _pushToCloud();
        return;
      }
      final m = snap.data()!;
      if (m['events'] is List) {
        events
          ..clear()
          ..addAll((m['events'] as List).map((e) => UserEvent.fromJson(Map<String, dynamic>.from(e))));
      }
      if (m['rsvp'] is Map) {
        rsvp.clear();
        (m['rsvp'] as Map).forEach((k, v) => rsvp['$k'] = v as String?);
      }
      if (m['subs'] is List) {
        subscriptions
          ..clear()
          ..addAll((m['subs'] as List).map((e) => e.toString()));
      }
      if (m['saved'] is List) {
        saved
          ..clear()
          ..addAll((m['saved'] as List).map((e) => e.toString()));
      }
      if (m['checkIns'] is List) {
        checkIns
          ..clear()
          ..addAll((m['checkIns'] as List).map((e) => AttendanceRec.fromJson(Map<String, dynamic>.from(e))));
      }
      if (m['notifs'] is List) {
        notifications
          ..clear()
          ..addAll((m['notifs'] as List).map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e))));
      }
      if (m['profile'] is Map) {
        final p = Map<String, dynamic>.from(m['profile']);
        if ((p['name'] ?? '').toString().isNotEmpty) {
          await Session.I.signIn(
            name: p['name'] ?? Session.I.fullName,
            family: p['family'] ?? Session.I.familyName,
            mobile: p['mobile'] ?? Session.I.mobile,
            city: p['city'] ?? Session.I.city,
          );
        }
      }
      await _saveLocal();
      notifyListeners();
    } catch (_) {}
  }

  // ---- queries ----
  List<UserEvent> eventsForDay(int day) => events.where((e) => e.day == day).toList();

  bool isSubscribed(String name) => subscriptions.contains(name);
  bool isSaved(String name) => saved.contains(name);

  // ---- mutations ----
  UserEvent addEvent(UserEvent e) {
    if (e.id.isEmpty) e.id = _newId();
    if (e.createdAt.isEmpty) e.createdAt = DateTime.now().toIso8601String();
    events.add(e);
    _pushNote('Event added', '${e.name} added to your calendar', 'event');
    if (settings['reminders'] ?? true) onEventAdded?.call(e); // schedule reminders (gated by setting)
    _persist();
    notifyListeners();
    return e;
  }

  void removeEvent(String id) {
    events.removeWhere((e) => e.id == id);
    _persist();
    notifyListeners();
  }

  /// Update an existing event in place (used by the edit flow). Falls back to
  /// adding it if the id isn't found.
  void updateEvent(UserEvent e) {
    final i = events.indexWhere((x) => x.id == e.id);
    if (i < 0 || e.id.isEmpty) {
      addEvent(e);
      return;
    }
    events[i] = e;
    if (settings['reminders'] ?? true) onEventAdded?.call(e); // reschedule reminders
    _persist();
    notifyListeners();
  }

  void setRsvp(String key, String? status) {
    rsvp[key] = status;
    if (status == 'going') _pushNote('RSVP confirmed', "You're going — added to your plans", 'rsvp');
    _persist();
    notifyListeners();
  }

  // Read a stored RSVP for a live programme (going|not_going|null).
  String? programRsvp(Map<String, dynamic> program) => rsvp['prog_${program['id']}'];

  // RSVP to a host-published programme. Saves locally + to the user's cloud doc,
  // AND writes a record into communities/{cid}/rsvps so the host dashboard's
  // RSVP view shows real guests + head-count.
  Future<void> rsvpToProgram(Map<String, dynamic> program,
      {required bool going, int guests = 1}) async {
    final pid = '${program['id']}';
    rsvp['prog_$pid'] = going ? 'going' : 'not_going';
    if (going) {
      _pushNote('RSVP confirmed',
          "You're going to ${program['title'] ?? 'the programme'} — added to your plans", 'rsvp');
    }
    _persist();
    notifyListeners();

    final u = uid;
    String cid = '${program['communityId'] ?? ''}';
    if (cid.isEmpty) {
      cid = liveCommunities.isNotEmpty ? '${liveCommunities.first['id']}' : '';
    }
    if (u == null || cid.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(cid)
          .collection('rsvps')
          .doc('${u}_$pid')
          .set({
        'name': Session.I.displayName,
        'mobile': Session.I.mobile,
        'programme': program['title'] ?? '',
        'programId': pid,
        'guests': going ? guests : 0,
        'status': going ? 'going' : 'not_going',
        'at': _dayLabel(),
        'uid': u,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  void toggleSubscription(String name) {
    if (!subscriptions.remove(name)) subscriptions.add(name);
    _persist();
    notifyListeners();
  }

  void setSubscribed(String name, bool on) {
    if (on) {
      subscriptions.add(name);
      _pushNote('Subscribed', "You'll get updates from $name", 'community');
    } else {
      subscriptions.remove(name);
    }
    _writeSubscriber(name, on); // reflect into the host dashboard
    final cid = _cidByName(name);
    if (cid != null) onCommunityTopic?.call(cid, on); // (un)follow push topic
    _persist();
    notifyListeners();
  }

  String? _cidByName(String name) {
    for (final c in liveCommunities) {
      if ('${c['name']}'.toLowerCase() == name.toLowerCase()) return '${c['id']}';
    }
    return null;
  }

  static String _dayLabel() {
    final n = DateTime.now();
    const mon = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${n.day} ${mon[n.month - 1]} ${n.year}';
  }

  // Write a subscriber record into communities/{cid}/subscribers so the host
  // dashboard's Subscribers view reflects real subscribers.
  Future<void> _writeSubscriber(String name, bool on) async {
    final u = uid;
    final cid = _cidByName(name);
    if (u == null || cid == null) return;
    try {
      final ref =
          FirebaseFirestore.instance.collection('communities').doc(cid).collection('subscribers').doc(u);
      if (on) {
        await ref.set({
          'name': Session.I.displayName,
          'mobile': Session.I.mobile,
          'since': _dayLabel(),
          'uid': u,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await ref.delete();
      }
    } catch (_) {}
  }

  void toggleSaved(String name) {
    if (!saved.remove(name)) saved.add(name);
    _persist();
    notifyListeners();
  }

  void addCheckIn(AttendanceRec r) {
    checkIns.insert(0, r);
    _pushNote('Attendance recorded', '${r.event} · ${r.venue}', 'attendance');
    _writeAttendance(r); // reflect into the host dashboard
    _persist();
    notifyListeners();
  }

  static String _time12(DateTime n) {
    final h = n.hour % 12 == 0 ? 12 : n.hour % 12;
    final ap = n.hour < 12 ? 'AM' : 'PM';
    return '$h:${_2(n.minute)} $ap';
  }

  /// Build + record an attendance check-in from a scanned QR value (or a manual
  /// entry). The event/venue are derived from the real programme the code maps
  /// to — matched by programme id embedded in the QR, else today's live/next
  /// programme — with the real date + time. No hardcoded event names.
  AttendanceRec checkInFromScan(String code) {
    final now = DateTime.now();
    Map<String, dynamic>? prog = _programForScan(code);
    final rec = AttendanceRec(
      event: prog != null ? '${prog['title'] ?? 'Event Check-in'}' : 'Event Check-in',
      venue: prog != null
          ? [
              if ('${prog['venue'] ?? ''}'.isNotEmpty) '${prog['venue']}',
              if ('${prog['area'] ?? ''}'.isNotEmpty) '${prog['area']}',
            ].join(', ')
          : '',
      dateLabel: _dayLabel(),
      code: code,
      time: _time12(now),
      dateIso: isoOf(now),
    );
    addCheckIn(rec);
    return rec;
  }

  // Resolve which live programme a scanned code belongs to.
  Map<String, dynamic>? _programForScan(String code) {
    final c = code.trim();
    if (c.isNotEmpty) {
      // 1) exact / embedded programme id (QR payloads often carry the doc id)
      for (final p in livePrograms) {
        final id = '${p['id']}';
        if (id.isNotEmpty && (c == id || c.contains(id))) return p;
      }
    }
    // 2) a programme scheduled live today
    final todays = liveProgramsForIso(todayIso);
    if (todays.isNotEmpty) return todays.first;
    // 3) the next upcoming programme, else nothing
    final upcoming = livePrograms.where((p) => '${p['date']}'.compareTo(todayIso) >= 0).toList();
    if (upcoming.isNotEmpty) return upcoming.first;
    return null;
  }

  // Write attendance into communities/{cid}/attendance for the dashboard.
  Future<void> _writeAttendance(AttendanceRec r) async {
    final u = uid;
    if (u == null) return;
    String? cid;
    for (final p in livePrograms) {
      if ('${p['title']}'.toLowerCase() == r.event.toLowerCase()) {
        cid = '${p['communityId']}';
        break;
      }
    }
    cid ??= liveCommunities.isNotEmpty ? '${liveCommunities.first['id']}' : null;
    if (cid == null || cid.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('communities').doc(cid).collection('attendance').add({
        'name': Session.I.displayName,
        'programme': r.event,
        'venue': r.venue,
        'at': _dayLabel(),
        'code': r.code,
        'uid': u,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  void toggleSubscriptionNotified(String name) => setSubscribed(name, !subscriptions.contains(name));

  // ---- settings / reminder preferences (persisted) ----
  static const _kSettings = 'ad_settings';
  static const _kRemPrefs = 'ad_remprefs';

  Future<void> setSetting(String key, bool val) async {
    settings[key] = val;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kSettings, jsonEncode(settings));
    } catch (_) {}
    notifyListeners();
  }

  Map<String, dynamic> reminderPrefFor(String progId) =>
      reminderPrefs[progId] ?? {'push': true, 'whats': false, 'email': false, 'muted': false};

  Future<void> setReminderPref(String progId, Map<String, dynamic> pref) async {
    reminderPrefs[progId] = pref;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kRemPrefs, jsonEncode(reminderPrefs));
    } catch (_) {}
    notifyListeners();
  }

  // Submit a host application into the top-level `hostApplications` collection.
  // Reviewed by the platform admin panel. Returns the new doc id (or null).
  Future<String?> submitHostApplication(Map<String, dynamic> fields,
      {required String track}) async {
    _pushNote('Application submitted',
        'Our team reviews host applications in 24–48 hrs.', 'system');
    try {
      final ref = await FirebaseFirestore.instance.collection('hostApplications').add({
        ...fields,
        'track': track,
        'status': 'pending',
        'applicantUid': uid ?? '',
        'applicantName': Session.I.displayName,
        'applicantMobile': Session.I.mobile,
        'submittedAt': _dayLabel(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (_) {
      return null;
    }
  }

  // ---- persistence ----
  static const _kEvents = 'ad_events';
  static const _kRsvp = 'ad_rsvp';
  static const _kSubs = 'ad_subs';
  static const _kSaved = 'ad_saved';
  static const _kCheck = 'ad_checkins';
  static const _kNotifs = 'ad_notifs';

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final ev = p.getString(_kEvents);
      if (ev != null) {
        events
          ..clear()
          ..addAll((jsonDecode(ev) as List).map((e) => UserEvent.fromJson(Map<String, dynamic>.from(e))));
      }
      final rs = p.getString(_kRsvp);
      if (rs != null) {
        rsvp.clear();
        (jsonDecode(rs) as Map).forEach((k, v) => rsvp[k] = v as String?);
      }
      final subs = p.getStringList(_kSubs);
      if (subs != null) {
        subscriptions
          ..clear()
          ..addAll(subs);
      }
      final sv = p.getStringList(_kSaved);
      if (sv != null) {
        saved
          ..clear()
          ..addAll(sv);
      }
      final ci = p.getString(_kCheck);
      if (ci != null) {
        checkIns
          ..clear()
          ..addAll((jsonDecode(ci) as List).map((e) => AttendanceRec.fromJson(Map<String, dynamic>.from(e))));
      }
      final st = p.getString(_kSettings);
      if (st != null) {
        (jsonDecode(st) as Map).forEach((k, v) => settings['$k'] = v == true);
      }
      final rp = p.getString(_kRemPrefs);
      if (rp != null) {
        (jsonDecode(rp) as Map).forEach((k, v) => reminderPrefs['$k'] = Map<String, dynamic>.from(v));
      }
      final nt = p.getString(_kNotifs);
      if (nt != null) {
        notifications
          ..clear()
          ..addAll((jsonDecode(nt) as List).map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e))));
      }
    } catch (_) {}
  }

  Future<void> _persist() async {
    await _saveLocal();
    _pushToCloud(); // fire-and-forget cloud sync
  }

  Future<void> _saveLocal() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kEvents, jsonEncode(events.map((e) => e.toJson()).toList()));
      await p.setString(_kRsvp, jsonEncode(rsvp));
      await p.setStringList(_kSubs, subscriptions.toList());
      await p.setStringList(_kSaved, saved.toList());
      await p.setString(_kCheck, jsonEncode(checkIns.map((e) => e.toJson()).toList()));
      await p.setString(_kNotifs, jsonEncode(notifications.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }
}
