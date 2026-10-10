
import 'package:flutter/material.dart';
import '../models/medical_record.dart';

class DoctorProfileScreen extends StatelessWidget {
  final String name;
  final String specialty;
  final String hospital;

  const DoctorProfileScreen({
    super.key,
    required this.name,
    required this.specialty,
    required this.hospital,
  });

  @override
  Widget build(BuildContext context) {
    final visits = MedicalData.records
        .where((record) => record.doctor == name)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 55,
              backgroundColor: Color(0xFFDDEEFF),
              child: Icon(
                Icons.person,
                size: 65,
                color: Color(0xFF1677D2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: Text(
              specialty,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.local_hospital),
                    title: const Text('Hospital / Clinic'),
                    subtitle: Text(hospital),
                  ),
                  const ListTile(
                    leading: Icon(Icons.verified_user),
                    title: Text('Medical Professional'),
                    subtitle: Text('Sample doctor profile'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Visit History',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (visits.isEmpty)
            const Text('No previous visits recorded.'),
          ...visits.map(
                (visit) => Card(
              child: ListTile(
                leading: const Icon(Icons.history),
                title: Text(visit.title),
                subtitle: Text(
                  '${visit.date}\n${visit.diagnosis}',
                ),
                isThreeLine: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
