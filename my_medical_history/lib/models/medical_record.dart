
class MedicalRecord {
  final String title;
  final String doctor;
  final String date;
  final String diagnosis;
  final String medicine;
  final String hospital;

  MedicalRecord({
    required this.title,
    required this.doctor,
    required this.date,
    required this.diagnosis,
    required this.medicine,
    required this.hospital,
  });
}

class MedicalData {
  static final List<MedicalRecord> records = [
    MedicalRecord(
      title: 'General Checkup',
      doctor: 'Dr. Sarah Ahmed',
      date: '2026-09-15',
      diagnosis: 'Routine health checkup',
      medicine: 'Vitamin D',
      hospital: 'City Medical Center',
    ),
    MedicalRecord(
      title: 'Dental Examination',
      doctor: 'Dr. Ali Khan',
      date: '2026-08-20',
      diagnosis: 'Dental cleaning',
      medicine: 'None',
      hospital: 'Smile Dental Clinic',
    ),
  ];
}
