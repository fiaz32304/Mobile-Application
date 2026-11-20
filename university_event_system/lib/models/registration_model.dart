class RegistrationModel {
  final int? id;
  final int studentId;
  final int eventId;
  final String status; // 'Pending', 'Approved', 'Rejected', 'Cancelled'
  final String registrationDate;

  // Joined display attributes (from users, events, payments)
  final String? studentName;
  final String? studentRollNumber;
  final String? studentEmail;
  final String? eventTitle;
  final String? eventVenue;
  final String? eventDate;
  final String? eventTime;
  final double? ticketPrice;
  final String? paymentStatus;
  final String? paymentMethod;
  final String? transactionReference;
  final String? ticketCode;

  RegistrationModel({
    this.id,
    required this.studentId,
    required this.eventId,
    required this.status,
    required this.registrationDate,
    this.studentName,
    this.studentRollNumber,
    this.studentEmail,
    this.eventTitle,
    this.eventVenue,
    this.eventDate,
    this.eventTime,
    this.ticketPrice,
    this.paymentStatus,
    this.paymentMethod,
    this.transactionReference,
    this.ticketCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'event_id': eventId,
      'status': status,
      'registration_date': registrationDate,
    };
  }

  factory RegistrationModel.fromMap(Map<String, dynamic> map) {
    return RegistrationModel(
      id: map['id'] as int?,
      studentId: map['student_id'] as int,
      eventId: map['event_id'] as int,
      status: map['status'] as String,
      registrationDate: map['registration_date'] as String,
      studentName: map['student_name'] as String?,
      studentRollNumber: map['student_roll_number'] as String?,
      studentEmail: map['student_email'] as String?,
      eventTitle: map['event_title'] as String?,
      eventVenue: map['event_venue'] as String?,
      eventDate: map['event_date'] as String?,
      eventTime: map['event_time'] as String?,
      ticketPrice: map['ticket_price'] != null
          ? (map['ticket_price'] is int
                ? (map['ticket_price'] as int).toDouble()
                : (map['ticket_price'] as num).toDouble())
          : null,
      paymentStatus: map['payment_status'] as String?,
      paymentMethod: map['payment_method'] as String?,
      transactionReference: map['transaction_reference'] as String?,
      ticketCode: map['ticket_code'] as String?,
    );
  }

  RegistrationModel copyWith({
    int? id,
    int? studentId,
    int? eventId,
    String? status,
    String? registrationDate,
    String? studentName,
    String? studentRollNumber,
    String? studentEmail,
    String? eventTitle,
    String? eventVenue,
    String? eventDate,
    String? eventTime,
    double? ticketPrice,
    String? paymentStatus,
    String? paymentMethod,
    String? transactionReference,
    String? ticketCode,
  }) {
    return RegistrationModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      eventId: eventId ?? this.eventId,
      status: status ?? this.status,
      registrationDate: registrationDate ?? this.registrationDate,
      studentName: studentName ?? this.studentName,
      studentRollNumber: studentRollNumber ?? this.studentRollNumber,
      studentEmail: studentEmail ?? this.studentEmail,
      eventTitle: eventTitle ?? this.eventTitle,
      eventVenue: eventVenue ?? this.eventVenue,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionReference: transactionReference ?? this.transactionReference,
      ticketCode: ticketCode ?? this.ticketCode,
    );
  }
}
