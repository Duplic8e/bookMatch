// notification_controls_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationControlsScreen extends StatefulWidget {
  const NotificationControlsScreen({super.key});

  @override
  State<NotificationControlsScreen> createState() => _NotificationControlsScreenState();
}

class _NotificationControlsScreenState extends State<NotificationControlsScreen> {
  bool _notifyNewBooks = true;
  bool _notifyMentions = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null && mounted) {
        setState(() {
          _notifyNewBooks = data['notifyNewBooks'] ?? true;
          _notifyMentions = data['notifyMentions'] ?? true;
        });
      }
    }
  }

  Future<void> _updateSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'notifyNewBooks': _notifyNewBooks,
        'notifyMentions': _notifyMentions,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification preferences updated.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('New Book Releases'),
              subtitle: const Text('Notify when a new book is added'),
              value: _notifyNewBooks,
              onChanged: (v) => setState(() => _notifyNewBooks = v),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Community Mentions'),
              subtitle: const Text('When someone replies to your post'),
              value: _notifyMentions,
              onChanged: (v) => setState(() => _notifyMentions = v),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save Preferences'),
              onPressed: _updateSettings,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            )
          ],
        ),
      ),
    );
  }
}
