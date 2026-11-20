import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/event_service.dart';
import '../../services/payment_service.dart';
import '../../services/registration_service.dart';
import '../../services/ticket_service.dart';
import '../auth/login_screen.dart';
import 'attendance_screen.dart';
import 'backup_screen.dart';
import 'create_guard_screen.dart';
import 'manage_events_screen.dart';
import 'pending_payments_screen.dart';
import 'registration_details_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _totalEvents = 0;
  int _pendingPayments = 0;
  int _totalRegistrations = 0;
  int _totalCheckIns = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final events = await EventService.instance.getAllEvents();
      final pending = await PaymentService.instance.getPendingPayments();
      final regs = await RegistrationService.instance.getAllRegistrations();
      final tickets = await TicketService.instance.getAllTickets();
      final checkIns = tickets.where((t) => t.ticketStatus == 'Used').length;

      if (mounted) {
        setState(() {
          _totalEvents = events.length;
          _pendingPayments = pending.length;
          _totalRegistrations = regs.length;
          _totalCheckIns = checkIns;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLogout() {
    AuthService.instance.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Stats',
            onPressed: _loadStats,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Admin Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white24,
                            child: Icon(
                              Icons.admin_panel_settings,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'System Administrator',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Campus Event Operations & Approvals',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Active Events',
                            value: '$_totalEvents',
                            icon: Icons.event,
                            color: const Color(0xFF0D47A1),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ManageEventsScreen(),
                                ),
                              );
                              _loadStats();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Pending Payments',
                            value: '$_pendingPayments',
                            icon: Icons.pending_actions,
                            color: const Color(0xFFEF6C00),
                            isUrgent: _pendingPayments > 0,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PendingPaymentsScreen(),
                                ),
                              );
                              _loadStats();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Registrations',
                            value: '$_totalRegistrations',
                            icon: Icons.people_outline,
                            color: const Color(0xFF2E7D32),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const RegistrationDetailsScreen(),
                                ),
                              );
                              _loadStats();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Gate Check-Ins',
                            value: '$_totalCheckIns',
                            icon: Icons.verified_user_outlined,
                            color: const Color(0xFF00838F),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AttendanceScreen(),
                                ),
                              );
                              _loadStats();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Menu Options
                    const Text(
                      'Management Actions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildMenuTile(
                      icon: Icons.edit_calendar,
                      title: 'Manage Events',
                      subtitle:
                          'Create, edit, delete, and view event schedules',
                      badgeColor: const Color(0xFF0D47A1),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManageEventsScreen(),
                          ),
                        );
                        _loadStats();
                      },
                    ),

                    _buildMenuTile(
                      icon: Icons.payment_outlined,
                      title: 'Pending Payments',
                      subtitle: 'Verify transaction references & issue tickets',
                      badgeText: _pendingPayments > 0
                          ? '$_pendingPayments New'
                          : null,
                      badgeColor: const Color(0xFFEF6C00),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PendingPaymentsScreen(),
                          ),
                        );
                        _loadStats();
                      },
                    ),

                    _buildMenuTile(
                      icon: Icons.app_registration,
                      title: 'Student Registrations',
                      subtitle: 'View all registered students & status history',
                      badgeColor: const Color(0xFF2E7D32),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegistrationDetailsScreen(),
                          ),
                        );
                      },
                    ),

                    _buildMenuTile(
                      icon: Icons.how_to_reg,
                      title: 'Attendance & Entry Records',
                      subtitle: 'Real-time gate check-ins & guard scan history',
                      badgeColor: const Color(0xFF00838F),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AttendanceScreen(),
                          ),
                        );
                      },
                    ),

                    _buildMenuTile(
                      icon: Icons.security,
                      title: 'Create Guard Account',
                      subtitle: 'Add gate security personnel credentials',
                      badgeColor: const Color(0xFF6A1B9A),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateGuardScreen(),
                          ),
                        );
                      },
                    ),

                    _buildMenuTile(
                      icon: Icons.cloud_sync,
                      title: 'Google Drive Backup & Restore',
                      subtitle: 'Backup database to Google Cloud or restore data',
                      badgeColor: const Color(0xFF0288D1),
                      iconColor: const Color(0xFF0288D1),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BackupScreen(),
                          ),
                        );
                        _loadStats();
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    bool isUrgent = false,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUrgent ? color : Colors.grey.shade200,
              width: isUrgent ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Icon(icon, color: color, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? badgeColor,
    String? badgeText,
    Color? iconColor,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: (iconColor ?? const Color(0xFF0D47A1)).withValues(
            alpha: 0.1,
          ),
          child: Icon(icon, color: iconColor ?? const Color(0xFF0D47A1)),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            if (badgeText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor ?? const Color(0xFFEF6C00),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
      ),
    );
  }
}
