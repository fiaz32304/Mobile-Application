import 'package:flutter/material.dart';

import '../../models/registration_model.dart';
import '../../services/auth_service.dart';
import '../../services/registration_service.dart';
import '../../services/ticket_service.dart';
import 'ticket_detail_screen.dart';

class MyRegistrationsScreen extends StatefulWidget {
  final VoidCallback? onRefreshStats;

  const MyRegistrationsScreen({super.key, this.onRefreshStats});

  @override
  State<MyRegistrationsScreen> createState() => _MyRegistrationsScreenState();
}

class _MyRegistrationsScreenState extends State<MyRegistrationsScreen> {
  List<RegistrationModel> _registrations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRegistrations();
  }

  Future<void> _loadRegistrations() async {
    setState(() => _isLoading = true);
    final user = AuthService.instance.currentUser;
    if (user?.id == null) return;

    try {
      final list = await RegistrationService.instance.getStudentRegistrations(
        user!.id!,
      );
      if (mounted) {
        setState(() {
          _registrations = list;
          _isLoading = false;
        });
      }
      widget.onRefreshStats?.call();
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF2E7D32);
      case 'pending':
        return const Color(0xFFEF6C00);
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFC62828);
      default:
        return Colors.grey.shade600;
    }
  }

  Future<void> _openTicketForRegistration(int registrationId) async {
    final ticket = await TicketService.instance.getTicketByRegistrationId(
      registrationId,
    );
    if (!mounted) return;
    if (ticket != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: ticket)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket not yet generated.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_registrations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            const Text(
              'No registrations yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Browse events and click Register to enroll.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRegistrations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _registrations.length,
        itemBuilder: (context, index) {
          final reg = _registrations[index];
          final statusColor = _getStatusColor(reg.status);
          final isApproved = reg.status == 'Approved';

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: statusColor.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isApproved
                                  ? Icons.check_circle
                                  : reg.status == 'Pending'
                                  ? Icons.hourglass_top
                                  : Icons.cancel,
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              reg.status.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'PKR ${(reg.ticketPrice ?? 0).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Event Title
                  Text(
                    reg.eventTitle ?? 'University Event',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${reg.eventDate ?? ""} • ${reg.eventTime ?? ""} • ${reg.eventVenue ?? ""}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // Payment & Submission details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Ref: ${reg.transactionReference ?? "N/A"}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade800,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Text(
                            'Method: ${reg.paymentMethod ?? "Manual"}  •  ${reg.registrationDate.split(" ").first}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      if (isApproved && reg.id != null)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.qr_code, size: 16),
                          label: const Text('View Ticket'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () => _openTicketForRegistration(reg.id!),
                        )
                      else if (reg.status == 'Pending')
                        Text(
                          'Awaiting Admin',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade900,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
