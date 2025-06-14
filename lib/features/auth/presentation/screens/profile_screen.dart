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

  // animated background
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

    _pulseAnimation = Tween<double>(begin: .85, end: 1.15).animate(
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
    final merri       = context.merriweather;
    final user        = ref.watch(authStateChangesProvider).valueOrNull;
    final authCtrl    = ref.watch(authControllerProvider);
    final currentMode = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(.85),
        elevation: 0,
        title: Text(
          'Profile & Settings',
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: theme.colorScheme.primary),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: Stack(
          children: [
            // animated blobs + shapes
            _blob(260, theme.colorScheme.primary.withOpacity(.25),
                top: -160 + _scrollOffset * .45,
                left: -110 + _scrollOffset * .25,
                animated: true),
            _blob(320, theme.colorScheme.secondary.withOpacity(.20),
                bottom: -190 + _scrollOffset * .18,
                right: -90 + _scrollOffset * .12),
            _square(190, theme.colorScheme.primary.withOpacity(.18),
                top: 230 - _scrollOffset * .35,
                right: -70 + _scrollOffset * .18),
            _blob(130, theme.colorScheme.secondary.withOpacity(.22),
                top: 500 - _scrollOffset * .28,
                left: -60 + _scrollOffset * .18),

            // main content
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
                        _avatar(theme, merri, user),
                        const SizedBox(height: 16),
                        _displayNameField(merri),
                        const SizedBox(height: 8),
                        Center(child: Text(user.email!, style: merri.bodyMedium)),
                        const SizedBox(height: 32),
                      ],
                      Text('Favorite Genres', style: merri.titleLarge),
                      const Divider(),
                      _genreChips(theme, merri),
                      const SizedBox(height: 32),
                      Text('Settings', style: merri.titleLarge),
                      const Divider(),
                      _themeCard(theme, merri, currentMode),
                      _faqCard(theme, merri),
                      const SizedBox(height: 32),
                      _buttonsRow(theme, authCtrl, user, context),
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

  // ---------- Widgets --------------------------------------------------

  Widget _avatar(ThemeData theme, TextTheme merri, User user) => Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child:
                  _circle(120, theme.colorScheme.primary.withOpacity(.30)),
            ),
            Hero(
              tag: 'profile-avatar',
              child: CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  (user.displayName?.isNotEmpty ?? false)
                      ? user.displayName![0].toUpperCase()
                      : user.email![0].toUpperCase(),
                  style: merri.titleLarge!.copyWith(fontSize: 48),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _displayNameField(TextTheme merri) => TextFormField(
        controller: _displayNameController,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Image.asset(
              'lib/features/auth/assets/user.png',
              width: 24,
              height: 24,
            ),
          ),
          labelText: 'Display Name',
          labelStyle: merri.bodyMedium,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  Widget _genreChips(ThemeData theme, TextTheme merri) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Wrap(
          key: ValueKey(selectedGenres),
          spacing: 8,
          runSpacing: 8,
          children: allGenres.map((g) {
            final sel = selectedGenres.contains(g);
            return ChoiceChip(
              label: Text(g,
                  style: merri.bodySmall!.copyWith(
                      color:
                          sel ? Colors.white : theme.colorScheme.onSurface)),
              selected: sel,
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary,
              onSelected: (v) => setState(() => v
                  ? selectedGenres.add(g)
                  : selectedGenres.remove(g)),
            );
          }).toList(),
        ),
      );

  Card _themeCard(ThemeData theme, TextTheme merri, ThemeMode current) => Card(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Theme', style: merri.bodyLarge),
              Row(
                children: ThemeMode.values.map((mode) {
                  final asset = mode == ThemeMode.light
                      ? 'lib/features/auth/assets/sun.png'
                      : mode == ThemeMode.dark
                          ? 'lib/features/auth/assets/moon.png'
                          : 'lib/features/auth/assets/gear.png';
                  return IconButton(
                    icon: Image.asset(asset, width: 24, height: 24),
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

  Card _faqCard(ThemeData theme, TextTheme merri) => Card(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Image.asset(
            'lib/features/auth/assets/question-mark.png',
            width: 28,
            height: 28,
          ),
          title: Text('Help & FAQ', style: merri.bodyLarge),
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FAQScreen())),
        ),
      );

  Widget _buttonsRow(
    ThemeData theme,
    AsyncValue authCtrl,
    User? user,
    BuildContext ctx,
  ) =>
      Row(
        children: [
          Expanded(
            child: _actionButton(
              ctx,
              icon: Icons.save,
              label: 'Save',
              isLoading: authCtrl.isLoading,
              onTap: () => _saveProfile(user, ctx),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _actionButton(
              ctx,
              icon: Icons.logout,
              label: 'Sign Out',
              isLoading: authCtrl.isLoading,
              color: theme.colorScheme.error,
              onTap: () =>
                  ref.read(authControllerProvider.notifier).signOut(),
            ),
          ),
        ],
      );

  // ---------- Simple helpers ------------------------------------------

  Widget _blob(double size, Color c,
          {double? top,
          double? left,
          double? right,
          double? bottom,
          bool animated = false}) =>
      Positioned(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
        child: animated
            ? ScaleTransition(scale: _pulseAnimation, child: _circle(size, c))
            : _circle(size, c),
      );

  Widget _square(double size, Color c,
          {double? top, double? left, double? right, double? bottom}) =>
      Positioned(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
        child: Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      );

  Widget _circle(double s, Color c) =>
      Container(width: s, height: s, decoration: BoxDecoration(shape: BoxShape.circle, color: c));

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
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(backgroundColor: color),
        onPressed: isLoading ? null : onTap,
      );

  Future<void> _saveProfile(User? user, BuildContext ctx) async {
    final name = _displayNameController.text.trim();
    if (user != null && name.isNotEmpty) {
      await user.updateDisplayName(name);
      await ref.read(userProfileRepositoryProvider).createUserProfile(
            uid: user.uid,
            email: user.email!,
            displayName: name,
            favoriteGenres: selectedGenres,
          );
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx)
            .showSnackBar(const SnackBar(content: Text('Profile updated')));
      }
    }
  }
}
