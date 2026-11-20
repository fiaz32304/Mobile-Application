class PaymentModel {
  final int? id;
  final int registrationId;
  final double amount;
  final String paymentMethod;
  final String transactionReference;
  final String paymentStatus; // 'Pending', 'Verified', 'Rejected'
  final int? verifiedBy;
  final String? verifiedAt;

  // Joined display attributes
  final String? studentName;
  final String? studentRollNumber;
  final String? studentEmail;
  final String? eventTitle;
  final String? eventDate;
  final String? eventVenue;

  PaymentModel({
    this.id,
    required this.registrationId,
    required this.amount,
    required this.paymentMethod,
    required this.transactionReference,
    required this.paymentStatus,
    this.verifiedBy,
    this.verifiedAt,
    this.studentName,
    this.studentRollNumber,
    this.studentEmail,
    this.eventTitle,
    this.eventDate,
    this.eventVenue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'registration_id': registrationId,
      'amount': amount,
      'payment_method': paymentMethod,
      'transaction_reference': transactionReference,
      'payment_status': paymentStatus,
      'verified_by': verifiedBy,
      'verified_at': verifiedAt,
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] as int?,
      registrationId: map['registration_id'] as int,
      amount: (map['amount'] is int)
          ? (map['amount'] as int).toDouble()
          : (map['amount'] as num).toDouble(),
      paymentMethod: map['payment_method'] as String,
      transactionReference: map['transaction_reference'] as String,
      paymentStatus: map['payment_status'] as String,
      verifiedBy: map['verified_by'] as int?,
      verifiedAt: map['verified_at'] as String?,
      studentName: map['student_name'] as String?,
      studentRollNumber: map['student_roll_number'] as String?,
      studentEmail: map['student_email'] as String?,
      eventTitle: map['event_title'] as String?,
      eventDate: map['event_date'] as String?,
      eventVenue: map['event_venue'] as String?,
    );
  }

  PaymentModel copyWith({
    int? id,
    int? registrationId,
    double? amount,
    String? paymentMethod,
    String? transactionReference,
    String? paymentStatus,
    int? verifiedBy,
    String? verifiedAt,
    String? studentName,
    String? studentRollNumber,
    String? studentEmail,
    String? eventTitle,
    String? eventDate,
    String? eventVenue,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      registrationId: registrationId ?? this.registrationId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionReference: transactionReference ?? this.transactionReference,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      studentName: studentName ?? this.studentName,
      studentRollNumber: studentRollNumber ?? this.studentRollNumber,
      studentEmail: studentEmail ?? this.studentEmail,
      eventTitle: eventTitle ?? this.eventTitle,
      eventDate: eventDate ?? this.eventDate,
      eventVenue: eventVenue ?? this.eventVenue,
    );
  }
}
