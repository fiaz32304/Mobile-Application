import 'package:flutter/material.dart';

import '../../models/event_model.dart';
import '../../services/ticket_service.dart';
import '../../widgets/custom_button.dart';
import 'verification_result_screen.dart';

class RollNumberCheckScreen extends StatefulWidget {
  final EventModel event;

  const RollNumberCheckScreen({super.key, required this.event});

  @override
  State<RollNumberCheckScreen> createState() => _RollNumberCheckScreenState();
}

class _RollNumberCheckScreenState extends State<RollNumberCheckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rollController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _rollController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyRollNumber() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final rollNumber = _rollController.text.trim();
      final result = await TicketService.instance.verifyTicketRollNumber(
        rollNumber: rollNumber,
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
            content: Text('Error verifying roll number: $e'),
            backgroundColor: const Color(0xFFC62828),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Roll Number Verification'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Event Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event, color: Color(0xFF0D47A1)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.event.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${widget.event.eventDate}  •  ${widget.event.venue}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Enter Student University Roll Number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Search for student approved registration & ticket in SQLite database.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _rollController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Student Roll Number',
                  hintText: 'e.g. FA24-BSE-042',
                  prefixIcon: const Icon(
                    Icons.badge_outlined,
                    color: Color(0xFF0D47A1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter the student roll number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Demo Shortcut Chip
              Row(
                children: [
                  const Text(
                    'Quick Test: ',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  ActionChip(
                    label: const Text(
                      'FA24-BSE-042 (Ali Khan)',
                      style: TextStyle(fontSize: 11),
                    ),
                    onPressed: () {
                      setState(() {
                        _rollController.text = 'FA24-BSE-042';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Search & Verify Ticket',
                isLoading: _isLoading,
                icon: Icons.search,
                onPressed: _handleVerifyRollNumber,
              ),
              const SizedBox(height: 16),

              // Instructional Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.security, size: 18, color: Colors.grey.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Security Rule: Roll number lookup displays matching credentials and ticket validity. Entry will NOT be granted until you compare details with physical student ID and click "Allow Entry".',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
