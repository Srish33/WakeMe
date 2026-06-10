import 'package:hive_flutter/hive_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class SoundService {
  static const String soundBoxName = 'sound_library';
  
  static Future<List<String>> getLibrary() async {
    final box = await Hive.openBox<String>(soundBoxName);
    return box.values.toList();
  }

  static Future<void> addToLibrary(String path) async {
    final box = await Hive.openBox<String>(soundBoxName);
    if (!box.values.contains(path)) {
      await box.add(path);
    }
  }

  static Future<void> removeFromLibrary(String path) async {
    final box = await Hive.openBox<String>(soundBoxName);
    final key = box.keys.firstWhere((k) => box.get(k) == path, orElse: () => null);
    if (key != null) {
      await box.delete(key);
    }
  }

  static Future<String?> pickAndAdd() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      await addToLibrary(path);
      return path;
    }
    return null;
  }
  
  static List<String> getBuiltInSounds() {
    return [
      'assets/sounds/Tropical.mp3',
      'assets/sounds/Morning.mp3',
      'assets/sounds/scam.mp3',
      'assets/sounds/Guitar.mp3',
      'assets/sounds/Trippin.mp3',
    ];
  }
}
