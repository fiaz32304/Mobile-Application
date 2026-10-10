
import 'package:flutter/material.dart';
import '../models/medical_record.dart';

class AddVisitScreen extends StatefulWidget {
  const AddVisitScreen({super.key});

  @override
  State<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final doctorController = TextEditingController();
  final hospitalController = TextEditingController();
  final diagnosisController = TextEditingController();
  final medicineController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    titleController.dispose();
    doctorController.dispose();
    hospitalController.dispose();
    diagnosisController.dispose();
    medicineController.dispose();
    super.dispose();
  }

  String get formattedDate {
    return '${selectedDate.year}-'
        '${selectedDate.month.toString().padLeft(2, '0')}-'
        '${selectedDate.day.toString().padLeft(2, '0')}';
  }

  Future<void> chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Widget field(
      String label,
      TextEditingController controller, {
        bool requiredField = true,
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        validator: (value) {
          if (requiredField && (value == null || value.trim().isEmpty)) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  void saveVisit() {
    if (!formKey.currentState!.validate()) return;

    MedicalData.records.add(
      MedicalRecord(
        title: titleController.text.trim(),
        doctor: doctorController.text.trim(),
        date: formattedDate,
        diagnosis: diagnosisController.text.trim(),
        medicine: medicineController.text.trim(),
        hospital: hospitalController.text.trim(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medical visit saved successfully'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medical Visit')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Visit Information',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            field('Visit Title', titleController),
            field('Doctor Name', doctorController),
            field('Hospital / Clinic', hospitalController),

            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Visit Date'),
                subtitle: Text(formattedDate),
                trailing: const Icon(Icons.edit_calendar),
                onTap: chooseDate,
              ),
            ),

            const SizedBox(height: 16),
            field(
              'Diagnosis',
              diagnosisController,
              maxLines: 3,
            ),
            field(
              'Medicines / Prescription',
              medicineController,
              requiredField: false,
              maxLines: 3,
            ),

            const SizedBox(height: 20),
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: saveVisit,
                icon: const Icon(Icons.save),
                label: const Text('Save Medical Visit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1677D2),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
