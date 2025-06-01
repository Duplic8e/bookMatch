import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookmatch/features/auth/presentation/providers/auth_providers.dart';
// Corrected import paths based on our previous discussion
import 'package:bookmatch/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:bookmatch/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:bookmatch/features/auth/presentation/screens/profile_screen.dart'; // Assuming this file exists and ProfileScreen class is defined

import 'package:bookmatch/features/home/presentation/screens/home_screen.dart';
import 'package:bookmatch/features/books/screens/book_details_screen.dart';

// Placeholder for SplashScreen if not defined elsewhere
// class SplashScreen extends StatelessWidget { // ORIGINAL
//   const SplashScreen({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(body: Center(child: CircularProgressIndicator()));
//   }
// }

// --- DEBUG MODIFICATION 1: Simplified SplashScreen for testing ---
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    print("DEBUG: Building SplashScreen"); // Debug print
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("DEBUG: Splash Screen Content"),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
// --- END OF DEBUG MODIFICATION 1 ---

GoRouter createRouter(WidgetRef ref) {
  print("DEBUG: createRouter called"); // Debug print
  // It's important to listen to authStateChangesProvider *outside* the redirect
  // if you want to react to its loading/error states directly for redirection,
  // but for GoRouter's redirect, it's fine to watch it inside.
  // However, ensure the provider itself is robust.
  return GoRouter(
    initialLocation: '/splash', // Start at splash
    routes: [
      GoRoute(
        name: 'splash',
        path: '/splash',
        builder: (context, state) {
          print("DEBUG: Building /splash route"); // Debug print
          return const SplashScreen();
        },
      ),
      GoRoute(
        name: 'signup',
        path: '/signup',
        builder: (context, state) {
          print("DEBUG: Building /signup route"); // Debug print
          return const SignUpScreen();
        },
      ),
      GoRoute(
        name: 'signin',
        path: '/signin',
        builder: (context, state) {
          print("DEBUG: Building /signin route"); // Debug print
          return const SignInScreen();
        },
      ),
      GoRoute(
        name: 'home',
        path: '/home',
        builder: (context, state) {
          print("DEBUG: Building /home route"); // Debug print
          return const HomeScreen(); // Ensure HomeScreen is also debugged if needed
        },
      ),
      GoRoute(
        name: 'profile',
        path: '/profile',
        builder: (context, state) {
          print("DEBUG: Building /profile route"); // Debug print
          return const ProfileScreen();
        },
      ),
      GoRoute(
        name: 'bookDetails',
        path: '/books/:bookId',
        builder: (context, state) {
          print("DEBUG: Building /books/:bookId route"); // Debug print
          final bookId = state.pathParameters['bookId'];
          if (bookId == null) {
            return Scaffold(
              appBar: AppBar(title: const Text("Error")),
              body: const Center(child: Text("Book ID is missing.")),
            );
          }
          return BookDetailsScreen(bookId: bookId);
        },
      ),
    ],
    // --- RESTORED AND DEBUGGED REDIRECT LOGIC ---
    redirect: (BuildContext context, GoRouterState state) {
      final location = state.matchedLocation;
      print("DEBUG: GoRouter redirect called. Current location: $location");

      // Watch the authStateChangesProvider to get the current user status.
      // This AsyncValue will rebuild the redirect whenever the auth state changes.
      final authState = ref.watch(authStateChangesProvider);

      print(
        "DEBUG: GoRouter redirect - authState.isLoading: ${authState.isLoading}, authState.hasValue: ${authState.hasValue}, authState.error: ${authState.error}",
      );

      final onAuthScreens = location == '/signin' || location == '/signup';
      final onSplash = location == '/splash';

      // If auth state is still loading, and we are not already on splash, go to splash.
      // If we are on splash, let it build (return null).
      if (authState.isLoading) {
        print("DEBUG: GoRouter redirect - Auth state is loading.");
        return onSplash ? null : '/splash';
      }

      final isLoggedIn = authState.hasValue && authState.value != null;
      print(
        "DEBUG: GoRouter redirect - isLoggedIn: $isLoggedIn (based on authState.hasValue and authState.value != null)",
      );

      if (isLoggedIn) {
        print("DEBUG: GoRouter redirect - User IS logged in.");
        // If logged in, and on splash, signin, or signup, redirect to home.
        if (onSplash || onAuthScreens) {
          print(
            "DEBUG: GoRouter redirect - User on splash/auth screen, redirecting to /home.",
          );
          return '/home';
        }
        // If logged in and on any other screen, no redirect needed from here.
        print(
          "DEBUG: GoRouter redirect - User logged in, not on splash/auth. No redirect needed from here.",
        );
        return null;
      } else {
        // User is NOT logged in (and auth is not loading)
        print("DEBUG: GoRouter redirect - User is NOT logged in.");
        // If not logged in, and on splash, let splash decide (or redirect to signin if splash logic is minimal)
        // For simplicity, if on splash and not logged in (and not loading), go to signin.
        if (onSplash) {
          print(
            "DEBUG: GoRouter redirect - User not logged in, on splash, redirecting to /signin.",
          );
          return '/signin';
        }
        // If not logged in and NOT on an auth screen or splash, redirect to signin.
        // This prevents access to protected routes.
        if (!onAuthScreens && !onSplash) {
          print(
            "DEBUG: GoRouter redirect - User not logged in, not on auth/splash screen, redirecting to /signin.",
          );
          return '/signin';
        }
        // If not logged in BUT already on signin/signup, no redirect needed.
        print(
          "DEBUG: GoRouter redirect - User not logged in, already on auth screen. No redirect needed.",
        );
        return null;
      }
    },
    // --- END OF RESTORED REDIRECT LOGIC ---
    errorBuilder:
        (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Page Not Found')),
          body: Center(
            child: Text(
              'Error: ${state.error?.toString() ?? 'Unknown route issue'}. Path: ${state.uri}',
            ),
          ),
        ),
  );
}
