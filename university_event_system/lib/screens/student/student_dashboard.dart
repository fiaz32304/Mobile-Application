import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/event_service.dart';
import '../../services/registration_service.dart';
import '../../services/ticket_service.dart';
import '../auth/login_screen.dart';
import 'event_list_screen.dart';
import 'my_registrations_screen.dart';
import 'my_tickets_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;
  UserModel? _student;

  int _eventCount = 0;
  int _registrationCount = 0;
  int _ticketCount = 0;

  @override
  void initState() {
    super.initState();
    _student = AuthService.instance.currentUser;
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    if (_student?.id == null) return;
    try {
      final events = await EventService.instance.getAllEvents();
      final regs = await RegistrationService.instance.getStudentRegistrations(
        _student!.id!,
      );
      final tickets = await TicketService.instance.getStudentTickets(
        _student!.id!,
      );

      if (mounted) {
        setState(() {
          _eventCount = events.length;
          _registrationCount = regs.length;
          _ticketCount = tickets.where((t) => t.ticketStatus == 'Valid').length;
        });
      }
    } catch (_) {}
  }

  void _handleLogout() {
    AuthService.instance.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      EventListScreen(onRefreshStats: _loadSummary),
      MyRegistrationsScreen(onRefreshStats: _loadSummary),
      MyTicketsScreen(onRefreshStats: _loadSummary),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _student?.name ?? 'Student Portal',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (_student?.rollNumber != null)
              Text(
                'Roll No: ${_student!.rollNumber}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadSummary,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          _loadSummary();
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: const Icon(Icons.explore),
            label: 'Events ($_eventCount)',
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: 'Registrations ($_registrationCount)',
          ),
          NavigationDestination(
            icon: const Icon(Icons.qr_code_2_outlined),
            selectedIcon: const Icon(Icons.qr_code_2),
            label: 'My Tickets ($_ticketCount)',
          ),
        ],
      ),
    );
  }
}
