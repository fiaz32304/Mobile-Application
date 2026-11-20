class EventModel {
  final int? id;
  final String title;
  final String description;
  final String category;
  final String eventDate;
  final String eventTime;
  final String venue;
  final double ticketPrice;
  final int capacity;
  final int createdBy;

  EventModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.eventDate,
    required this.eventTime,
    required this.venue,
    required this.ticketPrice,
    required this.capacity,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'event_date': eventDate,
      'event_time': eventTime,
      'venue': venue,
      'ticket_price': ticketPrice,
      'capacity': capacity,
      'created_by': createdBy,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      eventDate: map['event_date'] as String,
      eventTime: map['event_time'] as String,
      venue: map['venue'] as String,
      ticketPrice: (map['ticket_price'] is int)
          ? (map['ticket_price'] as int).toDouble()
          : (map['ticket_price'] as num).toDouble(),
      capacity: map['capacity'] as int,
      createdBy: map['created_by'] as int,
    );
  }

  EventModel copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    String? eventDate,
    String? eventTime,
    String? venue,
    double? ticketPrice,
    int? capacity,
    int? createdBy,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      venue: venue ?? this.venue,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      capacity: capacity ?? this.capacity,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
