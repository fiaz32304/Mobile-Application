import 'package:flutter/material.dart';

import '../../models/event_model.dart';
import '../../models/ticket_model.dart';
import '../../services/event_service.dart';
import '../../services/ticket_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<EventModel> _events = [];
  EventModel? _selectedEvent;
  List<TicketModel> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEventsAndAttendance();
  }

  Future<void> _loadEventsAndAttendance() async {
    setState(() => _isLoading = true);
    try {
      final events = await EventService.instance.getAllEvents();
      _events = events;

      if (events.isNotEmpty && _selectedEvent == null) {
        _selectedEvent = events.first;
      }

      await _loadTicketsForEvent();
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTicketsForEvent() async {
    if (_selectedEvent == null || _selectedEvent!.id == null) {
      setState(() {
        _tickets = [];
        _isLoading = false;
      });
      return;
    }

    try {
      final allTickets = await TicketService.instance.getAllTickets();
      final filtered = allTickets
          .where((t) => t.eventId == _selectedEvent!.id)
          .toList();

      if (mounted) {
        setState(() {
          _tickets = filtered;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkedInCount = _tickets
        .where((t) => t.ticketStatus == 'Used')
        .length;
    final totalTickets = _tickets.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Attendance & Entry Log'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Event Selector Header
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select University Event:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<EventModel>(
                            isExpanded: true,
                            value: _selectedEvent,
                            items: _events.map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedEvent = val;
                                  _isLoading = true;
                                });
                                _loadTicketsForEvent();
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Attendance Counters
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Checked In',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF2E7D32),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$checkedInCount',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Approved',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF0D47A1),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$totalTickets',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0D47A1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Not Arrived',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFEF6C00),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${totalTickets - checkedInCount}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFEF6C00),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Attendance List
                Expanded(
                  child: _tickets.isEmpty
                      ? Center(
                          child: Text(
                            'No approved tickets for this event.',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadTicketsForEvent,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _tickets.length,
                            itemBuilder: (context, index) {
                              final t = _tickets[index];
                              final isCheckedIn = t.ticketStatus == 'Used';

                              return Card(
                                elevation: 1,
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: isCheckedIn
                                        ? Colors.green.shade200
                                        : Colors.grey.shade200,
                                  ),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isCheckedIn
                                        ? const Color(0xFF2E7D32)
                                        : Colors.grey.shade300,
                                    child: Icon(
                                      isCheckedIn
                                          ? Icons.check
                                          : Icons.schedule,
                                      color: isCheckedIn
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    t.studentName ?? 'Student',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Roll No: ${t.studentRollNumber ?? "N/A"}  •  ${t.ticketCode}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      if (isCheckedIn && t.usedAt != null)
                                        Text(
                                          'Gate entry at ${t.usedAt}${t.guardName != null ? " by ${t.guardName}" : ""}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF2E7D32),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCheckedIn
                                          ? const Color(0xFFE8F5E9)
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isCheckedIn ? 'PRESENT' : 'ABSENT',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isCheckedIn
                                            ? const Color(0xFF2E7D32)
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
