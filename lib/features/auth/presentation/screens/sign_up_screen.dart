import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_project_bookstore/features/auth/presentation/providers/auth_providers.dart';

class SignUpScreen extends ConsumerStatefulWidget { // Changed to ConsumerStatefulWidget for local state
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> { // ConsumerState
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Example: Local state for preferences - adapt as needed for your actual preferences UI
  Set<String> _selectedPreferences = {}; // Example: use a more complex UI for this

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { // Removed WidgetRef from here, use `ref` from ConsumerState
    // Listen to the AuthNotifier state for errors or navigation
    ref.listen<AuthScreenState>(authNotifierProvider, (previous, next) {
      if (next.error != null && next.error!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }
      if (next.user != null) {
        // User is signed up and logged in, GoRouter's redirect logic
        // should handle navigation to '/home' or appropriate screen.
      }
    });

    // Watch the AuthNotifier state to enable/disable button and show loading
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create KetaBook Account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Join KetaBook!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'you@example.com',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Minimum 6 characters',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // --- Placeholder for Preferences ---
                // TODO: Replace this with your actual preferences UI
                // For now, let's add a simple multi-select chip example
                const Text("Select Preferences (Example):", style: TextStyle(fontSize: 16)),
                Wrap(
                  spacing: 8.0,
                  children: <String>['Fiction', 'Sci-Fi', 'Mystery', 'History', 'Tech']
                      .map((String preference) {
                    return ChoiceChip(
                      label: Text(preference),
                      selected: _selectedPreferences.contains(preference),
                      onSelected: (bool selected) {
                        setState(() { // Use setState for local UI changes
                          if (selected) {
                            _selectedPreferences.add(preference);
                          } else {
                            _selectedPreferences.remove(preference);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                // --- End of Placeholder ---
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: authState.isLoading
                      ? null
                      : () {
                    if (formKey.currentState!.validate()) {
                      // TODO: Add proper preference selection UI and pass the selected preferences
                      // For now, using the example _selectedPreferences
                      if (_selectedPreferences.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select at least one preference.')),
                        );
                        return;
                      }

                      ref.read(authNotifierProvider.notifier).signUpUser(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                        _selectedPreferences, // Pass selected preferences
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                      : const Text('Sign Up'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: authState.isLoading
                      ? null
                      : () {
                    context.go('/signin'); // Navigate to SignInScreen
                  },
                  child: const Text('Already have an account? Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}