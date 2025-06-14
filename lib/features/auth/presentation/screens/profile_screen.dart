import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_project_bookstore/core/theme/app_theme.dart';
import 'package:mobile_app_project_bookstore/core/theme/theme_provider.dart';
import 'package:mobile_app_project_bookstore/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile_app_project_bookstore/features/user_profile/presentation/providers/user_profile_providers.dart';
import 'faq_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayNameController;

  final List<String> allGenres = [
    'Fiction', 'Mystery', 'Romance', 'Sci-Fi', 'Fantasy',
    'Biography', 'Self-Help', 'History', 'Thriller'
  ];
  List<String> selectedGenres = [];

  // background animation
  double _scrollOffset = 0;
  late final AnimationController _pulseController;
  late final Animation<double>  _pulseAnimation;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _displayNameController =
        TextEditingController(text: user?.displayName ?? '');

    if (user != null) _loadUserProfile(user.uid);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: .8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile(String uid) async {
    final snap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (snap.exists && mounted) {
      setState(() {
        selectedGenres =
            List<String>.from(snap.data()?['favoriteGenres'] ?? <String>[]);
      });
    }
  }

  bool _onScrollNotification(ScrollNotification n) {
    if (n.metrics.axis == Axis.vertical) {
      setState(() => _scrollOffset = n.metrics.pixels);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final merri       = context.merriweather;          // <-- extension
    final user        = ref.watch(authStateChangesProvider).valueOrNull;
    final authCtrl    = ref.watch(authControllerProvider);
    final currentMode = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(.8),
        elevation: 0,
        title: Text('Profile & Settings',
            style: merri.titleMedium!
                .copyWith(color: theme.colorScheme.onBackground)),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: Stack(
          children: [
            _blob(
              size: 250,
              color: theme.colorScheme.primary.withOpacity(.25),
              top: -150 + _scrollOffset * .4,
              left: -100 + _scrollOffset * .2,
              animated: true,
            ),
            _blob(
              size: 300,
              color: theme.colorScheme.secondary.withOpacity(.20),
              bottom: -180 + _scrollOffset * .15,
              right: -80 + _scrollOffset * .1,
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user != null) ...[
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ScaleTransition(
                                scale: _pulseAnimation,
                                child: _circle(
                                    120, theme.colorScheme.primary.withOpacity(.3)),
                              ),
                              Hero(
                                tag: 'profile-avatar',
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor:
                                      theme.colorScheme.primaryContainer,
                                  child: Text(
                                    (user.displayName?.isNotEmpty ?? false)
                                        ? user.displayName![0].toUpperCase()
                                        : user.email![0].toUpperCase(),
                                    style: merri.titleLarge!
                                        .copyWith(fontSize: 48),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _displayNameController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person),
                            labelText: 'Display Name',
                            labelStyle: merri.bodyMedium,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                            child: Text(user.email!,
                                style: theme.textTheme.bodyMedium)),
                        const SizedBox(height: 32),
                      ],

                      // genre chips
                      Text('Favorite Genres', style: merri.titleLarge),
                      const Divider(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Wrap(
                          key: ValueKey(selectedGenres),
                          spacing: 8,
                          runSpacing: 8,
                          children: allGenres.map((g) {
                            final selected = selectedGenres.contains(g);
                            return ChoiceChip(
                              label: Text(
                                g,
                                style: merri.bodySmall!.copyWith(
                                  color: selected
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              selected: selected,
                              backgroundColor: theme.colorScheme.surface,
                              selectedColor: theme.colorScheme.primary,
                              onSelected: (v) => setState(() => v
                                  ? selectedGenres.add(g)
                                  : selectedGenres.remove(g)),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // settings
                      Text('Settings', style: merri.titleLarge),
                      const Divider(),
                      _themeCard(theme, merri, currentMode),
                      _faqCard(merri),
                      const SizedBox(height: 32),

                      // buttons
                      Row(
                        children: [
                          Expanded(
                            child: _actionButton(
                              context,
                              icon: Icons.save,
                              label: 'Save',
                              isLoading: authCtrl.isLoading,
                              onTap: () async {
                                final name = _displayNameController.text.trim();
                                if (user != null && name.isNotEmpty) {
                                  await user.updateDisplayName(name);
                                  await ref
                                      .read(userProfileRepositoryProvider)
                                      .createUserProfile(
                                        uid: user.uid,
                                        email: user.email!,
                                        displayName: name,
                                        favoriteGenres: selectedGenres,
                                      );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Profile updated')),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _actionButton(
                              context,
                              icon: Icons.logout,
                              label: 'Sign Out',
                              isLoading: authCtrl.isLoading,
                              color: theme.colorScheme.error,
                              onTap: () => ref
                                  .read(authControllerProvider.notifier)
                                  .signOut(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI helper methods ---------------------------------------------------

  Widget _blob({
    required double size,
    required Color color,
    double? top,
    double? left,
    double? right,
    double? bottom,
    bool animated = false,
  }) =>
      Positioned(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
        child: animated ? ScaleTransition(scale: _pulseAnimation, child: _circle(size, color))
                         : _circle(size, color),
      );

  Widget _circle(double size, Color color) =>
      Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));

  Card _themeCard(ThemeData theme, TextTheme merri, ThemeMode current) =>
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Theme', style: merri.bodyLarge),
              Row(
                children: ThemeMode.values.map((mode) {
                  final sel  = mode == current;
                  IconData ic = mode == ThemeMode.light
                      ? Icons.light_mode
                      : mode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.settings;
                  return IconButton(
                    icon: Icon(ic,
                        color: sel
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface),
                    onPressed: () => ref
                        .read(themeNotifierProvider.notifier)
                        .setTheme(mode),
                  );
                }).toList(),
              )
            ],
          ),
        ),
      );

  Card _faqCard(TextTheme merri) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: const Icon(Icons.help_outline),
          title: Text('Help & FAQ', style: merri.bodyLarge),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FAQScreen()),
          ),
        ),
      );

  Widget _actionButton(
    BuildContext ctx, {
    required IconData icon,
    required String label,
    required bool isLoading,
    required VoidCallback onTap,
    Color? color,
  }) =>
      ElevatedButton.icon(
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(backgroundColor: color),
        onPressed: isLoading ? null : onTap,
      );
}
