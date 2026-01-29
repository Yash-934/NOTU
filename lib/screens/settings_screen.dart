import 'package:flutter/material.dart';
import 'package:notu/utils/backup_service.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onDataRestored;

  const SettingsScreen({super.key, required this.onDataRestored});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BackupService _backupService = BackupService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Data'),
            subtitle: const Text('Save your books and chapters to a file.'),
            onTap: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final success = await _backupService.backupData();
              if (mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Backup successful!' : 'Backup failed.'),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Data'),
            subtitle: const Text('Restore your books and chapters from a file.'),
            onTap: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final success = await _backupService.restoreData();
              if (mounted) {
                if (success) {
                  widget.onDataRestored();
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Restore successful!')),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Restore failed.')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
