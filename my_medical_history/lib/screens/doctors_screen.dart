
import 'package:flutter/material.dart';
import 'doctor_profile_screen.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  String search = '';

  final doctors = [
    {
      'name': 'Dr. Sarah Ahmed',
      'specialty': 'General Physician',
      'hospital': 'City Medical Center',
    },
    {
      'name': 'Dr. Ali Khan',
      'specialty': 'Dentist',
      'hospital': 'Smile Dental Clinic',
    },
    {
      'name': 'Dr. Ayesha Malik',
      'specialty': 'Cardiologist',
      'hospital': 'Heart Care Hospital',
    },
    {
      'name': 'Dr. Omar Hassan',
      'specialty': 'Dermatologist',
      'hospital': 'Skin Care Clinic',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = doctors.where((doctor) {
      return doctor['name']!.toLowerCase().contains(search) ||
          doctor['specialty']!.toLowerCase().contains(search);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Doctors')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search doctors',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onChanged: (value) {
                setState(() => search = value.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final doctor = filtered[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      radius: 28,
                      child: Icon(Icons.person, size: 30),
                    ),
                    title: Text(
                      doctor['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${doctor['specialty']}\n${doctor['hospital']}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DoctorProfileScreen(
                            name: doctor['name']!,
                            specialty: doctor['specialty']!,
                            hospital: doctor['hospital']!,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
