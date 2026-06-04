import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/mood_entry_model.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class MoodProvider extends ChangeNotifier {
  final StorageService _storageService;
  late Box<MoodEntryModel> _moodBox;

  MoodProvider(this._storageService) {
    _moodBox = _storageService.getMoodBox();
  }

  List<MoodEntryModel> get entries => _moodBox.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> addEntry({required String mood, required String note, String? title}) async {
    final id = const Uuid().v4();
    final entry = MoodEntryModel(
      id: id,
      mood: mood,
      note: note,
      createdAt: DateTime.now(),
      title: title,
    );
    await _moodBox.put(id, entry);
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    await _moodBox.delete(id);
    notifyListeners();
  }

  Future<void> updateEntry(MoodEntryModel entry) async {
    await entry.save();
    notifyListeners();
  }
}
