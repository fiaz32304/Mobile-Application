import 'package:flutter/material.dart';

import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../widgets/event_card.dart';
import 'event_detail_screen.dart';

class EventListScreen extends StatefulWidget {
  final VoidCallback? onRefreshStats;

  const EventListScreen({super.key, this.onRefreshStats});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
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
      widget.onRefreshStats?.call();
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'No upcoming university events',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Check back later for newly announced events.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 20),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          final remaining = _remainingSeats[event.id];

          return EventCard(
            event: event,
            remainingSeats: remaining,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailScreen(event: event),
                ),
              );
              _loadEvents();
            },
          );
        },
      ),
    );
  }
}
