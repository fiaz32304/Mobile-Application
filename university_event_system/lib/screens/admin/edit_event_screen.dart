import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../widgets/custom_button.dart';

class EditEventScreen extends StatefulWidget {
  final EventModel event;

  const EditEventScreen({super.key, required this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _venueController;
  late TextEditingController _priceController;
  late TextEditingController _capacityController;

  late String _category;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  final List<String> _categories = [
    'Technology',
    'Workshop',
    'Sports',
    'Cultural',
    'Academic',
    'Seminar',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descController = TextEditingController(text: widget.event.description);
    _venueController = TextEditingController(text: widget.event.venue);
    _priceController = TextEditingController(
      text: widget.event.ticketPrice.toStringAsFixed(0),
    );
    _capacityController = TextEditingController(
      text: widget.event.capacity.toString(),
    );
    _category = _categories.contains(widget.event.category)
        ? widget.event.category
        : _categories.first;

    try {
      _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.event.eventDate);
    } catch (_) {
      _selectedDate = DateTime.now();
    }
    _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _venueController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dateStr = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : widget.event.eventDate;
      final timeStr = _selectedTime != null
          ? _selectedTime!.format(context)
          : widget.event.eventTime;

      final updated = widget.event.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _category,
        eventDate: dateStr,
        eventTime: timeStr,
        venue: _venueController.text.trim(),
        ticketPrice:
            double.tryParse(_priceController.text.trim()) ??
            widget.event.ticketPrice,
        capacity:
            int.tryParse(_capacityController.text.trim()) ??
            widget.event.capacity,
      );

      await EventService.instance.updateEvent(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event updated successfully!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating event: $e'),
          backgroundColor: const Color(0xFFC62828),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = _selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
        : widget.event.eventDate;
    final timeFormatted = _selectedTime != null
        ? _selectedTime!.format(context)
        : widget.event.eventTime;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Event'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Event Title',
                  prefixIcon: const Icon(Icons.event, color: Color(0xFF0D47A1)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(
                    Icons.category_outlined,
                    color: Color(0xFF0D47A1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: _categories.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(
                      Icons.description_outlined,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter a description'
                    : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Event Date',
                          prefixIcon: const Icon(
                            Icons.calendar_month,
                            color: Color(0xFF0D47A1),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          dateFormatted,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Event Time',
                          prefixIcon: const Icon(
                            Icons.access_time,
                            color: Color(0xFF0D47A1),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          timeFormatted,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _venueController,
                decoration: InputDecoration(
                  labelText: 'Venue',
                  prefixIcon: const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF0D47A1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter a venue'
                    : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Ticket Price (PKR)',
                        prefixIcon: const Icon(
                          Icons.payments_outlined,
                          color: Color(0xFF0D47A1),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter price';
                        if (double.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _capacityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Capacity',
                        prefixIcon: const Icon(
                          Icons.people_outline,
                          color: Color(0xFF0D47A1),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Enter capacity';
                        }
                        final num = int.tryParse(v);
                        if (num == null || num <= 0) return 'Must be > 0';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              CustomButton(
                text: 'Save Changes',
                isLoading: _isLoading,
                icon: Icons.save_outlined,
                onPressed: _updateEvent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
