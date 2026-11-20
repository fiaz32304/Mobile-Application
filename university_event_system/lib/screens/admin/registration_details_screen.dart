import 'package:flutter/material.dart';

import '../../models/registration_model.dart';
import '../../services/registration_service.dart';

class RegistrationDetailsScreen extends StatefulWidget {
  const RegistrationDetailsScreen({super.key});

  @override
  State<RegistrationDetailsScreen> createState() =>
      _RegistrationDetailsScreenState();
}

class _RegistrationDetailsScreenState extends State<RegistrationDetailsScreen> {
  List<RegistrationModel> _allRegistrations = [];
  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRegistrations();
  }

  Future<void> _loadRegistrations() async {
    setState(() => _isLoading = true);
    try {
      final list = await RegistrationService.instance.getAllRegistrations();
      if (mounted) {
        setState(() {
          _allRegistrations = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF2E7D32);
      case 'pending':
        return const Color(0xFFEF6C00);
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFC62828);
      default:
        return Colors.grey.shade600;
    }
  }

  List<RegistrationModel> get _filteredList {
    return _allRegistrations.where((r) {
      final matchesFilter =
          _selectedFilter == 'All' ||
          r.status.toLowerCase() == _selectedFilter.toLowerCase();
      final matchesSearch =
          _searchQuery.isEmpty ||
          (r.studentName ?? '').toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (r.studentRollNumber ?? '').toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (r.eventTitle ?? '').toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredList;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Registered Students'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search & Filter header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search by student, roll number, or event...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Approved', 'Pending', 'Rejected'].map((
                      status,
                    ) {
                      final isSelected = _selectedFilter == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          selectedColor: const Color(0xFF0D47A1),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                          onSelected: (_) =>
                              setState(() => _selectedFilter = status),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Registrations List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 54,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No matching registrations found',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadRegistrations,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final r = list[index];
                        final statusColor = _getStatusColor(r.status);

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      r.studentName ?? 'Student',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: statusColor.withValues(
                                            alpha: 0.4,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        r.status.toUpperCase(),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Roll No: ${r.studentRollNumber ?? "N/A"}  •  ${r.studentEmail ?? ""}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Divider(height: 1),
                                const SizedBox(height: 8),
                                Text(
                                  r.eventTitle ?? 'Event',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0D47A1),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Date: ${r.eventDate ?? "N/A"}  |  Fee: PKR ${(r.ticketPrice ?? 0).toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                if (r.transactionReference != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'Ref: ${r.transactionReference} (${r.paymentMethod ?? "Manual"})',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade800,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                                if (r.ticketCode != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.confirmation_number,
                                        size: 14,
                                        color: Color(0xFF2E7D32),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Ticket: ${r.ticketCode}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
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
