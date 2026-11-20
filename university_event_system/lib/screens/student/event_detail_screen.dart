import 'package:flutter/material.dart';

import '../../models/event_model.dart';
import '../../models/registration_model.dart';
import '../../models/ticket_model.dart';
import '../../services/auth_service.dart';
import '../../services/event_service.dart';
import '../../services/registration_service.dart';
import '../../services/ticket_service.dart';
import '../../widgets/custom_button.dart';
import 'event_registration_screen.dart';
import 'ticket_detail_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  RegistrationModel? _myRegistration;
  TicketModel? _myTicket;
  int _remainingSeats = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRegistrationStatus();
  }

  Future<void> _loadRegistrationStatus() async {
    setState(() => _isLoading = true);
    final user = AuthService.instance.currentUser;
    if (user?.id == null || widget.event.id == null) return;

    try {
      final regs = await RegistrationService.instance.getStudentRegistrations(
        user!.id!,
      );
      final matchingReg = regs
          .where((r) => r.eventId == widget.event.id)
          .firstOrNull;

      TicketModel? ticket;
      if (matchingReg != null && matchingReg.status == 'Approved') {
        final tickets = await TicketService.instance.getStudentTickets(
          user.id!,
        );
        ticket = tickets
            .where((t) => t.registrationId == matchingReg.id)
            .firstOrNull;
      }

      final remaining = await EventService.instance.getRemainingCapacity(
        widget.event.id!,
      );

      if (mounted) {
        setState(() {
          _myRegistration = matchingReg;
          _myTicket = ticket;
          _remainingSeats = remaining;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category tag & price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D47A1)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          event.category.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF0D47A1),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          event.ticketPrice == 0
                              ? 'Free Entry'
                              : 'PKR ${event.ticketPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Color(0xFF2E7D32),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Key Details Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          icon: Icons.calendar_today,
                          label: 'Date',
                          value: event.eventDate,
                        ),
                        const Divider(height: 16),
                        _buildDetailRow(
                          icon: Icons.access_time,
                          label: 'Time',
                          value: event.eventTime,
                        ),
                        const Divider(height: 16),
                        _buildDetailRow(
                          icon: Icons.location_on_outlined,
                          label: 'Venue',
                          value: event.venue,
                        ),
                        const Divider(height: 16),
                        _buildDetailRow(
                          icon: Icons.people_outline,
                          label: 'Available Seats',
                          value:
                              '$_remainingSeats / ${event.capacity} total seats',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'About this Event',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Registration status / Action banner
                  if (_myRegistration != null) ...[
                    _buildExistingRegistrationBanner(),
                  ] else if (_remainingSeats <= 0) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: const Center(
                        child: Text(
                          'This event is fully booked.',
                          style: TextStyle(
                            color: Color(0xFFC62828),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    CustomButton(
                      text: 'Register for Event',
                      icon: Icons.app_registration,
                      onPressed: () async {
                        final registered = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EventRegistrationScreen(event: event),
                          ),
                        );
                        if (registered == true) {
                          _loadRegistrationStatus();
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0D47A1)),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildExistingRegistrationBanner() {
    final status = _myRegistration!.status;

    if (status == 'Approved') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade300),
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 24),
                SizedBox(width: 8),
                Text(
                  'Registration Approved!',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Your payment was verified by the admin and your official ticket is ready.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(height: 14),
            if (_myTicket != null)
              CustomButton(
                text: 'View Official Ticket & QR Code',
                icon: Icons.qr_code_2,
                color: const Color(0xFF2E7D32),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketDetailScreen(ticket: _myTicket!),
                    ),
                  );
                },
              ),
          ],
        ),
      );
    } else if (status == 'Pending') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade300),
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hourglass_top, color: Color(0xFFEF6C00), size: 24),
                SizedBox(width: 8),
                Text(
                  'Payment Under Verification',
                  style: TextStyle(
                    color: Color(0xFFEF6C00),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Your registration has been submitted. Reference: ${_myRegistration?.transactionReference ?? "N/A"}.\nThe administrator will verify your payment and issue your ticket.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel, color: Color(0xFFC62828), size: 24),
                SizedBox(width: 8),
                Text(
                  'Registration Rejected',
                  style: TextStyle(
                    color: Color(0xFFC62828),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Your previous payment was not verified. You may re-submit with correct payment details.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Re-Submit Registration',
              icon: Icons.refresh,
              color: const Color(0xFF0D47A1),
              onPressed: () async {
                final registered = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        EventRegistrationScreen(event: widget.event),
                  ),
                );
                if (registered == true) _loadRegistrationStatus();
              },
            ),
          ],
        ),
      );
    }
  }
}
