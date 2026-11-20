import 'package:flutter/material.dart';

import '../../models/event_model.dart';
import '../../services/auth_service.dart';
import '../../services/registration_service.dart';
import '../../widgets/custom_button.dart';

class PaymentSubmissionScreen extends StatefulWidget {
  final EventModel event;

  const PaymentSubmissionScreen({super.key, required this.event});

  @override
  State<PaymentSubmissionScreen> createState() =>
      _PaymentSubmissionScreenState();
}

class _PaymentSubmissionScreenState extends State<PaymentSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _refController = TextEditingController();

  String _paymentMethod = 'JazzCash';
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _methods = [
    'JazzCash',
    'EasyPaisa',
    'Bank Transfer',
    'Campus Cash Desk',
  ];

  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final student = AuthService.instance.currentUser;
    if (student == null || student.id == null || widget.event.id == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await RegistrationService.instance.registerForEvent(
        studentId: student.id!,
        eventId: widget.event.id!,
        paymentMethod: _paymentMethod,
        transactionReference: _refController.text.trim(),
        amount: widget.event.ticketPrice,
      );

      if (!mounted) return;

      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF2E7D32),
            size: 48,
          ),
          title: const Text('Payment Submitted!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your event registration has been submitted and is currently PENDING admin approval.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Method: $_paymentMethod',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Transaction Ref: ${_refController.text.trim()}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'Status: Pending Admin Verification',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your ticket with a secure QR code will be generated automatically once the administrator verifies your payment.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
              ),
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context, true); // Pop submission screen
              },
              child: const Text(
                'OK, Got It',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Submit Payment Details'),
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
              // Amount banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payable Amount',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.event.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'PKR ${widget.event.ticketPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Payment Method Dropdown
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: InputDecoration(
                  labelText: 'Payment Method Used',
                  prefixIcon: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Color(0xFF0D47A1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: _methods.map((m) {
                  return DropdownMenuItem(value: m, child: Text(m));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _paymentMethod = val);
                },
              ),
              const SizedBox(height: 16),

              // Transaction Reference ID
              TextFormField(
                controller: _refController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Transaction ID / Reference Number',
                  hintText: 'e.g. TXN1029384756 or Cash Slip #',
                  prefixIcon: const Icon(
                    Icons.receipt_outlined,
                    color: Color(0xFF0D47A1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  helperText:
                      'Admin checks this reference against received funds.',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter the transaction reference / TID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              CustomButton(
                text: 'Submit for Admin Verification',
                isLoading: _isLoading,
                icon: Icons.send_outlined,
                onPressed: _submitPayment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
