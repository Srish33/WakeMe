import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/alarm_model.dart';
import '../providers/alarm_provider.dart';
import '../../core/theme/app_theme.dart';

class AlarmFormScreen extends StatefulWidget {
  final AlarmModel? alarm;

  const AlarmFormScreen({super.key, this.alarm});

  @override
  State<AlarmFormScreen> createState() => _AlarmFormScreenState();
}

class _AlarmFormScreenState extends State<AlarmFormScreen> {
  late TimeOfDay _selectedTime;
  late List<String> _selectedDays;
  late String _soundPath;
  late int _snoozeDuration;
  late int _maxSnoozes;
  final TextEditingController _labelController = TextEditingController();

  final List<String> _daysOfWeek = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];

  final List<String> _defaultSounds = [
    'Classic Bell', 'Morning Rise', 'Soft Chime', 'Digital Alarm'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.alarm != null) {
      _selectedTime = TimeOfDay(hour: widget.alarm!.hour, minute: widget.alarm!.minute);
      _selectedDays = List.from(widget.alarm!.repeatDays);
      _soundPath = widget.alarm!.soundPath;
      _snoozeDuration = widget.alarm!.snoozeDuration;
      _maxSnoozes = widget.alarm!.maxSnoozes;
      _labelController.text = widget.alarm!.label ?? '';
    } else {
      _selectedTime = const TimeOfDay(hour: 7, minute: 0);
      _selectedDays = [];
      _soundPath = 'default';
      _snoozeDuration = 5;
      _maxSnoozes = 3;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  String _calculateNextRing() {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    if (_selectedDays.isNotEmpty) {
      while (!_selectedDays.contains(_getDayName(scheduled.weekday))) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
    }

    final diff = scheduled.difference(now);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    return 'Alarm will ring in $hours hours $minutes minutes';
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }

  Future<void> _pickCustomSound() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _soundPath = result.files.single.path!;
      });
    }
  }

  void _saveAlarm() {
    final provider = context.read<AlarmProvider>();
    if (widget.alarm != null) {
      final updatedAlarm = widget.alarm!;
      updatedAlarm.hour = _selectedTime.hour;
      updatedAlarm.minute = _selectedTime.minute;
      updatedAlarm.repeatDays = _selectedDays;
      updatedAlarm.soundPath = _soundPath;
      updatedAlarm.snoozeDuration = _snoozeDuration;
      updatedAlarm.maxSnoozes = _maxSnoozes;
      updatedAlarm.label = _labelController.text.isNotEmpty ? _labelController.text : null;
      provider.updateAlarm(updatedAlarm);
    } else {
      provider.addAlarm(
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
        repeatDays: _selectedDays,
        soundPath: _soundPath,
        snoozeDuration: _snoozeDuration,
        maxSnoozes: _maxSnoozes,
        label: _labelController.text.isNotEmpty ? _labelController.text : null,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm == null ? 'CREATE ALARM' : 'EDIT ALARM'),
        actions: [
          IconButton(onPressed: _saveAlarm, icon: const Icon(Icons.check)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _calculateNextRing(),
              style: TextStyle(
                color: isDark ? AppTheme.secondaryTextColor : AppTheme.lightSecondaryTextColor,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: _selectedTime);
                if (time != null) setState(() => _selectedTime = time);
              },
              child: Text(
                '${_selectedTime.hourOfPeriod.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}',
                style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Repeat Days'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _daysOfWeek.map((day) {
                final isSelected = _selectedDays.contains(day);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedDays.remove(day);
                      } else {
                        _selectedDays.add(day);
                      }
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryPurple),
                    ),
                    child: Center(
                      child: Text(
                        day[0],
                        style: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Alarm Sound'),
            ListTile(
              title: Text(_soundPath == 'default' ? 'Default' : _soundPath.split('/').last),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showSoundPicker();
              },
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Snooze'),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _snoozeDuration,
                    decoration: const InputDecoration(labelText: 'Duration'),
                    items: [5, 10, 15, 20].map((d) => DropdownMenuItem(value: d, child: Text('$d mins'))).toList(),
                    onChanged: (v) => setState(() => _snoozeDuration = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _maxSnoozes,
                    decoration: const InputDecoration(labelText: 'Limit'),
                    items: [1, 2, 3, 999].map((l) => DropdownMenuItem(value: l, child: Text(l == 999 ? 'Unlimited' : '$l times'))).toList(),
                    onChanged: (v) => setState(() => _maxSnoozes = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Label',
                hintText: 'Morning Alarm',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showSoundPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            ..._defaultSounds.map((sound) => ListTile(
              title: Text(sound),
              onTap: () {
                setState(() => _soundPath = sound);
                Navigator.pop(context);
              },
            )),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Custom Sound'),
              onTap: () {
                Navigator.pop(context);
                _pickCustomSound();
              },
            ),
          ],
        );
      },
    );
  }
}
