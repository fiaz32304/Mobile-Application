import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/ticket_model.dart';

class TicketDetailScreen extends StatelessWidget {
  final TicketModel ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'valid':
        return const Color(0xFF2E7D32);
      case 'used':
        return const Color(0xFFEF6C00);
      case 'cancelled':
        return const Color(0xFFC62828);
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(ticket.ticketStatus);
    final isValid = ticket.ticketStatus == 'Valid';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Campus Event Ticket'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: statusColor.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ticket Header Banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D47A1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'OFFICIAL ENTRY PASS',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                ticket.ticketStatus.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ticket.eventTitle ?? 'University Event',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ticket ID: ${ticket.ticketCode}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // QR Code Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 20,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: ticket.verificationToken,
                            version: QrVersions.auto,
                            size: 190,
                            backgroundColor: Colors.white,
                            errorStateBuilder: (cxt, err) {
                              return const Center(
                                child: Text('Error generating QR code'),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Security Verification Token',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        SelectableText(
                          ticket.verificationToken,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dotted Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: List.generate(
                        30,
                        (i) => Expanded(
                          child: Container(
                            color: i % 2 == 0
                                ? Colors.grey.shade300
                                : Colors.transparent,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Ticket Details
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildRow('STUDENT NAME', ticket.studentName ?? 'N/A'),
                        const SizedBox(height: 10),
                        _buildRow(
                          'ROLL NUMBER',
                          ticket.studentRollNumber ?? 'N/A',
                        ),
                        const SizedBox(height: 10),
                        _buildRow(
                          'DATE & TIME',
                          '${ticket.eventDate ?? ""} at ${ticket.eventTime ?? ""}',
                        ),
                        const SizedBox(height: 10),
                        _buildRow(
                          'VENUE',
                          ticket.eventVenue ?? 'University Campus',
                        ),
                        const SizedBox(height: 10),
                        _buildRow('ISSUED AT', ticket.issuedAt),

                        if (ticket.ticketStatus == 'Used' &&
                            ticket.usedAt != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.verified,
                                      color: Color(0xFFEF6C00),
                                      size: 16,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Ticket Already Used / Checked In',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFEF6C00),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Checked in at ${ticket.usedAt}${ticket.guardName != null ? " by ${ticket.guardName}" : ""}. Double entry is prevented.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (isValid) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF2E7D32),
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Present this QR code or your Roll Number to the security guard at the venue gate for check-in.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A237E),
            ),
          ),
        ),
      ],
    );
  }
}
