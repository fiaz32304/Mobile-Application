import 'package:flutter/material.dart';

import '../../models/payment_model.dart';
import '../../services/auth_service.dart';
import '../../services/payment_service.dart';

class PendingPaymentsScreen extends StatefulWidget {
  const PendingPaymentsScreen({super.key});

  @override
  State<PendingPaymentsScreen> createState() => _PendingPaymentsScreenState();
}

class _PendingPaymentsScreenState extends State<PendingPaymentsScreen> {
  List<PaymentModel> _pendingPayments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingPayments();
  }

  Future<void> _loadPendingPayments() async {
    setState(() => _isLoading = true);
    try {
      final list = await PaymentService.instance.getPendingPayments();
      if (mounted) {
        setState(() {
          _pendingPayments = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleApprove(PaymentModel payment) async {
    final admin = AuthService.instance.currentUser;
    if (admin == null || admin.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve Payment?'),
        content: Text(
          'Confirm payment of PKR ${payment.amount.toStringAsFixed(0)} for ${payment.studentName ?? "Student"} (${payment.studentRollNumber ?? "N/A"}).\n\nThis will automatically generate a valid ticket and QR code for this student.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Approve & Issue Ticket',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final ticket = await PaymentService.instance.approvePayment(
          registrationId: payment.registrationId,
          adminId: admin.id!,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment approved! Ticket ${ticket.ticketCode} issued.',
            ),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
        _loadPendingPayments();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error approving payment: $e'),
            backgroundColor: const Color(0xFFC62828),
          ),
        );
      }
    }
  }

  Future<void> _handleReject(PaymentModel payment) async {
    final admin = AuthService.instance.currentUser;
    if (admin == null || admin.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Payment?'),
        content: Text(
          'Are you sure you want to reject the payment reference "${payment.transactionReference}" for ${payment.studentName ?? "Student"}?\n\nNo ticket will be generated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Reject Payment',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await PaymentService.instance.rejectPayment(
          registrationId: payment.registrationId,
          adminId: admin.id!,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment rejected.'),
            backgroundColor: Color(0xFFC62828),
          ),
        );
        _loadPendingPayments();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rejecting payment: $e'),
            backgroundColor: const Color(0xFFC62828),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Pending Payments'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingPayments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green.shade400,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'All caught up!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No pending payments waiting for verification.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPendingPayments,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _pendingPayments.length,
                itemBuilder: (context, index) {
                  final p = _pendingPayments[index];

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.orange.shade200,
                        width: 1.2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top status and amount
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 14,
                                      color: Color(0xFFEF6C00),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'PENDING VERIFICATION',
                                      style: TextStyle(
                                        color: Color(0xFFEF6C00),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'PKR ${p.amount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D47A1),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Student Info
                          Text(
                            p.studentName ?? 'Student',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Roll No: ${p.studentRollNumber ?? "N/A"}  •  ${p.studentEmail ?? ""}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1),
                          const SizedBox(height: 10),

                          // Event Info
                          Row(
                            children: [
                              const Icon(
                                Icons.event_note,
                                size: 16,
                                color: Color(0xFF0D47A1),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  p.eventTitle ?? 'Event',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A237E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Transaction Details
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Method: ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    Text(
                                      p.paymentMethod,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Transaction / Ref ID: ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    SelectableText(
                                      p.transactionReference,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0D47A1),
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Approve / Reject Actions
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Color(0xFFC62828),
                                  ),
                                  label: const Text(
                                    'Reject',
                                    style: TextStyle(color: Color(0xFFC62828)),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFFC62828),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () => _handleReject(p),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.check,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Approve',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E7D32),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () => _handleApprove(p),
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
            ),
    );
  }
}
