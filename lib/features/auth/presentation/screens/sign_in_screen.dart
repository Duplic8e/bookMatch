import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookmatch/features/auth/presentation/providers/auth_providers.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  void _trySubmit() async {
    final isValid = _formKey.currentState?.validate();
    FocusScope.of(context).unfocus(); // Close keyboard

    if (isValid == true) {
      _formKey.currentState?.save();
      print(
        "DEBUG: SignInScreen - Attempting to sign in with Email: $_email",
      ); // DEBUG
      // Call the sign-in method from the AuthNotifier
      // No need to await here if navigation is handled by listener or router redirect
      ref.read(authNotifierProvider.notifier).signInUser(_email, _password);
    } else {
      print("DEBUG: SignInScreen - Form is not valid."); // DEBUG
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the AuthScreenState for loading and errors
    final authScreenState = ref.watch(
      authNotifierProvider,
    ); // For isLoading and error
    final authNotifier = ref.read(authNotifierProvider.notifier);

    ref.listen<AuthScreenState>(authNotifierProvider, (previous, next) {
      print(
        "DEBUG: SignInScreen listener - Prev User: ${previous?.user?.uid}, Next User: ${next.user?.uid}, Error: ${next.error}, Loading: ${next.isLoading}",
      ); // DEBUG

      if (next.error != null && next.error!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        authNotifier.clearError(); // Clear error after showing
      }
      // Successful login should trigger redirect via GoRouter's authStateChangesProvider listener
      // If GoRouter's redirect is working correctly with authStateChangesProvider,
      // this direct navigation might not be strictly necessary or could conflict.
      // However, for debugging, let's see if the user object appears here.
      if (next.user != null) {
        print(
          "DEBUG: SignInScreen listener - User is now available: ${next.user!.uid}. GoRouter should redirect.",
        );
        // context.goNamed('home'); // Let GoRouter handle this if authStateChangesProvider is correctly wired
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Sign In (Debug)')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  key: const ValueKey('email_signin'),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value ?? '';
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('password_signin'),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 7) {
                      return 'Password must be at least 7 characters long.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value ?? '';
                  },
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 30),
                if (authScreenState.isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _trySubmit,
                    child: const Text('Sign In'),
                  ),
                const SizedBox(height: 20),
                TextButton(
                  child: const Text('Create new account'),
                  onPressed: () {
                    print(
                      "DEBUG: SignInScreen - Navigating to signup",
                    ); // DEBUG
                    context.goNamed('signup');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
