import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/ticket_model.dart';

class TicketVerificationResult {
  final bool isValid;
  final String message;
  final TicketModel? ticket;

  TicketVerificationResult({
    required this.isValid,
    required this.message,
    this.ticket,
  });
}

class TicketService {
  TicketService._internal();
  static final TicketService instance = TicketService._internal();

  /// Get student's tickets with event and student details
  Future<List<TicketModel>> getStudentTickets(int studentId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery(
      '''
      SELECT 
        t.id,
        t.registration_id,
        t.ticket_code,
        t.verification_token,
        t.ticket_status,
        t.issued_at,
        t.used_at,
        t.verified_by,
        u.name AS student_name,
        u.roll_number AS student_roll_number,
        u.email AS student_email,
        e.id AS event_id,
        e.title AS event_title,
        e.event_date,
        e.event_time,
        e.venue AS event_venue,
        g.name AS guard_name
      FROM tickets t
      JOIN registrations r ON t.registration_id = r.id
      JOIN users u ON r.student_id = u.id
      JOIN events e ON r.event_id = e.id
      LEFT JOIN users g ON t.verified_by = g.id
      WHERE r.student_id = ?
      ORDER BY t.issued_at DESC
    ''',
      [studentId],
    );

    return results.map((m) => TicketModel.fromMap(m)).toList();
  }

  /// Get ticket by registration ID
  Future<TicketModel?> getTicketByRegistrationId(int registrationId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery(
      '''
      SELECT 
        t.id,
        t.registration_id,
        t.ticket_code,
        t.verification_token,
        t.ticket_status,
        t.issued_at,
        t.used_at,
        t.verified_by,
        u.name AS student_name,
        u.roll_number AS student_roll_number,
        u.email AS student_email,
        e.id AS event_id,
        e.title AS event_title,
        e.event_date,
        e.event_time,
        e.venue AS event_venue,
        g.name AS guard_name
      FROM tickets t
      JOIN registrations r ON t.registration_id = r.id
      JOIN users u ON r.student_id = u.id
      JOIN events e ON r.event_id = e.id
      LEFT JOIN users g ON t.verified_by = g.id
      WHERE t.registration_id = ?
      LIMIT 1
    ''',
      [registrationId],
    );

    if (results.isEmpty) return null;
    return TicketModel.fromMap(results.first);
  }

  /// Find ticket by verification token (scanned from QR code)
  Future<TicketModel?> getTicketByVerificationToken(String token) async {
    final db = await DatabaseHelper.instance.database;
    final cleanToken = token.trim();
    final results = await db.rawQuery(
      '''
      SELECT 
        t.id,
        t.registration_id,
        t.ticket_code,
        t.verification_token,
        t.ticket_status,
        t.issued_at,
        t.used_at,
        t.verified_by,
        u.name AS student_name,
        u.roll_number AS student_roll_number,
        u.email AS student_email,
        e.id AS event_id,
        e.title AS event_title,
        e.event_date,
        e.event_time,
        e.venue AS event_venue,
        g.name AS guard_name
      FROM tickets t
      JOIN registrations r ON t.registration_id = r.id
      JOIN users u ON r.student_id = u.id
      JOIN events e ON r.event_id = e.id
      LEFT JOIN users g ON t.verified_by = g.id
      WHERE t.verification_token = ?
      LIMIT 1
    ''',
      [cleanToken],
    );

    if (results.isEmpty) return null;
    return TicketModel.fromMap(results.first);
  }

  /// Find ticket by student roll number and event ID (Method B: Roll Number check)
  Future<TicketModel?> getTicketByRollNumberAndEvent(
    String rollNumber,
    int eventId,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final cleanRoll = rollNumber.trim().toUpperCase();

    final results = await db.rawQuery(
      '''
      SELECT 
        t.id,
        t.registration_id,
        t.ticket_code,
        t.verification_token,
        t.ticket_status,
        t.issued_at,
        t.used_at,
        t.verified_by,
        u.name AS student_name,
        u.roll_number AS student_roll_number,
        u.email AS student_email,
        e.id AS event_id,
        e.title AS event_title,
        e.event_date,
        e.event_time,
        e.venue AS event_venue,
        g.name AS guard_name
      FROM tickets t
      JOIN registrations r ON t.registration_id = r.id
      JOIN users u ON r.student_id = u.id
      JOIN events e ON r.event_id = e.id
      LEFT JOIN users g ON t.verified_by = g.id
      WHERE UPPER(u.roll_number) = ? AND e.id = ?
      ORDER BY
        CASE t.ticket_status
          WHEN 'Valid' THEN 0
          WHEN 'Used' THEN 1
          ELSE 2
        END,
        t.issued_at DESC,
        t.id DESC
      LIMIT 1
    ''',
      [cleanRoll, eventId],
    );

    if (results.isEmpty) return null;
    return TicketModel.fromMap(results.first);
  }

  /// Verify Ticket for guard checks against validation rules
  Future<TicketVerificationResult> verifyTicketToken({
    required String token,
    required int expectedEventId,
  }) async {
    final ticket = await getTicketByVerificationToken(token);

    if (ticket == null) {
      return TicketVerificationResult(
        isValid: false,
        message: 'Invalid QR Code: No matching ticket found in system.',
      );
    }

    return _validateTicketRules(ticket, expectedEventId);
  }

  /// Verify Ticket by Roll Number for guard check
  Future<TicketVerificationResult> verifyTicketRollNumber({
    required String rollNumber,
    required int expectedEventId,
  }) async {
    final ticket = await getTicketByRollNumberAndEvent(
      rollNumber,
      expectedEventId,
    );

    if (ticket == null) {
      return TicketVerificationResult(
        isValid: false,
        message:
            'No approved ticket found for Roll Number "$rollNumber" in this event.',
      );
    }

    return _validateTicketRules(ticket, expectedEventId);
  }

  /// Internal rule validation
  TicketVerificationResult _validateTicketRules(
    TicketModel ticket,
    int expectedEventId,
  ) {
    if (ticket.eventId != expectedEventId) {
      return TicketVerificationResult(
        isValid: false,
        message:
            'Ticket belongs to a different event: "${ticket.eventTitle ?? 'Another Event'}".',
        ticket: ticket,
      );
    }

    if (ticket.ticketStatus == 'Used') {
      return TicketVerificationResult(
        isValid: false,
        message:
            'Ticket has already been used on ${ticket.usedAt ?? 'earlier'}. Double entry denied.',
        ticket: ticket,
      );
    }

    if (ticket.ticketStatus == 'Cancelled') {
      return TicketVerificationResult(
        isValid: false,
        message: 'This ticket has been cancelled. Entry denied.',
        ticket: ticket,
      );
    }

    if (ticket.ticketStatus != 'Valid') {
      return TicketVerificationResult(
        isValid: false,
        message: 'Ticket status is "${ticket.ticketStatus}". Entry denied.',
        ticket: ticket,
      );
    }

    return TicketVerificationResult(
      isValid: true,
      message: 'Ticket is valid! Verified and approved for entry.',
      ticket: ticket,
    );
  }

  /// Confirm entry: Atomic transaction marking ticket as Used
  Future<TicketModel> confirmEntry({
    required int ticketId,
    required int guardId,
    required int expectedEventId,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    return await db.transaction<TicketModel>((txn) async {
      // 1. Fetch current ticket inside transaction to prevent double entry race conditions
      final results = await txn.rawQuery(
        '''
        SELECT 
          t.id,
          t.registration_id,
          t.ticket_code,
          t.verification_token,
          t.ticket_status,
          t.issued_at,
          t.used_at,
          t.verified_by,
          u.name AS student_name,
          u.roll_number AS student_roll_number,
          u.email AS student_email,
          e.id AS event_id,
          e.title AS event_title,
          e.event_date,
          e.event_time,
          e.venue AS event_venue,
          g.name AS guard_name
        FROM tickets t
        JOIN registrations r ON t.registration_id = r.id
        JOIN users u ON r.student_id = u.id
        JOIN events e ON r.event_id = e.id
        LEFT JOIN users g ON t.verified_by = g.id
        WHERE t.id = ?
        LIMIT 1
      ''',
        [ticketId],
      );

      if (results.isEmpty) {
        throw Exception('Ticket not found.');
      }

      final ticket = TicketModel.fromMap(results.first);

      if (ticket.eventId != expectedEventId) {
        throw Exception('Ticket does not belong to this event.');
      }

      if (ticket.ticketStatus == 'Used') {
        throw Exception('Ticket has already been used on ${ticket.usedAt}.');
      }

      if (ticket.ticketStatus != 'Valid') {
        throw Exception(
          'Ticket is not valid (status: ${ticket.ticketStatus}).',
        );
      }

      // 2. Mark ticket as Used atomically
      await txn.update(
        'tickets',
        {'ticket_status': 'Used', 'used_at': now, 'verified_by': guardId},
        where: 'id = ?',
        whereArgs: [ticketId],
      );

      return ticket.copyWith(
        ticketStatus: 'Used',
        usedAt: now,
        verifiedBy: guardId,
      );
    });
  }

  /// Get entry history / attendance records for an event
  Future<List<TicketModel>> getEventEntryHistory(int eventId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery(
      '''
      SELECT 
        t.id,
        t.registration_id,
        t.ticket_code,
        t.verification_token,
        t.ticket_status,
        t.issued_at,
        t.used_at,
        t.verified_by,
        u.name AS student_name,
        u.roll_number AS student_roll_number,
        u.email AS student_email,
        e.id AS event_id,
        e.title AS event_title,
        e.event_date,
        e.event_time,
        e.venue AS event_venue,
        g.name AS guard_name
      FROM tickets t
      JOIN registrations r ON t.registration_id = r.id
      JOIN users u ON r.student_id = u.id
      JOIN events e ON r.event_id = e.id
      LEFT JOIN users g ON t.verified_by = g.id
      WHERE e.id = ? AND t.ticket_status = 'Used'
      ORDER BY t.used_at DESC
    ''',
      [eventId],
    );

    return results.map((m) => TicketModel.fromMap(m)).toList();
  }

  /// Get all approved tickets for admin attendance view
  Future<List<TicketModel>> getAllTickets() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery('''
      SELECT 
        t.id,
        t.registration_id,
        t.ticket_code,
        t.verification_token,
        t.ticket_status,
        t.issued_at,
        t.used_at,
        t.verified_by,
        u.name AS student_name,
        u.roll_number AS student_roll_number,
        u.email AS student_email,
        e.id AS event_id,
        e.title AS event_title,
        e.event_date,
        e.event_time,
        e.venue AS event_venue,
        g.name AS guard_name
      FROM tickets t
      JOIN registrations r ON t.registration_id = r.id
      JOIN users u ON r.student_id = u.id
      JOIN events e ON r.event_id = e.id
      LEFT JOIN users g ON t.verified_by = g.id
      ORDER BY t.issued_at DESC
    ''');

    return results.map((m) => TicketModel.fromMap(m)).toList();
  }
}
