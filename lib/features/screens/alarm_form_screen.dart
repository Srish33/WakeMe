import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:wakeme/core/services/settings_service.dart';
import '../models/alarm_model.dart';
import '../models/routine_task_model.dart';
import '../providers/alarm_provider.dart';
import 'sound_selection_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:camera/camera.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io';

// Comprehensive editor for creating or modifying alarms and morning routines.
class AlarmFormScreen extends StatefulWidget {
  final AlarmModel? alarm; // Null if creating a new alarm

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
  late List<RoutineTask> _routineTasks;
  late String _routineSoundPath;
  late ChallengeType _selectedChallenge;
  late int _stepGoal;
  String? _barcodeData;
  String? _referencePhotoPath;
  final TextEditingController _labelController = TextEditingController();

  final List<String> _daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  final Map<ChallengeType, String> _challengeDescriptions = {
    ChallengeType.numberOrder: "Tap the numbers in ascending order (1, 2, 3...) to clear the level.",
    ChallengeType.memorySequence: "Watch the sequence of glowing circles and repeat it exactly by tapping them in the same order.",
    ChallengeType.matchPairs: "Flip the cards to find matching pairs of icons. Match all cards to proceed.",
    ChallengeType.patternMemory: "Memorize the highlighted grid cells and tap them after they disappear.",
    ChallengeType.sequencePath: "Connect the numbered nodes in order by dragging your finger through the path without lifting it.",
    ChallengeType.stepCounter: "Walk the required number of steps physically. The app detects movement to ensure you are out of bed.",
    ChallengeType.math: "Solve the mathematical expression and enter the correct result using the keyboard.",
    ChallengeType.barcodeScanner: "Locate and scan the specific barcode or QR code you registered during setup.",
    ChallengeType.photoMatch: "Take a photo that matches the reference image you saved (e.g., your bathroom sink or coffee machine).",
    ChallengeType.typing: "Type the displayed motivational phrase exactly as it appears, including punctuation and capitalization.",
  };

  @override
  void initState() {
    super.initState();
    final SettingsService settings = context.read<SettingsService>();
    if (widget.alarm != null) {
      _selectedTime = TimeOfDay(hour: widget.alarm!.hour, minute: widget.alarm!.minute);
      _selectedDays = List.from(widget.alarm!.repeatDays);
      _soundPath = widget.alarm!.soundPath;
      _snoozeDuration = widget.alarm!.snoozeDuration;
      _maxSnoozes = widget.alarm!.maxSnoozes;
      _routineTasks = List.from(widget.alarm!.routineTasks);
      _routineSoundPath = widget.alarm!.routineReminderSoundPath;
      _selectedChallenge = widget.alarm!.challengeType;
      _stepGoal = widget.alarm!.stepGoal;
      _barcodeData = widget.alarm!.barcodeData;
      _referencePhotoPath = widget.alarm!.referencePhotoPath;
      _labelController.text = widget.alarm!.label ?? '';
    } else {
      _selectedTime = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 1)));
      _selectedDays = [];
      _soundPath = settings.defaultAlarmSound;
      _snoozeDuration = settings.defaultSnoozeDuration;
      _maxSnoozes = settings.defaultMaxSnoozes;
      _routineTasks = [];
      _routineSoundPath = 'Tropical.mp3';
      _selectedChallenge = ChallengeType.memorySequence;
      _stepGoal = 10;
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
      updatedAlarm.routineTasks = _routineTasks;
      updatedAlarm.routineReminderSoundPath = _routineSoundPath;
      updatedAlarm.challengeType = _selectedChallenge;
      updatedAlarm.stepGoal = _stepGoal;
      updatedAlarm.barcodeData = _barcodeData;
      updatedAlarm.referencePhotoPath = _referencePhotoPath;
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
        routineTasks: _routineTasks,
        routineReminderSoundPath: _routineSoundPath,
        challengeType: _selectedChallenge,
        stepGoal: _stepGoal,
        barcodeData: _barcodeData,
        referencePhotoPath: _referencePhotoPath,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFF12121A),
      appBar: AppBar(
        title: Text(widget.alarm == null ? 'NEW ALARM' : 'EDIT ALARM'),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
        actions: [
          TextButton(onPressed: _saveAlarm, child: Text('SAVE', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(colorScheme: ColorScheme.dark(primary: primaryColor, surface: const Color(0xFF1E1E2A), onSurface: Colors.white)),
                    child: child!,
                  ),
                );
                if (time != null) setState(() => _selectedTime = time);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                decoration: BoxDecoration(color: const Color(0xFF1E1E2A), borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
                child: Text('${_selectedTime.hourOfPeriod.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.period.name.toUpperCase()}', style: GoogleFonts.jetBrainsMono(fontSize: 46, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            
            const SizedBox(height: 48),
            _buildSectionTitle('REPEAT'),
            const SizedBox(height: 16),
            FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _daysOfWeek.map((day) {
                  final isSelected = _selectedDays.contains(day);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => isSelected ? _selectedDays.remove(day) : _selectedDays.add(day)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: isSelected ? primaryColor : Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle, boxShadow: isSelected ? [BoxShadow(color: primaryColor.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 1)] : []),
                        child: Center(child: Text(day[0], style: TextStyle(color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3), fontWeight: FontWeight.bold))),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 40),
            _buildSectionTitle('WAKE-UP CHALLENGE'),
            const SizedBox(height: 16),
            _buildChallengeSelection(),
            
            _buildChallengeSettings(),

            const SizedBox(height: 40),
            _buildSectionTitle('LABEL'),
            const SizedBox(height: 12),
            TextField(
              controller: _labelController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(hintText: 'Work, Gym, etc.', hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)), filled: true, fillColor: const Color(0xFF1E1E2A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)))),
            ),
            
            const SizedBox(height: 40),
            _buildSectionTitle('SOUND'),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              tileColor: const Color(0xFF1E1E2A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
              title: Text(_soundPath.split('/').last, style: const TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.music_note_rounded, color: Color(0xFF22D3EE)),
              onTap: () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (context) => SoundSelectionScreen(currentPath: _soundPath)),
                );
                if (result != null) setState(() => _soundPath = result);
              },
            ),
            
            const SizedBox(height: 40),
            _buildSectionTitle('SNOOZE SETTINGS'),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildDropdownContainer('Duration', _snoozeDuration, [1, 5, 10, 15, 20], (val) => setState(() => _snoozeDuration = val!)),
                const SizedBox(width: 16),
                _buildDropdownContainer('Max Snoozes', _maxSnoozes, [1, 3, 5, 10], (val) => setState(() => _maxSnoozes = val!)),
              ],
            ),

            const SizedBox(height: 40),
            _buildSectionTitle('MORNING ROUTINE'),
            const SizedBox(height: 16),
            ReorderableListView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              itemCount: _routineTasks.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final task = _routineTasks.removeAt(oldIndex);
                  _routineTasks.insert(newIndex, task);
                });
              },
              itemBuilder: (context, index) {
                final task = _routineTasks[index];
                return Container(
                  key: ValueKey(task.id), margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: const Color(0xFF1E1E2A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
                  child: ListTile(
                    title: Text(task.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('${task.durationMinutes} min', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.white70), onPressed: () => _showTaskDialog(task: task, index: index)),
                      IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent), onPressed: () => setState(() => _routineTasks.removeAt(index))),
                      const Icon(Icons.drag_handle_rounded, color: Colors.white24),
                    ]),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(onPressed: () => _showTaskDialog(), icon: const Icon(Icons.add_rounded), label: const Text('ADD TASK'), style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.05), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12))),
            ),

            if (_routineTasks.isNotEmpty) ...[
              const SizedBox(height: 16),
              Align(alignment: Alignment.centerRight, child: Text('Total Duration: ${_routineTasks.fold(0, (sum, t) => sum + t.durationMinutes)} min', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))),
            ],

            const SizedBox(height: 32),
            _buildSectionTitle('ROUTINE REMINDER SOUND'),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              tileColor: const Color(0xFF1E1E2A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
              title: Text(_routineSoundPath.split('/').last, style: const TextStyle(color: Colors.white)),
              trailing: Icon(Icons.notifications_active_outlined, color: primaryColor),
              onTap: () async {
                final result = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (context) => SoundSelectionScreen(currentPath: _routineSoundPath)),
                );
                if (result != null) setState(() => _routineSoundPath = result);
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(alignment: Alignment.centerLeft, child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white.withValues(alpha: 0.3))));
  }

  Widget _buildChallengeSelection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _buildChallengeCategory('MEMORY & PUZZLE', [
            ChallengeType.numberOrder,
            ChallengeType.memorySequence,
            ChallengeType.matchPairs,
            ChallengeType.patternMemory,
            ChallengeType.sequencePath,
          ]),
          const Divider(color: Colors.white10, height: 1),
          _buildChallengeCategory('INTERACTIVE', [
            ChallengeType.stepCounter,
            ChallengeType.math,
            ChallengeType.barcodeScanner,
            ChallengeType.photoMatch,
            ChallengeType.typing,
          ]),
        ],
      ),
    );
  }

  Widget _buildChallengeSettings() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    Widget settings = const SizedBox.shrink();

    if (_selectedChallenge == ChallengeType.stepCounter) {
      settings = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          _buildSectionTitle('STEP COUNTER CONFIGURATION'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Steps to Walk', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('$_stepGoal', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Slider(
                  value: _stepGoal.toDouble(),
                  min: 10,
                  max: 500,
                  divisions: 49,
                  activeColor: primaryColor,
                  inactiveColor: Colors.white10,
                  onChanged: (val) => setState(() => _stepGoal = val.toInt()),
                ),
                const Text(
                  'User must walk physically. Shake detection is active to prevent cheating.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white24, fontSize: 10, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (_selectedChallenge == ChallengeType.barcodeScanner) {
      settings = Column(
        children: [
          const SizedBox(height: 24),
          _buildSectionTitle('BARCODE SETUP'),
          const SizedBox(height: 12),
          ListTile(
            tileColor: const Color(0xFF1E1E2A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(_barcodeData ?? 'No barcode registered', style: const TextStyle(color: Colors.white)),
            trailing: Icon(Icons.qr_code_2_rounded, color: primaryColor),
            onTap: _registerBarcode,
          ),
        ],
      );
    } else if (_selectedChallenge == ChallengeType.photoMatch) {
      settings = Column(
        children: [
          const SizedBox(height: 24),
          _buildSectionTitle('REFERENCE PHOTO'),
          const SizedBox(height: 12),
          if (_referencePhotoPath != null)
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(image: FileImage(File(_referencePhotoPath!)), fit: BoxFit.cover),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _captureReferencePhoto,
              icon: const Icon(Icons.camera_alt_rounded),
              label: Text(_referencePhotoPath == null ? 'CAPTURE REFERENCE' : 'RETAKE PHOTO'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.05), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
        ],
      );
    }

    return settings;
  }

  Future<void> _registerBarcode() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Scan Barcode'), backgroundColor: Colors.black),
        body: MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              Navigator.pop(context, barcodes.first.rawValue);
            }
          },
        ),
      ),
    );

    if (result != null) {
      setState(() => _barcodeData = result);
    }
  }

  Future<void> _captureReferencePhoto() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    if (!mounted) return;

    final photo = await showDialog<XFile>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CameraCaptureDialog(camera: cameras[0]),
    );

    if (photo != null) {
      setState(() => _referencePhotoPath = photo.path);
    }
  }

  Widget _buildChallengeCategory(String title, List<ChallengeType> types) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ),
        ...types.map((type) => RadioListTile<ChallengeType>(
          value: type,
          groupValue: _selectedChallenge,
          onChanged: (val) {
            setState(() => _selectedChallenge = val!);
            _showChallengeDescription(val!);
          },
          title: Text(type.label, style: const TextStyle(color: Colors.white, fontSize: 14)),
          secondary: Icon(type.icon, color: Colors.white38, size: 20),
          activeColor: Theme.of(context).colorScheme.primary,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          dense: true,
        )),
      ],
    );
  }

  void _showChallengeDescription(ChallengeType type) {
    final description = _challengeDescriptions[type] ?? "No description available.";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(type.icon, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(width: 12),
            Text(type.label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          description,
          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('GOT IT', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownContainer(String title, int value, List<int> options, ValueChanged<int?> onChanged) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFF1E1E2A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          DropdownButton<int>(value: value, isExpanded: true, underline: const SizedBox(), dropdownColor: const Color(0xFF1E1E2A), items: options.map((int value) => DropdownMenuItem<int>(value: value, child: Text('$value', style: const TextStyle(color: Colors.white)))).toList(), onChanged: onChanged),
        ]),
      ),
    );
  }

  void _showTaskDialog({RoutineTask? task, int? index}) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final nameController = TextEditingController(text: task?.name);
    final durationController = TextEditingController(text: task?.durationMinutes.toString() ?? '5');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2A),
        title: Text(task == null ? 'Add Task' : 'Edit Task', style: const TextStyle(color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameController, autofocus: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Task Name', labelStyle: TextStyle(color: Colors.white70))),
          const SizedBox(height: 16),
          TextField(controller: durationController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Duration (min)', labelStyle: TextStyle(color: Colors.white70))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  final newTask = RoutineTask(id: task?.id ?? const Uuid().v4(), name: nameController.text, durationMinutes: int.tryParse(durationController.text) ?? 5);
                  if (index != null) _routineTasks[index] = newTask;
                  else _routineTasks.add(newTask);
                });
                Navigator.pop(context);
              }
            },
            child: Text('OK', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }
}

class _CameraCaptureDialog extends StatefulWidget {
  final CameraDescription camera;
  const _CameraCaptureDialog({required this.camera});

  @override
  State<_CameraCaptureDialog> createState() => _CameraCaptureDialogState();
}

class _CameraCaptureDialogState extends State<_CameraCaptureDialog> {
  late CameraController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium, enableAudio: false);
    _controller.initialize().then((_) {
      if (mounted) setState(() => _isInitialized = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Capture Reference'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          if (_isInitialized)
            Center(child: CameraPreview(_controller))
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: _isInitialized
                    ? () async {
                        try {
                          final p = await _controller.takePicture();
                          if (context.mounted) Navigator.pop(context, p);
                        } catch (e) {
                          debugPrint('Error taking picture: $e');
                        }
                      }
                    : null,
                child: const Icon(Icons.camera, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
