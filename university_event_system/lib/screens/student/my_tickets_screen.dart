import 'package:flutter/material.dart';

import '../../models/ticket_model.dart';
import '../../services/auth_service.dart';
import '../../services/ticket_service.dart';
import '../../widgets/ticket_card.dart';
import 'ticket_detail_screen.dart';

class MyTicketsScreen extends StatefulWidget {
  final VoidCallback? onRefreshStats;

  const MyTicketsScreen({super.key, this.onRefreshStats});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  List<TicketModel> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    final user = AuthService.instance.currentUser;
    if (user?.id == null) return;

    try {
      final list = await TicketService.instance.getStudentTickets(user!.id!);
      if (mounted) {
        setState(() {
          _tickets = list;
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

    if (_tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            const Text(
              'No tickets issued yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Tickets are generated once the admin approves your payment.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTickets,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 20),
        itemCount: _tickets.length,
        itemBuilder: (context, index) {
          final ticket = _tickets[index];
          return TicketCard(
            ticket: ticket,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TicketDetailScreen(ticket: ticket),
                ),
              );
              _loadTickets();
            },
          );
        },
      ),
    );
  }
}
