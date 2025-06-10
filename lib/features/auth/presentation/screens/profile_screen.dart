import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_project_bookstore/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile_app_project_bookstore/Core/theme/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final currentTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (user != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      // You can add user.photoURL here later if you implement it
                      child: Text(
                        user.displayName?.substring(0, 1).toUpperCase() ?? user.email?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.displayName ?? 'No display name',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email ?? 'No email',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),
          ListTile(
            title: const Text('App Theme'),
            subtitle: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
                ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.settings)),
              ],
              selected: {currentTheme},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                ref.read(themeNotifierProvider.notifier).setTheme(newSelection.first);
              },
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOutUser();
            },
          ),
        ],
      ),
    );
  }
}
