import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/sound_service.dart';
import 'dart:io';

class SoundSelectionScreen extends StatefulWidget {
  final String currentPath;

  const SoundSelectionScreen({super.key, required this.currentPath});

  @override
  State<SoundSelectionScreen> createState() => _SoundSelectionScreenState();
}

class _SoundSelectionScreenState extends State<SoundSelectionScreen> {
  List<String> _library = [];
  bool _isLoading = true;
  late String _selectedPath;
  late AudioPlayer _audioPlayer;
  String? _playingPath;

  @override
  void initState() {
    super.initState();
    _selectedPath = widget.currentPath;
    _audioPlayer = AudioPlayer();
    _loadLibrary();
    
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingPath = null);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadLibrary() async {
    setState(() => _isLoading = true);
    final lib = await SoundService.getLibrary();
    setState(() {
      _library = lib;
      _isLoading = false;
    });
  }

  Future<void> _playAudio(String path, bool isBuiltIn) async {
    try {
      if (_playingPath == path) {
        await _audioPlayer.stop();
        setState(() => _playingPath = null);
        return;
      }

      await _audioPlayer.stop();
      
      if (isBuiltIn) {
        // Remove 'assets/' prefix if it exists, as AssetSource expects path relative to assets folder
        String assetPath = path.startsWith('assets/') ? path.replaceFirst('assets/', '') : path;
        await _audioPlayer.play(AssetSource(assetPath));
      } else {
        await _audioPlayer.play(DeviceFileSource(path));
      }
      
      setState(() => _playingPath = path);
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final builtIn = SoundService.getBuiltInSounds();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('SELECT SOUND'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _selectedPath),
            child: Text('SAVE', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: primaryColor))
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle('BUILT-IN SOUNDS', primaryColor),
              ...builtIn.map((path) => _buildSoundTile(path, isBuiltIn: true, primaryColor: primaryColor)),
              
              const SizedBox(height: 32),
              _buildSectionTitle('YOUR LIBRARY', primaryColor),
              ..._library.map((path) => _buildSoundTile(path, primaryColor: primaryColor)),
              
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  final path = await SoundService.pickAndAdd();
                  if (path != null) {
                    _loadLibrary();
                  }
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('IMPORT FROM DEVICE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildSectionTitle(String title, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildSoundTile(String path, {bool isBuiltIn = false, required Color primaryColor}) {
    final fileName = path.split('/').last;
    final isSelected = _selectedPath == path;
    final isPlaying = _playingPath == path;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? primaryColor : Colors.white.withValues(alpha: 0.05),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: () {
          setState(() => _selectedPath = path);
          _playAudio(path, isBuiltIn);
        },
        leading: Icon(
          isPlaying ? Icons.pause_circle_filled_rounded : (isBuiltIn ? Icons.audiotrack_rounded : Icons.music_note_rounded),
          color: (isSelected || isPlaying) ? primaryColor : Colors.white24,
        ),
        title: Text(
          fileName,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) 
              Icon(Icons.check_circle_rounded, color: primaryColor),
            if (!isBuiltIn) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.white24, size: 20),
                onPressed: () async {
                  await SoundService.removeFromLibrary(path);
                  if (_selectedPath == path) {
                    _selectedPath = SoundService.getBuiltInSounds().first;
                  }
                  if (_playingPath == path) {
                    await _audioPlayer.stop();
                    _playingPath = null;
                  }
                  _loadLibrary();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
