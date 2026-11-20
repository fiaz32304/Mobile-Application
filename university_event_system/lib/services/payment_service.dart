import 'dart:math';

import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/payment_model.dart';
import '../models/ticket_model.dart';

class PaymentService {
  PaymentService._internal();
  static final PaymentService instance = PaymentService._internal();

  /// Retrieve all pending payments for Admin verification
  Future<List<PaymentModel>> getPendingPayments() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery(
      '''
      SELECT 
        p.id,
        p.registration_id,
        p.amount,
        p.payment_method,
        p.transaction_reference,
        p.payment_status,
        p.verified_by,
        p.verified_at,
        u.name AS student_name,
        u.roll_number AS student_roll_number,
        u.email AS student_email,
        e.title AS event_title,
        e.event_date,
        e.venue AS event_venue
      FROM payments p
      JOIN registrations r ON p.registration_id = r.id
      JOIN users u ON r.student_id = u.id
      JOIN events e ON r.event_id = e.id
      WHERE p.payment_status = ?
      ORDER BY r.registration_date ASC
    ''',
      ['Pending'],
    );

    return results.map((m) => PaymentModel.fromMap(m)).toList();
  }

  /// Retrieve all payments (all statuses)
  Future<List<PaymentModel>> getAllPayments() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery('''
      SELECT 
        p.id,
        p.registration_id,
        p.amount,
        p.payment_method,
        p.transaction_reference,
        p.payment_status,
        p.verified_by,
        p.verified_at,
        u.name AS student_name,
        u.roll_number AS student_roll_number,
        u.email AS student_email,
        e.title AS event_title,
        e.event_date,
        e.venue AS event_venue
      FROM payments p
      JOIN registrations r ON p.registration_id = r.id
      JOIN users u ON r.student_id = u.id
      JOIN events e ON r.event_id = e.id
      ORDER BY p.id DESC
    ''');

    return results.map((m) => PaymentModel.fromMap(m)).toList();
  }

  /// Approve payment and generate ticket atomically (Admin only)
  Future<TicketModel> approvePayment({
    required int registrationId,
    required int adminId,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    return await db.transaction<TicketModel>((txn) async {
      // 1. Verify registration and payment exist
      final paymentRows = await txn.query(
        'payments',
        where: 'registration_id = ?',
        whereArgs: [registrationId],
        limit: 1,
      );
      if (paymentRows.isEmpty) {
        throw Exception('Payment record not found for this registration.');
      }

      // 2. Update payment status to Verified
      await txn.update(
        'payments',
        {
          'payment_status': 'Verified',
          'verified_by': adminId,
          'verified_at': now,
        },
        where: 'registration_id = ?',
        whereArgs: [registrationId],
      );

      // 3. Update registration status to Approved
      await txn.update(
        'registrations',
        {'status': 'Approved'},
        where: 'id = ?',
        whereArgs: [registrationId],
      );

      // 4. Generate unique Ticket Code and unpredictable Verification Token
      final ticketCode = 'EVT-${registrationId.toString().padLeft(6, '0')}';
      final random = Random.secure();
      final randomHex = List.generate(
        8,
        (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join().toUpperCase();
      final verificationToken = 'UET-VERIFY-$randomHex-$registrationId';

      // Check if ticket already exists (idempotency)
      final existingTicket = await txn.query(
        'tickets',
        where: 'registration_id = ?',
        whereArgs: [registrationId],
      );

      int ticketId;
      if (existingTicket.isEmpty) {
        ticketId = await txn.insert('tickets', {
          'registration_id': registrationId,
          'ticket_code': ticketCode,
          'verification_token': verificationToken,
          'ticket_status': 'Valid',
          'issued_at': now,
          'used_at': null,
          'verified_by': null,
        });
      } else {
        ticketId = existingTicket.first['id'] as int;
        await txn.update(
          'tickets',
          {'ticket_status': 'Valid', 'issued_at': now},
          where: 'id = ?',
          whereArgs: [ticketId],
        );
      }

      return TicketModel(
        id: ticketId,
        registrationId: registrationId,
        ticketCode: ticketCode,
        verificationToken: verificationToken,
        ticketStatus: 'Valid',
        issuedAt: now,
      );
    });
  }

  /// Reject payment (Admin only)
  Future<void> rejectPayment({
    required int registrationId,
    required int adminId,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    await db.transaction((txn) async {
      await txn.update(
        'payments',
        {
          'payment_status': 'Rejected',
          'verified_by': adminId,
          'verified_at': now,
        },
        where: 'registration_id = ?',
        whereArgs: [registrationId],
      );

      await txn.update(
        'registrations',
        {'status': 'Rejected'},
        where: 'id = ?',
        whereArgs: [registrationId],
      );

      // Cancel ticket if one exists
      await txn.update(
        'tickets',
        {'ticket_status': 'Cancelled'},
        where: 'registration_id = ?',
        whereArgs: [registrationId],
      );
    });
  }
}
