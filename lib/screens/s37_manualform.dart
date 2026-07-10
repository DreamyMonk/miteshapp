import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../data_store.dart';
import '../widgets/common.dart';
import '../widgets/svg.dart';

const _heart =
    '<path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"/>';
const _meeting =
    '<path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/><rect x="8" y="2" width="8" height="4" rx="1"/>';
const _bday = '<path d="M20 21v-8H4v8M2 21h20M9 13V8a3 3 0 0 1 6 0v5"/>';
const _appt = '<circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>';
const _travel =
    '<path d="M17.8 19.2 16 11l3.5-3.5C21 6 21.5 4 21 3c-1-.5-3 0-4.5 1.5L13 8 4.8 6.2c-.5-.1-.9.1-1.1.5l-.3.5c-.2.5-.1 1 .3 1.3L9 12l-2 3H4l-1 1 3 2 2 3 1-1v-3l3-2 3.5 5.3c.3.4.8.5 1.3.3l.5-.2c.4-.3.6-.7.5-1.2z"/>';
const _other =
    '<rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/>';
const _couple =
    '<circle cx="9" cy="7" r="4"/><path d="M3 21v-2a4 4 0 0 1 4-4h4a4 4 0 0 1 4 4v2"/><circle cx="17" cy="11" r="3"/>';
const _phone =
    '<path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/>';
const _bell = '<path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>';
const _bellFull =
    '<path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/>';
const _plus = '<line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>';
const _x = '<line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>';
const _trash =
    '<polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>';
const _pin =
    '<path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/>';
const _note =
    '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="8" y1="13" x2="16" y2="13"/><line x1="8" y1="17" x2="16" y2="17"/>';
const _check = '<polyline points="20 6 9 17 4 12"/>';
const _calIcon =
    '<rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>';
const _clockIcon = '<circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>';

const _pink = Color(0xFFA21CAF);
const _pinkLight = Color(0xFFE879F9);
const _pinkBorder = Color(0xFFF0ABFC);
const _pinkBg = Color(0xFFFAE8FF);

const _fnColors = [
  Color(0xFFF5A623),
  Color(0xFF7C5CBF),
  Color(0xFF16A34A),
  Color(0xFFA21CAF),
  Color(0xFF1D4ED8),
  Color(0xFFDC2626),
  Color(0xFF0F766E),
];

// Event type chip definitions (verbatim from HTML).
class _TypeDef {
  final String key, label, icon;
  final List<Color>? grad;
  final Color? shadow;
  const _TypeDef(this.key, this.label, this.icon, {this.grad, this.shadow});
}

const _types = [
  _TypeDef('wedding', 'Wedding', _heart, grad: [_pink, _pinkLight], shadow: Color(0x40A21CAF)),
  _TypeDef('meeting', 'Meeting', _meeting, grad: [Color(0xFF1E3A8A), Color(0xFF1D4ED8)], shadow: Color(0x401D4ED8)),
  _TypeDef('birthday', 'Birthday', _bday, grad: [Color(0xFF7C2D12), Color(0xFFD97706)], shadow: Color(0x40D97706)),
  _TypeDef('appointment', 'Appointment', _appt, grad: [Color(0xFF166534), K.ok], shadow: Color(0x4016A34A)),
  _TypeDef('travel', 'Travel', _travel, grad: [Color(0xFF0F766E), Color(0xFF14B8A6)], shadow: Color(0x4014B8A6)),
  _TypeDef('other', 'Other', _other, grad: [K.t6, K.t5], shadow: Color(0x407C5CBF)),
];

const Map<String, String> _placeholders = {
  'wedding': 'e.g. Amarjit & Manisha Wedding',
  'meeting': 'e.g. Q3 Pitch with Mitesh',
  'birthday': 'e.g. Priya 30th Birthday',
  'appointment': 'e.g. Dental Check-up',
  'travel': 'e.g. Goa Trip',
  'other': 'e.g. Anniversary Dinner',
};

const _reminderOptions = [
  ('0', 'None'),
  ('15', '15 min before'),
  ('30', '30 min before'),
  ('60', '1 hour before'),
  ('120', '2 hours before'),
  ('1440', '1 day before'),
  ('2880', '2 days before'),
  ('10080', '1 week before'),
];

const _genericReminderOptions = [
  ('0', 'None'),
  ('15', '15 min before'),
  ('60', '1 hour before'),
  ('1440', '1 day before'),
  ('10080', '1 week before'),
];

// type key -> (label, icon svg, colorHex)
final Map<String, (String, String, String)> _typeMeta = {
  'wedding': ('Wedding', _heart, '#A21CAF'),
  'meeting': ('Meeting', _meeting, '#1D4ED8'),
  'birthday': ('Birthday', _bday, '#D97706'),
  'appointment': ('Appointment', _appt, '#16A34A'),
  'travel': ('Travel', _travel, '#14B8A6'),
  'other': ('Other', _other, '#7C5CBF'),
};

int _dayOf(String iso) {
  final p = iso.split('-');
  if (p.length < 3) return 0;
  final y = int.tryParse(p[0]) ?? 0;
  final m = int.tryParse(p[1]) ?? 0;
  final d = int.tryParse(p[2]) ?? 0;
  return (y == 2026 && m == 5) ? d : 0;
}

String _dayMon(String iso) {
  const mon = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final p = iso.split('-');
  if (p.length < 3) return iso;
  final m = int.tryParse(p[1]) ?? 1;
  final d = int.tryParse(p[2]) ?? 1;
  return '$d ${mon[(m - 1).clamp(0, 11)]}';
}

String _to12h(String t) {
  final p = t.split(':');
  if (p.length < 2) return t;
  var h = int.tryParse(p[0]) ?? 0;
  final m = p[1].padLeft(2, '0');
  final ap = h >= 12 ? 'PM' : 'AM';
  h = h % 12;
  if (h == 0) h = 12;
  return '$h:$m $ap';
}

// '9:00 AM' / '19:00' → '19:00' (24h) for the time field when editing.
String _to24h(String t) {
  final m = RegExp(r'(\d+):(\d+)\s*(AM|PM)?', caseSensitive: false).firstMatch(t);
  if (m == null) return '19:00';
  var h = int.parse(m.group(1)!);
  final mn = m.group(2)!.padLeft(2, '0');
  final ap = (m.group(3) ?? '').toUpperCase();
  if (ap == 'PM' && h != 12) h += 12;
  if (ap == 'AM' && h == 12) h = 0;
  return '${h.toString().padLeft(2, '0')}:$mn';
}

String _fnHex(int i) {
  const hex = ['#F5A623', '#7C5CBF', '#16A34A', '#A21CAF', '#1D4ED8', '#DC2626', '#0F766E'];
  return hex[i % hex.length];
}

class _Function {
  String n, date, time, notes, loc;
  List<String> reminders;
  _Function({this.n = '', this.date = '', this.time = '19:00', this.notes = '', this.loc = '', List<String>? reminders})
      : reminders = reminders ?? ['60'];
}

class S37 extends StatefulWidget {
  const S37({super.key});
  @override
  State<S37> createState() => _S37State();
}

class _S37State extends State<S37> {
  String _type = 'wedding';
  final List<_Function> _functions = [];
  final _name = TextEditingController();
  final _start = TextEditingController(text: AppData.todayIso);
  final _end = TextEditingController(text: AppData.todayIso);
  final _time = TextEditingController(text: '19:00');
  final _loc = TextEditingController();
  final _bride = TextEditingController();
  final _groom = TextEditingController();
  final _family = TextEditingController();
  final _host = TextEditingController();
  String _genericReminder = '15';
  String? _editId; // non-null when editing an existing event

  @override
  void initState() {
    super.initState();
    final e = AppData.I.editingEvent;
    AppData.I.editingEvent = null; // consume so a later fresh add starts blank
    if (e != null) {
      _editId = e.id.isEmpty ? null : e.id; // empty id = OCR prefill → treat as new add
      _loadFrom(e);
    } else {
      // Fresh add: type 'wedding' with one empty function.
      _functions.clear();
      _setEventType('wedding');
    }
  }

  // Pre-fill the form from an existing event (edit flow).
  void _loadFrom(UserEvent e) {
    String key = 'other';
    if (e.isWedding) {
      key = 'wedding';
    } else {
      _typeMeta.forEach((k, v) {
        if (v.$1.toLowerCase() == e.type.toLowerCase()) key = k;
      });
    }
    _type = key;
    _name.text = e.name;
    if (e.isWedding) {
      _bride.text = e.bride;
      _groom.text = e.groom;
      _family.text = e.family;
      _host.text = e.host;
      _start.text = e.dateIso.isNotEmpty ? e.dateIso : AppData.todayIso;
      _end.text = e.dateIso.isNotEmpty ? e.dateIso : AppData.todayIso;
      _functions.clear();
      for (final f in e.functions) {
        // AI-scanned functions carry a real ISO date in dateLabel; normal saved
        // ones carry a display label ('6 Jul') → fall back to today for those.
        final fnDate = DateTime.tryParse(f.dateLabel) != null ? f.dateLabel : AppData.todayIso;
        _functions.add(_Function(
          n: f.name,
          date: fnDate,
          time: f.time.isNotEmpty ? _to24h(f.time) : '11:00',
          notes: f.notes,
          loc: f.loc,
          reminders: f.reminders.isNotEmpty ? List<String>.from(f.reminders) : ['60'],
        ));
      }
      if (_functions.isEmpty) _functions.add(_Function(date: AppData.todayIso, time: '11:00'));
    } else {
      _start.text = e.dateIso.isNotEmpty ? e.dateIso : AppData.todayIso;
      _time.text = e.time.isNotEmpty ? _to24h(e.time) : '19:00';
      _loc.text = e.loc;
      _genericReminder = e.reminders.isNotEmpty ? e.reminders.first : '15';
    }
  }

  void _persistEvent(UserEvent ev) {
    if (_editId != null) {
      AppData.I.updateEvent(ev);
    } else {
      AppData.I.addEvent(ev);
    }
  }

  Future<DateTime?> _pickDate(String current) {
    final init = DateTime.tryParse(current) ?? DateTime.now();
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
  }

  Future<TimeOfDay?> _pickTime(String current, {int defHour = 19}) {
    final p = current.split(':');
    final init = TimeOfDay(
      hour: p.isNotEmpty ? (int.tryParse(p[0]) ?? defHour) : defHour,
      minute: p.length > 1 ? (int.tryParse(p[1]) ?? 0) : 0,
    );
    return showTimePicker(context: context, initialTime: init);
  }

  String _hhmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // A guaranteed-tappable selector styled like an input, with a trailing icon.
  Widget _pickerBox({
    required String text,
    required String placeholder,
    required String icon,
    required VoidCallback onTap,
    double margin = 9,
  }) {
    final empty = text.isEmpty;
    return Container(
      margin: EdgeInsets.only(bottom: margin),
      child: Press(
        scale: .99,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: K.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: K.bd2, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(empty ? placeholder : text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ff(size: rem(.81), color: empty ? K.ink4 : K.ink)),
              ),
              const SizedBox(width: 8),
              Ico(icon, size: 15, stroke: K.t6, sw: 1.9),
            ],
          ),
        ),
      ),
    );
  }

  // Tappable date field → date picker (stores ISO 'YYYY-MM-DD').
  Widget _dateField(TextEditingController ctl, {double margin = 9}) {
    return _pickerBox(
      text: ctl.text,
      placeholder: 'Select date',
      icon: _calIcon,
      margin: margin,
      onTap: () async {
        final d = await _pickDate(ctl.text);
        if (d != null) setState(() => ctl.text = AppData.isoOf(d));
      },
    );
  }

  // Tappable time field → time picker (stores 24h 'HH:MM').
  Widget _timeField(TextEditingController ctl, {double margin = 9}) {
    return _pickerBox(
      text: ctl.text,
      placeholder: 'Select time',
      icon: _clockIcon,
      margin: margin,
      onTap: () async {
        final t = await _pickTime(ctl.text);
        if (t != null) setState(() => ctl.text = _hhmm(t));
      },
    );
  }

  // Wedding-function date/time pickers (update the function).
  Widget _fnDatePicker(_Function f) {
    return _pickerBox(
      text: f.date,
      placeholder: 'Date',
      icon: _calIcon,
      margin: 0,
      onTap: () async {
        final d = await _pickDate(f.date);
        if (d != null) setState(() => f.date = AppData.isoOf(d));
      },
    );
  }

  Widget _fnTimePicker(_Function f) {
    return _pickerBox(
      text: f.time,
      placeholder: 'Time',
      icon: _clockIcon,
      margin: 0,
      onTap: () async {
        final t = await _pickTime(f.time, defHour: 11);
        if (t != null) setState(() => f.time = _hhmm(t));
      },
    );
  }

  bool get _isWed => _type == 'wedding';

  void _setEventType(String type) {
    setState(() {
      _type = type;
      if (type == 'wedding' && _functions.isEmpty) {
        _functions.add(_Function(date: AppData.todayIso, time: '11:00'));
      }
    });
  }

  void _addFunction() => setState(() => _functions.add(_Function(date: AppData.todayIso)));
  void _removeFunction(int i) => setState(() => _functions.removeAt(i));

  void _addReminder(int i) {
    if (_functions[i].reminders.length >= 3) {
      toast('Max 3 reminders per function');
      return;
    }
    setState(() => _functions[i].reminders.add('60'));
  }

  void _removeReminder(int f, int r) => setState(() => _functions[f].reminders.removeAt(r));
  void _updateReminder(int f, int r, String v) => setState(() => _functions[f].reminders[r] = v);

  void _save() {
    if (_name.text.trim().isEmpty) {
      toast('Please enter event name');
      return;
    }
    final meta = _typeMeta[_type] ?? _typeMeta['other']!;
    if (_isWed) {
      if (_functions.isEmpty) {
        toast('Add at least one function');
        return;
      }
      final valid = _functions.where((f) => f.n.trim().isNotEmpty).toList();
      if (valid.isEmpty) {
        toast('Function name required');
        return;
      }
      final fns = <UserFn>[];
      for (var i = 0; i < valid.length; i++) {
        final f = valid[i];
        fns.add(UserFn(
          name: f.n.trim(),
          dateLabel: _dayMon(f.date),
          time: _to12h(f.time),
          notes: f.notes,
          loc: f.loc,
          colorHex: _fnHex(i),
          reminders: List<String>.from(f.reminders),
        ));
      }
      final wDay = _dayOf(valid.first.date);
      _persistEvent(UserEvent(
        id: _editId ?? '',
        name: _name.text.trim(),
        type: 'Wedding',
        dateIso: (valid.first.date.isNotEmpty ? valid.first.date : _start.text).trim(),
        day: wDay != 0 ? wDay : _dayOf(_start.text),
        time: 'All Day',
        loc: _loc.text.trim().isNotEmpty ? _loc.text.trim() : valid.first.loc,
        colorHex: '#A21CAF',
        icon: _heart,
        source: 'manual',
        isWedding: true,
        bride: _bride.text.trim(),
        groom: _groom.text.trim(),
        family: _family.text.trim(),
        host: _host.text.trim(),
        wedStart: _dayMon(_start.text),
        wedEnd: _dayMon(_end.text),
        wedNextFn: fns.first.name,
        wedNextTime: '${fns.first.dateLabel}, ${fns.first.time}',
        functions: fns,
      ));
      toast(_editId != null ? 'Wedding updated' : 'Wedding saved with ${valid.length} functions');
    } else {
      _persistEvent(UserEvent(
        id: _editId ?? '',
        name: _name.text.trim(),
        type: meta.$1,
        dateIso: _start.text.trim(),
        day: _dayOf(_start.text),
        time: _to12h(_time.text),
        loc: _loc.text.trim(),
        colorHex: meta.$3,
        icon: meta.$2,
        source: 'manual',
        reminders: [_genericReminder],
      ));
      toast(_editId != null ? 'Event updated' : 'Event added to your calendar');
    }
    go(_editId != null ? 's39' : 's03');
  }

  @override
  void dispose() {
    _name.dispose();
    _start.dispose();
    _end.dispose();
    _time.dispose();
    _loc.dispose();
    _bride.dispose();
    _groom.dispose();
    _family.dispose();
    _host.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: K.cream,
      child: Column(
        children: [
          AppBarX(title: 'Add Event', sub: 'Fill details below', onBack: () => go('s36')),
          Sc(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            [
              _typeLabel('Event Type'),
              const SizedBox(height: 0),
              _typeGrid(),
              const SizedBox(height: 13),
              _typeLabel('Event Name'),
              Inp(controller: _name, hint: _placeholders[_type], margin: _isWed ? 0 : 12),
              if (_isWed) ...[
                const SizedBox(height: 6),
                Text('Tip: Enter the couple\'s name — e.g. "Amarjit & Manisha Wedding"',
                    style: ff(size: rem(.6), w: FontWeight.w600, color: K.ink2, height: 1.5)),
                const SizedBox(height: 12),
                _coupleCard(),
              ],
              // Date + Time row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _typeLabel('Start Date'),
                        _dateField(_start),
                      ],
                    ),
                  ),
                  if (!_isWed) ...[
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Lbl('Time'),
                          _timeField(_time),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              if (_isWed) ...[
                const Lbl('End Date  (multi-day)'),
                _dateField(_end),
              ],
              if (!_isWed) ...[
                const Lbl('Location'),
                Inp(controller: _loc, hint: 'e.g. Apollo Clinic / Office / Restaurant', margin: 9),
              ],
              if (_isWed) _fnsBuilder(),
              if (!_isWed) _genericReminderCard(),
              const SizedBox(height: 6),
              Btn('Save Event', kind: BtnKind.p, leading: _check, onTap: _save),
              const SizedBox(height: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: RichText(
        text: TextSpan(
          text: '${text.toUpperCase()} ',
          style: ff(size: rem(.58), w: FontWeight.w700, color: K.ink3, ls: .7),
          children: [TextSpan(text: '*', style: ff(size: rem(.58), w: FontWeight.w700, color: K.er))],
        ),
      ),
    );
  }

  Widget _typeGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 7,
      crossAxisSpacing: 7,
      childAspectRatio: 1.7,
      children: _types.map((t) {
        final on = t.key == _type;
        return Press(
          scale: .96,
          onTap: () => _setEventType(t.key),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
            decoration: BoxDecoration(
              gradient: on ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: t.grad!) : null,
              color: on ? null : K.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: on ? Colors.transparent : K.bd),
              boxShadow: on ? [BoxShadow(color: t.shadow!, blurRadius: 10, offset: const Offset(0, 3))] : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Ico(t.icon, size: 18, stroke: on ? Colors.white : K.ink, sw: 1.8),
                const SizedBox(height: 3),
                Text(t.label, style: ff(size: rem(.62), w: FontWeight.w800, color: on ? Colors.white : K.ink, ls: .1)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _coupleCard() {
    Widget field(String label, String hint, TextEditingController ctl) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(label.toUpperCase(),
                style: ff(size: rem(.5), w: FontWeight.w800, color: K.ink2, ls: .3)),
          ),
          Inp(controller: ctl, hint: hint, margin: 0),
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment(-0.7, -1), end: Alignment(0.7, 1), colors: [K.white, _pinkBg]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _pinkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_pink, _pinkLight]),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(child: Ico(_couple, size: 11, stroke: Colors.white, sw: 2.2, round: false)),
              ),
              const SizedBox(width: 6),
              Text('Couple & Family Details', style: fd(size: rem(.72), w: FontWeight.w800, color: _pink, ls: -.1)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: field('Bride Name', 'e.g. Manisha Das', _bride)),
              const SizedBox(width: 8),
              Expanded(child: field('Groom Name', 'e.g. Amarjit Singh', _groom)),
            ],
          ),
          const SizedBox(height: 8),
          field('Family Name', 'e.g. Das & Singh Families', _family),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    Ico(_phone, size: 10, stroke: K.ink2, sw: 2.2),
                    const SizedBox(width: 4),
                    Text('HOST CONTACT NUMBER',
                        style: ff(size: rem(.5), w: FontWeight.w800, color: K.ink2, ls: .3)),
                  ],
                ),
              ),
              Inp(controller: _host, hint: 'e.g. +91 98765 43210', mono_: true, margin: 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fnsBuilder() {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment(-0.7, -1), end: Alignment(0.7, 1), colors: [K.white, _pinkBg]),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _pinkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_pink, _pinkLight]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Ico(_heart, size: 14, stroke: Colors.white, sw: 2.2, round: false)),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Wedding Functions', style: fd(size: rem(.85), w: FontWeight.w800, color: _pink, ls: -.1)),
                    const SizedBox(height: 2),
                    Text("Add only the functions you're invited to",
                        style: ff(size: rem(.56), w: FontWeight.w700, color: K.ink3)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          for (var i = 0; i < _functions.length; i++) _fnCard(i),
          // Add Function CTA
          Press(
            scale: .98,
            onTap: _addFunction,
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.6),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: _pinkBorder, width: 1.5, style: BorderStyle.solid),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Ico(_plus, size: 13, stroke: _pink, sw: 2.4),
                  const SizedBox(width: 6),
                  Text('Add Function', style: ff(size: rem(.62), w: FontWeight.w800, color: _pink)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fnCard(int i) {
    final f = _functions[i];
    final c = _fnColors[i % _fnColors.length];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: K.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: c, width: 4)),
        boxShadow: K.sh,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: number + name + delete
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                child: Center(child: Text('${i + 1}', style: mono(size: rem(.72), w: FontWeight.w800, color: Colors.white))),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Inp(
                  controller: TextEditingController(text: f.n)..selection = TextSelection.collapsed(offset: f.n.length),
                  hint: 'Function name (e.g. Haldi)',
                  onChanged: (v) => f.n = v,
                  margin: 0,
                ),
              ),
              if (_functions.length > 1) ...[
                const SizedBox(width: 8),
                Press(
                  scale: .9,
                  onTap: () => _removeFunction(i),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(color: K.er1, borderRadius: BorderRadius.circular(7)),
                    child: Center(child: Ico(_trash, size: 13, stroke: K.er, sw: 2.4)),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 11),
          // Date + Time
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _fnSub('Date', _fnDatePicker(f))),
              const SizedBox(width: 8),
              Expanded(child: _fnSub('Time', _fnTimePicker(f))),
            ],
          ),
          const SizedBox(height: 8),
          // Location
          _fnSubIcon(_pin, 'Location',
              Inp(value: f.loc, hint: 'e.g. Banquet Hall / Family home / Hotel name', onChanged: (v) => f.loc = v, margin: 0)),
          const SizedBox(height: 10),
          // Reminders block
          _remindersBlock(i, f, c),
          const SizedBox(height: 9),
          // Notes
          _fnSubIcon(_note, 'Notes  (dress code, gift, etc.)', _notesField(f)),
        ],
      ),
    );
  }

  Widget _fnSub(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(label.toUpperCase(), style: ff(size: rem(.54), w: FontWeight.w800, color: K.ink2, ls: .4)),
        ),
        child,
      ],
    );
  }

  Widget _fnSubIcon(String icon, String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Ico(icon, size: 11, stroke: K.ink2, sw: 2.2),
              const SizedBox(width: 5),
              Text(label.toUpperCase(), style: ff(size: rem(.54), w: FontWeight.w800, color: K.ink2, ls: .4)),
            ],
          ),
        ),
        child,
      ],
    );
  }

  Widget _notesField(_Function f) {
    return TextField(
      controller: TextEditingController(text: f.notes)..selection = TextSelection.collapsed(offset: f.notes.length),
      onChanged: (v) => f.notes = v,
      maxLines: 2,
      minLines: 2,
      style: ff(size: rem(.7), w: FontWeight.w600, color: K.ink, height: 1.4),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Wear traditional / Gift: cash envelope / Reach 30 min early',
        hintStyle: ff(size: rem(.7), color: K.ink4),
        filled: true,
        fillColor: K.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: BorderSide(color: K.bd)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: BorderSide(color: K.bd)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: const BorderSide(color: K.t6)),
      ),
    );
  }

  Widget _remindersBlock(int i, _Function f, Color c) {
    final canAdd = f.reminders.length < 3;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(color: K.cream2, borderRadius: BorderRadius.circular(9)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Ico(_bell, size: 11, stroke: K.ink2, sw: 2.2),
              const SizedBox(width: 5),
              Text('REMINDERS ', style: ff(size: rem(.54), w: FontWeight.w800, color: K.ink2, ls: .4)),
              Text('(${f.reminders.length} of 3)', style: ff(size: rem(.54), w: FontWeight.w700, color: K.ink4)),
            ],
          ),
          const SizedBox(height: 6),
          for (var ri = 0; ri < f.reminders.length; ri++) _reminderRow(i, ri, f),
          if (canAdd)
            Press(
              scale: .97,
              onTap: () => _addReminder(i),
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Ico(_plus, size: 10, stroke: K.t7, sw: 2.6),
                    const SizedBox(width: 4),
                    Text('Add another reminder', style: ff(size: rem(.6), w: FontWeight.w800, color: K.t7)),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text('Max 3 reminders', style: ff(size: rem(.56), w: FontWeight.w700, color: K.ink4)),
            ),
        ],
      ),
    );
  }

  Widget _reminderRow(int i, int ri, _Function f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: K.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: K.bd),
      ),
      child: Row(
        children: [
          Ico(_bell, size: 11, stroke: K.t6, sw: 2),
          const SizedBox(width: 6),
          Expanded(
            child: _DropSelect(
              value: f.reminders[ri],
              options: _reminderOptions,
              onChanged: (v) => _updateReminder(i, ri, v),
            ),
          ),
          if (f.reminders.length > 1) ...[
            const SizedBox(width: 6),
            Press(
              scale: .9,
              onTap: () => _removeReminder(i, ri),
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(color: K.er1, borderRadius: BorderRadius.circular(5)),
                child: Center(child: Ico(_x, size: 10, stroke: K.er, sw: 2.6, round: false)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _genericReminderCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: K.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: K.bd),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(color: K.t0, borderRadius: BorderRadius.circular(8), border: Border.all(color: K.t1)),
            child: Center(child: Ico(_bellFull, size: 13, stroke: K.t7, sw: 2)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Set Reminder', style: ff(size: rem(.76), w: FontWeight.w800, color: K.ink)),
                const SizedBox(height: 1),
                Text('Get notified before this event', style: ff(size: rem(.56), w: FontWeight.w600, color: K.ink3)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _DropSelect(
            value: _genericReminder,
            options: _genericReminderOptions,
            onChanged: (v) => setState(() => _genericReminder = v),
          ),
        ],
      ),
    );
  }
}

class _DropSelect extends StatelessWidget {
  final String value;
  final List<(String, String)> options;
  final ValueChanged<String> onChanged;
  const _DropSelect({required this.value, required this.options, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: K.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: K.bd),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          icon: Ico(P.chevDown, size: 12, stroke: K.ink3, sw: 2),
          style: ff(size: rem(.66), w: FontWeight.w600, color: K.ink),
          items: options
              .map((o) => DropdownMenuItem(
                    value: o.$1,
                    child: Text(o.$2, style: ff(size: rem(.66), w: FontWeight.w600, color: K.ink)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
