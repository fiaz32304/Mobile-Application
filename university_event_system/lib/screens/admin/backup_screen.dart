import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:intl/intl.dart';

import '../../services/google_drive_service.dart';
import '../../widgets/custom_button.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isConnecting = false;
  bool _isBackingUp = false;
  bool _isRestoring = false;
  bool _isLoadingInfo = false;
  drive.File? _latestBackupFile;

  @override
  void initState() {
    super.initState();
    _checkBackupStatus();
  }

  Future<void> _checkBackupStatus() async {
    if (!mounted) return;
    setState(() => _isLoadingInfo = true);
    try {
      if (GoogleDriveService.instance.isSignedIn) {
        final file = await GoogleDriveService.instance.getLatestBackupInfo();
        if (mounted) setState(() => _latestBackupFile = file);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingInfo = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isConnecting = true);
    try {
      await GoogleDriveService.instance.signIn();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Connected to Google Drive: ${GoogleDriveService.instance.currentUser?.email}',
            ),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      }
      await _checkBackupStatus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect Google Drive: $e'),
            backgroundColor: const Color(0xFFC62828),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  Future<void> _handleSignOut() async {
    await GoogleDriveService.instance.signOut();
    if (mounted) {
      setState(() {
        _latestBackupFile = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disconnected from Google Account.'),
        ),
      );
    }
  }

  Future<void> _handleUploadBackup() async {
    setState(() => _isBackingUp = true);
    try {
      final msg = await GoogleDriveService.instance.uploadBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      }
      await _checkBackupStatus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup Failed: $e'),
            backgroundColor: const Color(0xFFC62828),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _handleRestoreBackup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Database from Drive?'),
        content: const Text(
          'Warning: This action will replace your local database with the backup copy stored on Google Drive. Current unsaved offline changes will be overwritten.',
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
            child: const Text(
              'Confirm Restore',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isRestoring = true);
    try {
      final msg = await GoogleDriveService.instance.restoreBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      }
      await _checkBackupStatus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore Failed: $e'),
            backgroundColor: const Color(0xFFC62828),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final googleUser = GoogleDriveService.instance.currentUser;
    final isSignedIn = GoogleDriveService.instance.isSignedIn;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Google Cloud Backup & Restore'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Account Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFE3F2FD),
                          child: Icon(
                            Icons.cloud_sync_outlined,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Google Account Connection',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isSignedIn
                                    ? (googleUser?.email ?? 'Connected')
                                    : 'Not connected to Google Drive',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isSignedIn
                                      ? const Color(0xFF2E7D32)
                                      : Colors.grey.shade600,
                                  fontWeight: isSignedIn
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!isSignedIn)
                      CustomButton(
                        text: 'Connect Google Drive Account',
                        icon: Icons.login,
                        isLoading: _isConnecting,
                        onPressed: _handleGoogleSignIn,
                      )
                    else
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFC62828),
                          side: const BorderSide(color: Color(0xFFC62828)),
                          minimumSize: const Size.fromHeight(44),
                        ),
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('Disconnect Google Account'),
                        onPressed: _handleSignOut,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Backup Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cloud Backup Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_isLoadingInfo)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_latestBackupFile == null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber.shade900),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                isSignedIn
                                    ? 'No backup file found on your Google Drive.'
                                    : 'Connect Google account to check cloud backup status.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      _buildInfoRow(
                        'Backup File Name:',
                        _latestBackupFile!.name ?? 'university_events_backup.db',
                      ),
                      const Divider(height: 16),
                      _buildInfoRow(
                        'Last Backup Date:',
                        _latestBackupFile!.modifiedTime != null
                            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(
                                _latestBackupFile!.modifiedTime!.toLocal(),
                              )
                            : 'Unknown',
                      ),
                      const Divider(height: 16),
                      _buildInfoRow(
                        'Backup File Size:',
                        _latestBackupFile!.size != null
                            ? '${(int.parse(_latestBackupFile!.size!) / 1024).toStringAsFixed(1)} KB'
                            : 'Unknown',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Actions Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Cloud Sync Actions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Backup Database to Google Drive',
                      icon: Icons.cloud_upload_outlined,
                      color: const Color(0xFF0D47A1),
                      isLoading: _isBackingUp,
                      onPressed: _handleUploadBackup,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Restore Database from Google Drive',
                      icon: Icons.cloud_download_outlined,
                      color: const Color(0xFF0288D1),
                      isLoading: _isRestoring,
                      onPressed: _handleRestoreBackup,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
      ],
    );
  }
}
