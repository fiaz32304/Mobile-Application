import 'package:flutter/material.dart';

import '../../models/event_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import 'payment_submission_screen.dart';

class EventRegistrationScreen extends StatelessWidget {
  final EventModel event;

  const EventRegistrationScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final student = AuthService.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Event Registration'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Student Profile Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF0D47A1),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student?.name ?? 'Student',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Roll No: ${student?.rollNumber ?? "N/A"}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          student?.email ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Event Summary Card
            const Text(
              'Selected Event',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${event.eventDate}  •  ${event.eventTime}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                  ),
                  Text(
                    'Venue: ${event.venue}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Registration Fee:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        event.ticketPrice == 0
                            ? 'FREE'
                            : 'PKR ${event.ticketPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Manual Payment Instructions
            const Text(
              'Payment Instructions (Offline/Manual)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFFEF6C00),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'How Manual Payment Works:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEF6C00),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Transfer PKR ${event.ticketPrice.toStringAsFixed(0)} via JazzCash, EasyPaisa, or University Bank Account:\n'
                    '   • JazzCash / EasyPaisa: 0300-1234567 (Title: Campus Events)\n'
                    '   • Bank Transfer: Allied Bank AC 0123-45678901234\n'
                    '   • Or pay cash at the Campus Student Affairs Desk.\n'
                    '2. Copy the Transaction ID / Reference Number.\n'
                    '3. Click below to submit your payment details for Admin verification.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.brown.shade900,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            CustomButton(
              text: 'Proceed to Submit Payment Details',
              icon: Icons.payment,
              onPressed: () async {
                final success = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentSubmissionScreen(event: event),
                  ),
                );
                if (success == true && context.mounted) {
                  Navigator.pop(context, true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
