import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerChallenge extends StatefulWidget {
  final String targetBarcode;
  final VoidCallback onSuccess;
  final VoidCallback onFail;

  const BarcodeScannerChallenge({
    super.key,
    required this.targetBarcode,
    required this.onSuccess,
    required this.onFail,
  });

  @override
  State<BarcodeScannerChallenge> createState() => _BarcodeScannerChallengeState();
}

class _BarcodeScannerChallengeState extends State<BarcodeScannerChallenge> {
  final MobileScannerController controller = MobileScannerController();
  bool _isScanning = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'BARCODE SCANNER',
          style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        const Text(
          'Scan the registered barcode to dismiss',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                if (!_isScanning) return;
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue == widget.targetBarcode) {
                    setState(() => _isScanning = false);
                    widget.onSuccess();
                    break;
                  } else {
                    // Wrong barcode
                    debugPrint('Wrong barcode: ${barcode.rawValue}');
                  }
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Looking for registered code...',
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }
}
