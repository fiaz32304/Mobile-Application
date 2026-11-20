import 'package:flutter/material.dart';

import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../widgets/event_card.dart';
import 'add_event_screen.dart';
import 'edit_event_screen.dart';

class ManageEventsScreen extends StatefulWidget {
  const ManageEventsScreen({super.key});

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen> {
  List<EventModel> _events = [];
  Map<int, int> _remainingSeats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final list = await EventService.instance.getAllEvents();
      final seatsMap = <int, int>{};
      for (final e in list) {
        if (e.id != null) {
          seatsMap[e.id!] = await EventService.instance.getRemainingCapacity(
            e.id!,
          );
        }
      }
      if (mounted) {
        setState(() {
          _events = list;
          _remainingSeats = seatsMap;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDelete(EventModel event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text(
          'Are you sure you want to delete "${event.title}"? All associated registrations, payments, and tickets will also be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && event.id != null) {
      await EventService.instance.deleteEvent(event.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${event.title}"'),
            backgroundColor: const Color(0xFFC62828),
          ),
        );
        _loadEvents();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Manage Events'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Event'),
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddEventScreen()),
          );
          if (created == true) _loadEvents();
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'No events found',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Click "+ New Event" to create the first event.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadEvents,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final event = _events[index];
                  final remaining = _remainingSeats[event.id];

                  return EventCard(
                    event: event,
                    remainingSeats: remaining,
                    trailing: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Color(0xFF0D47A1),
                          ),
                          label: const Text(
                            'Edit',
                            style: TextStyle(color: Color(0xFF0D47A1)),
                          ),
                          onPressed: () async {
                            final updated = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditEventScreen(event: event),
                              ),
                            );
                            if (updated == true) _loadEvents();
                          },
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Color(0xFFC62828),
                          ),
                          label: const Text(
                            'Delete',
                            style: TextStyle(color: Color(0xFFC62828)),
                          ),
                          onPressed: () => _confirmDelete(event),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
