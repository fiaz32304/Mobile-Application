import 'package:flutter/material.dart';

import '../models/event_model.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showPrice;
  final int? remainingSeats;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.trailing,
    this.showPrice = true,
    this.remainingSeats,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
      case 'tech':
        return const Color(0xFF0D47A1); // Deep blue
      case 'workshop':
        return const Color(0xFF6A1B9A); // Purple
      case 'sports':
        return const Color(0xFF2E7D32); // Green
      case 'cultural':
      case 'arts':
        return const Color(0xFFD84315); // Deep orange
      default:
        return const Color(0xFF00838F); // Teal
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(event.category);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Category Tag & Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: catColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      event.category.toUpperCase(),
                      style: TextStyle(
                        color: catColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  if (showPrice)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        event.ticketPrice == 0
                            ? 'Free Entry'
                            : 'PKR ${event.ticketPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 6),

              // Description (truncated)
              Text(
                event.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Metadata Row (Date, Time, Venue)
              Row(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    event.eventDate,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.access_time_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    event.eventTime,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.venue,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (remainingSeats != null)
                    Text(
                      '$remainingSeats seats left',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: remainingSeats! <= 10
                            ? const Color(0xFFC62828)
                            : Colors.grey.shade700,
                      ),
                    ),
                ],
              ),

              if (trailing != null) ...[const SizedBox(height: 10), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}
