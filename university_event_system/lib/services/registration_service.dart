import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/registration_model.dart';
import 'event_service.dart';

class RegistrationService {
  RegistrationService._internal();
  static final RegistrationService instance = RegistrationService._internal();

  /// Register student for event with manual payment submission (Atomic Transaction)
  Future<int> registerForEvent({
    required int studentId,
    required int eventId,
    required String paymentMethod,
    required String transactionReference,
    required double amount,
  }) async {
    final db = await DatabaseHelper.instance.database;

    // 1. Check for existing active registration (Pending or Approved)
    final existing = await db.query(
      'registrations',
      where: 'student_id = ? AND event_id = ? AND status IN (?, ?)',
      whereArgs: [studentId, eventId, 'Pending', 'Approved'],
    );
    if (existing.isNotEmpty) {
      final currentStatus = existing.first['status'] as String;
      if (currentStatus == 'Approved') {
        throw Exception(
          'You are already registered and approved for this event.',
        );
      } else {
        throw Exception(
          'You already have a pending registration for this event.',
        );
      }
    }

    // 2. Check event capacity
    final remainingSeats = await EventService.instance.getRemainingCapacity(
      eventId,
    );
    if (remainingSeats <= 0) {
      throw Exception('Sorry, this event is already fully booked.');
    }

    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // 3. Perform atomic registration & payment submission
    return await db.transaction<int>((txn) async {
      final registrationId = await txn.insert('registrations', {
        'student_id': studentId,
        'event_id': eventId,
        'status': 'Pending',
        'registration_date': now,
      });

      await txn.insert('payments', {
        'registration_id': registrationId,
        'amount': amount,
        'payment_method': paymentMethod.trim(),
        'transaction_reference': transactionReference.trim(),
        'payment_status': 'Pending',
        'verified_by': null,
        'verified_at': null,
      });

      return registrationId;
    });
  }

  /// Get registrations for a specific student with joined event, payment, and ticket info
  Future<List<RegistrationModel>> getStudentRegistrations(int studentId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery(
      '''
      SELECT 
        r.id,
        r.student_id,
        r.event_id,
        r.status,
        r.registration_date,
        u.name AS student_name,
        u.roll_number AS student_roll_number,
        u.email AS student_email,
        e.title AS event_title,
        e.venue AS event_venue,
        e.event_date,
        e.event_time,
        e.ticket_price,
        p.payment_status,
        p.payment_method,
        p.transaction_reference,
        t.ticket_code
      FROM registrations r
      JOIN users u ON r.student_id = u.id
      JOIN events e ON r.event_id = e.id
      LEFT JOIN payments p ON p.registration_id = r.id
      LEFT JOIN tickets t ON t.registration_id = r.id
      WHERE r.student_id = ?
      ORDER BY r.registration_date DESC
    ''',
      [studentId],
    );

    return results.map((m) => RegistrationModel.fromMap(m)).toList();
  }

  /// Get all registrations for admin
  Future<List<RegistrationModel>> getAllRegistrations() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery('''
      SELECT 
        r.id,
        r.student_id,
        r.event_id,
        r.status,
        r.registration_date,
        u.name AS student_name,
        u.roll_number AS student_roll_number,
        u.email AS student_email,
        e.title AS event_title,
        e.venue AS event_venue,
        e.event_date,
        e.event_time,
        e.ticket_price,
        p.payment_status,
        p.payment_method,
        p.transaction_reference,
        t.ticket_code
      FROM registrations r
      JOIN users u ON r.student_id = u.id
      JOIN events e ON r.event_id = e.id
      LEFT JOIN payments p ON p.registration_id = r.id
      LEFT JOIN tickets t ON t.registration_id = r.id
      ORDER BY r.registration_date DESC
    ''');

    return results.map((m) => RegistrationModel.fromMap(m)).toList();
  }

  /// Get single registration by ID
  Future<RegistrationModel?> getRegistrationById(int registrationId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery(
      '''
      SELECT 
        r.id,
        r.student_id,
        r.event_id,
        r.status,
        r.registration_date,
        u.name AS student_name,
        u.roll_number AS student_roll_number,
        u.email AS student_email,
        e.title AS event_title,
        e.venue AS event_venue,
        e.event_date,
        e.event_time,
        e.ticket_price,
        p.payment_status,
        p.payment_method,
        p.transaction_reference,
        t.ticket_code
      FROM registrations r
      JOIN users u ON r.student_id = u.id
      JOIN events e ON r.event_id = e.id
      LEFT JOIN payments p ON p.registration_id = r.id
      LEFT JOIN tickets t ON t.registration_id = r.id
      WHERE r.id = ?
      LIMIT 1
    ''',
      [registrationId],
    );

    if (results.isEmpty) return null;
    return RegistrationModel.fromMap(results.first);
  }

  /// Get registrations for a specific event
  Future<List<RegistrationModel>> getRegistrationsByEvent(int eventId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery(
      '''
      SELECT 
        r.id,
        r.student_id,
        r.event_id,
        r.status,
        r.registration_date,
        u.name AS student_name,
        u.roll_number AS student_roll_number,
        u.email AS student_email,
        e.title AS event_title,
        e.venue AS event_venue,
        e.event_date,
        e.event_time,
        e.ticket_price,
        p.payment_status,
        p.payment_method,
        p.transaction_reference,
        t.ticket_code
      FROM registrations r
      JOIN users u ON r.student_id = u.id
      JOIN events e ON r.event_id = e.id
      LEFT JOIN payments p ON p.registration_id = r.id
      LEFT JOIN tickets t ON t.registration_id = r.id
      WHERE r.event_id = ?
      ORDER BY r.registration_date DESC
    ''',
      [eventId],
    );

    return results.map((m) => RegistrationModel.fromMap(m)).toList();
  }
}
