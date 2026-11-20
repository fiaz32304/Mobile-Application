class TicketModel {
  final int? id;
  final int registrationId;
  final String ticketCode;
  final String verificationToken;
  final String ticketStatus; // 'Valid', 'Used', 'Cancelled'
  final String issuedAt;
  final String? usedAt;
  final int? verifiedBy;

  // Joined display attributes
  final String? studentName;
  final String? studentRollNumber;
  final String? studentEmail;
  final int? eventId;
  final String? eventTitle;
  final String? eventDate;
  final String? eventTime;
  final String? eventVenue;
  final String? guardName;

  TicketModel({
    this.id,
    required this.registrationId,
    required this.ticketCode,
    required this.verificationToken,
    required this.ticketStatus,
    required this.issuedAt,
    this.usedAt,
    this.verifiedBy,
    this.studentName,
    this.studentRollNumber,
    this.studentEmail,
    this.eventId,
    this.eventTitle,
    this.eventDate,
    this.eventTime,
    this.eventVenue,
    this.guardName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'registration_id': registrationId,
      'ticket_code': ticketCode,
      'verification_token': verificationToken,
      'ticket_status': ticketStatus,
      'issued_at': issuedAt,
      'used_at': usedAt,
      'verified_by': verifiedBy,
    };
  }

  factory TicketModel.fromMap(Map<String, dynamic> map) {
    return TicketModel(
      id: map['id'] as int?,
      registrationId: map['registration_id'] as int,
      ticketCode: map['ticket_code'] as String,
      verificationToken: map['verification_token'] as String,
      ticketStatus: map['ticket_status'] as String,
      issuedAt: map['issued_at'] as String,
      usedAt: map['used_at'] as String?,
      verifiedBy: map['verified_by'] as int?,
      studentName: map['student_name'] as String?,
      studentRollNumber: map['student_roll_number'] as String?,
      studentEmail: map['student_email'] as String?,
      eventId: map['event_id'] as int?,
      eventTitle: map['event_title'] as String?,
      eventDate: map['event_date'] as String?,
      eventTime: map['event_time'] as String?,
      eventVenue: map['event_venue'] as String?,
      guardName: map['guard_name'] as String?,
    );
  }

  TicketModel copyWith({
    int? id,
    int? registrationId,
    String? ticketCode,
    String? verificationToken,
    String? ticketStatus,
    String? issuedAt,
    String? usedAt,
    int? verifiedBy,
    String? studentName,
    String? studentRollNumber,
    String? studentEmail,
    int? eventId,
    String? eventTitle,
    String? eventDate,
    String? eventTime,
    String? eventVenue,
    String? guardName,
  }) {
    return TicketModel(
      id: id ?? this.id,
      registrationId: registrationId ?? this.registrationId,
      ticketCode: ticketCode ?? this.ticketCode,
      verificationToken: verificationToken ?? this.verificationToken,
      ticketStatus: ticketStatus ?? this.ticketStatus,
      issuedAt: issuedAt ?? this.issuedAt,
      usedAt: usedAt ?? this.usedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      studentName: studentName ?? this.studentName,
      studentRollNumber: studentRollNumber ?? this.studentRollNumber,
      studentEmail: studentEmail ?? this.studentEmail,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      eventVenue: eventVenue ?? this.eventVenue,
      guardName: guardName ?? this.guardName,
    );
  }
}
