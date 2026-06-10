import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class PhotoMatchChallenge extends StatefulWidget {
  final String referencePhotoPath;
  final VoidCallback onSuccess;
  final VoidCallback onFail;

  const PhotoMatchChallenge({
    super.key,
    required this.referencePhotoPath,
    required this.onSuccess,
    required this.onFail,
  });

  @override
  State<PhotoMatchChallenge> createState() => _PhotoMatchChallengeState();
}

class _PhotoMatchChallengeState extends State<PhotoMatchChallenge> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(cameras[0], ResolutionPreset.medium, enableAudio: false);
    await _controller!.initialize();
    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final XFile photo = await _controller!.takePicture();
      final bool isMatch = await _compareImages(widget.referencePhotoPath, photo.path);

      if (isMatch) {
        widget.onSuccess();
      } else {
        widget.onFail();
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
      widget.onFail();
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<bool> _compareImages(String refPath, String capPath) async {
    // Basic similarity check: Downscale to 32x32 and compare average grayscale values
    final refBytes = await File(refPath).readAsBytes();
    final capBytes = await File(capPath).readAsBytes();

    final refImg = img.decodeImage(refBytes);
    final capImg = img.decodeImage(capBytes);

    if (refImg == null || capImg == null) return false;

    final refSmall = img.copyResize(refImg, width: 32, height: 32);
    final capSmall = img.copyResize(capImg, width: 32, height: 32);

    double totalDiff = 0;
    for (int y = 0; y < 32; y++) {
      for (int x = 0; x < 32; x++) {
        final p1 = refSmall.getPixel(x, y);
        final p2 = capSmall.getPixel(x, y);

        // Simple brightness difference
        final diff = (p1.r - p2.r).abs() + (p1.g - p2.g).abs() + (p1.b - p2.b).abs();
        totalDiff += diff / (255 * 3);
      }
    }

    final averageDiff = totalDiff / (32 * 32);
    debugPrint('Image Similarity Diff: $averageDiff');

    // Threshold: 0.25 (lower is more similar)
    return averageDiff < 0.25;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'PHOTO MATCH',
          style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        const Text(
          'Take a photo of the same object',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 24),
        if (!_isInitialized)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CameraPreview(_controller!),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                      image: DecorationImage(
                        image: FileImage(File(widget.referencePhotoPath)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _takePhoto,
            icon: _isProcessing 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.camera_alt_rounded),
            label: Text(_isProcessing ? 'COMPARING...' : 'DONE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}
