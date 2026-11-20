import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../services/auth_service.dart';
import '../../services/event_service.dart';
import '../../widgets/custom_button.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _venueController = TextEditingController();
  final _priceController = TextEditingController(text: '0');
  final _capacityController = TextEditingController(text: '100');

  String _category = 'Technology';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
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
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = AuthService.instance.currentUser;
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final timeStr = _selectedTime.format(context);

      final newEvent = EventModel(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _category,
        eventDate: dateStr,
        eventTime: timeStr,
        venue: _venueController.text.trim(),
        ticketPrice: double.tryParse(_priceController.text.trim()) ?? 0.0,
        capacity: int.tryParse(_capacityController.text.trim()) ?? 100,
        createdBy: user?.id ?? 1,
      );

      await EventService.instance.createEvent(newEvent);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event created successfully!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating event: $e'),
          backgroundColor: const Color(0xFFC62828),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final timeFormatted = _selectedTime.format(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add University Event'),
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
              // Title
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

              // Category Dropdown
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

              // Description
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

              // Date & Time pickers in row
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

              // Venue
              TextFormField(
                controller: _venueController,
                decoration: InputDecoration(
                  labelText: 'Venue / Hall / Lab',
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

              // Price and Capacity in row
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
                        labelText: 'Capacity (Seats)',
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
                text: 'Publish Event',
                isLoading: _isLoading,
                icon: Icons.check_circle_outline,
                onPressed: _saveEvent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
