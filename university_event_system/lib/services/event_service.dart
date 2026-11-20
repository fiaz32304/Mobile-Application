import '../database/database_helper.dart';
import '../models/event_model.dart';

class EventService {
  EventService._internal();
  static final EventService instance = EventService._internal();

  /// Retrieve all events
  Future<List<EventModel>> getAllEvents() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'events',
      orderBy: 'event_date ASC, event_time ASC',
    );
    return results.map((m) => EventModel.fromMap(m)).toList();
  }

  /// Retrieve single event by ID
  Future<EventModel?> getEventById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return EventModel.fromMap(results.first);
  }

  /// Create new event (Admin only)
  Future<EventModel> createEvent(EventModel event) async {
    final db = await DatabaseHelper.instance.database;
    final map = event.toMap()..remove('id');
    final id = await db.insert('events', map);
    return event.copyWith(id: id);
  }

  /// Update event (Admin only)
  Future<bool> updateEvent(EventModel event) async {
    if (event.id == null) return false;
    final db = await DatabaseHelper.instance.database;
    final count = await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
    return count > 0;
  }

  /// Delete event (Admin only)
  Future<bool> deleteEvent(int id) async {
    final db = await DatabaseHelper.instance.database;
    final count = await db.delete('events', where: 'id = ?', whereArgs: [id]);
    return count > 0;
  }

  /// Get approved registrations count for capacity calculations
  Future<int> getApprovedCount(int eventId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM registrations WHERE event_id = ? AND status = ?',
      [eventId, 'Approved'],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Calculate remaining seats
  Future<int> getRemainingCapacity(int eventId) async {
    final event = await getEventById(eventId);
    if (event == null) return 0;
    final approved = await getApprovedCount(eventId);
    final remaining = event.capacity - approved;
    return remaining > 0 ? remaining : 0;
  }
}
