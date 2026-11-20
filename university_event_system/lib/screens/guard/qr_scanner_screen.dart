import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../models/event_model.dart';
import '../../services/ticket_service.dart';
import 'roll_number_check_screen.dart';
import 'verification_result_screen.dart';

class QrScannerScreen extends StatefulWidget {
  final EventModel event;

  const QrScannerScreen({super.key, required this.event});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(String rawValue) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final result = await TicketService.instance.verifyTicketToken(
        token: rawValue,
        expectedEventId: widget.event.id!,
      );

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationResultScreen(
            event: widget.event,
            initialResult: result,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verifying QR: $e'),
            backgroundColor: const Color(0xFFC62828),
          ),
        );
      }
    } finally {
      if (mounted) {
        // Small delay before accepting next scan
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() => _isProcessing = false);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Student Ticket QR'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: 'Flashlight',
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            tooltip: 'Switch Camera',
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Scanner
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final code = barcode.rawValue;
                if (code != null && code.isNotEmpty) {
                  _handleBarcode(code);
                  break;
                }
              }
            },
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 64,
                        color: Colors.white54,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Camera unavailable or permission not granted:\n${error.errorDetails?.message ?? "Device camera not found"}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.keyboard),
                        label: const Text('Switch to Manual Roll Number Check'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RollNumberCheckScreen(event: widget.event),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Scanner Target Frame Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isProcessing
                      ? Colors.orange
                      : const Color(0xFF0D47A1),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _isProcessing
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : null,
            ),
          ),

          // Top Info Banner
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    'Gate: ${widget.event.title}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Align QR code inside the target frame',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Manual Input Shortcut
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.keyboard_outlined),
              label: const Text('Enter Student Roll Number Manually'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0D47A1),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RollNumberCheckScreen(event: widget.event),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
