import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_project_bookstore/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile_app_project_bookstore/features/auth/presentation/screens/profile_screen.dart';
import 'package:mobile_app_project_bookstore/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:mobile_app_project_bookstore/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/screens/book_details_screen.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/screens/book_preview_screen.dart';
import 'package:mobile_app_project_bookstore/features/cart/presentation/screens/cart_screen.dart';
import 'package:mobile_app_project_bookstore/features/home/presentation/screens/home_screen.dart';
import 'package:mobile_app_project_bookstore/features/home/presentation/screens/scaffold_with_nested_navigation.dart';
import 'package:mobile_app_project_bookstore/features/library/presentation/screens/library_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

// private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorAKey = GlobalKey<NavigatorState>(debugLabel: 'shellA');
final _shellNavigatorBKey = GlobalKey<NavigatorState>(debugLabel: 'shellB');
final _shellNavigatorCKey = GlobalKey<NavigatorState>(debugLabel: 'shellC');

GoRouter createRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/splash',
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(
        name: 'splash',
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: 'signup',
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        name: 'signin',
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
      ),
      // This is a top-level route for the cart screen.
      // It will not have the bottom navigation bar.
      GoRoute(
        name: 'cart',
        path: '/cart',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CartScreen(),
      ),

      // Stateful Shell Route for main app sections with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
        },
        branches: [
          // Branch A: Home and its nested routes
          StatefulShellBranch(
            navigatorKey: _shellNavigatorAKey,
            routes: [
              GoRoute(
                  name: 'home',
                  path: '/home',
                  builder: (context, state) => const HomeScreen(),
                  routes: [
                    GoRoute(
                        name: 'bookDetails',
                        path: 'books/:bookId', // No leading '/' makes it a sub-route
                        builder: (context, state) {
                          final bookId = state.pathParameters['bookId'];
                          if (bookId == null) {
                            return const Scaffold(body: Center(child: Text("Book ID missing")));
                          }
                          return BookDetailScreen(bookId: bookId);
                        },
                        routes: [
                          GoRoute(
                            path: 'preview',
                            name: 'bookPreview',
                            parentNavigatorKey: _rootNavigatorKey, // Open in the root navigator to cover the bottom nav bar
                            builder: (context, state) {
                              final args = state.extra as Map<String, dynamic>?;
                              final url = args?['url'] as String?;
                              final title = args?['title'] as String?;
                              if (url != null && title != null) {
                                return BookPreviewScreen(pdfUrl: url, bookTitle: title);
                              }
                              return const Scaffold(body: Center(child: Text("Preview not available")));
                            },
                          ),
                        ]),
                  ]),
            ],
          ),

          // Branch B: Library
          StatefulShellBranch(
            navigatorKey: _shellNavigatorBKey,
            routes: [
              GoRoute(
                name: 'library',
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),

          // Branch C: Profile
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCKey,
            routes: [
              GoRoute(
                name: 'profile',
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.watch(authStateChangesProvider);
      final location = state.matchedLocation;

      final onAuthScreens = location == '/signin' || location == '/signup';
      final onSplash = location == '/splash';

      if (authState.isLoading) {
        return onSplash ? null : '/splash';
      }

      final isLoggedIn = authState.hasValue && authState.value != null;

      if (isLoggedIn) {
        if (onSplash || onAuthScreens) {
          return '/home';
        }
        return null;
      } else {
        // Not logged in
        if (!onAuthScreens) {
          return '/signin';
        }
        return null;
      }
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(child: Text('Error: ${state.error}')),
    ),
  );
}
