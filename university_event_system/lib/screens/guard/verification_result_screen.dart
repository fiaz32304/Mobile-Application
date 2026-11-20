import 'package:flutter/material.dart';

import '../../models/event_model.dart';
import '../../models/ticket_model.dart';
import '../../services/auth_service.dart';
import '../../services/ticket_service.dart';
import '../../widgets/custom_button.dart';

class VerificationResultScreen extends StatefulWidget {
  final EventModel event;
  final TicketVerificationResult initialResult;

  const VerificationResultScreen({
    super.key,
    required this.event,
    required this.initialResult,
  });

  @override
  State<VerificationResultScreen> createState() =>
      _VerificationResultScreenState();
}

class _VerificationResultScreenState extends State<VerificationResultScreen> {
  late TicketVerificationResult _result;
  bool _isConfirming = false;
  bool _entryGranted = false;
  TicketModel? _confirmedTicket;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _result = widget.initialResult;
    _confirmedTicket = widget.initialResult.ticket;
  }

  Future<void> _handleConfirmAllowEntry() async {
    final ticket = _confirmedTicket;
    final guard = AuthService.instance.currentUser;

    if (ticket == null ||
        ticket.id == null ||
        guard?.id == null ||
        widget.event.id == null) {
      return;
    }

    setState(() {
      _isConfirming = true;
      _errorMessage = null;
    });

    try {
      final updatedTicket = await TicketService.instance.confirmEntry(
        ticketId: ticket.id!,
        guardId: guard!.id!,
        expectedEventId: widget.event.id!,
      );

      if (!mounted) return;
      setState(() {
        _entryGranted = true;
        _confirmedTicket = updatedTicket;
        _isConfirming = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Entry confirmed for ${updatedTicket.studentName ?? "Student"}.',
          ),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isConfirming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticket = _confirmedTicket;
    final isAllowed = _result.isValid && !_entryGranted;
    final isAlreadyUsed = ticket?.ticketStatus == 'Used' && !_entryGranted;

    Color bannerColor;
    IconData bannerIcon;
    String bannerTitle;

    if (_entryGranted) {
      bannerColor = const Color(0xFF2E7D32);
      bannerIcon = Icons.check_circle;
      bannerTitle = 'ENTRY GRANTED & RECORDED';
    } else if (isAlreadyUsed) {
      bannerColor = const Color(0xFFEF6C00);
      bannerIcon = Icons.warning_amber_rounded;
      bannerTitle = 'TICKET ALREADY USED (DENIED)';
    } else if (isAllowed) {
      bannerColor = const Color(0xFF2E7D32);
      bannerIcon = Icons.verified_user;
      bannerTitle = 'TICKET VALID — READY FOR ENTRY';
    } else {
      bannerColor = const Color(0xFFC62828);
      bannerIcon = Icons.cancel;
      bannerTitle = 'ENTRY DENIED';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Ticket Verification'),
        backgroundColor: bannerColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: bannerColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: bannerColor, width: 2),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: bannerColor,
                    child: Icon(bannerIcon, size: 44, color: Colors.white),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    bannerTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: bannerColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage ??
                        (_entryGranted
                            ? 'Student entry has been confirmed and saved to SQLite.'
                            : _result.message),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: bannerColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Event Details
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gate Event Being Checked:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.event.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    Text(
                      '${widget.event.eventDate} at ${widget.event.eventTime}  •  ${widget.event.venue}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Student & Ticket Details
            if (ticket != null) ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Student & Pass Credentials:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow('Full Name', ticket.studentName ?? 'N/A'),
                      const Divider(height: 14),
                      _buildDetailRow(
                        'Roll Number',
                        ticket.studentRollNumber ?? 'N/A',
                        isBold: true,
                      ),
                      const Divider(height: 14),
                      _buildDetailRow('Email', ticket.studentEmail ?? 'N/A'),
                      const Divider(height: 14),
                      _buildDetailRow('Ticket ID', ticket.ticketCode),
                      const Divider(height: 14),
                      _buildDetailRow(
                        'Ticket Status',
                        ticket.ticketStatus.toUpperCase(),
                        color: bannerColor,
                      ),
                      if (ticket.usedAt != null) ...[
                        const Divider(height: 14),
                        _buildDetailRow('Checked In At', ticket.usedAt!),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            if (isAllowed) ...[
              CustomButton(
                text: 'Allow Entry (Confirm Check-In)',
                isLoading: _isConfirming,
                icon: Icons.check,
                color: const Color(0xFF2E7D32),
                height: 52,
                onPressed: _handleConfirmAllowEntry,
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Deny Entry (Cancel)',
                isOutlined: true,
                color: const Color(0xFFC62828),
                onPressed: () => Navigator.pop(context),
              ),
            ] else ...[
              CustomButton(
                text: 'Check Next Student',
                icon: Icons.arrow_back,
                color: const Color(0xFF0D47A1),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
