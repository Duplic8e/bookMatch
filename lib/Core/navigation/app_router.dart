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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorAKey,
            routes: [
              GoRoute(
                name: 'home',
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    name: 'cart', // Cart is now a sub-route of home
                    path: 'cart',
                    builder: (context, state) => const CartScreen(),
                  ),
                  GoRoute(
                      name: 'bookDetails',
                      path: 'books/:bookId',
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
                          parentNavigatorKey: _rootNavigatorKey,
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
                ],
              ),
            ],
          ),
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
      final onAuthScreens = state.matchedLocation == '/signin' || state.matchedLocation == '/signup';
      final onSplash = state.matchedLocation == '/splash';

      if (authState.isLoading) {
        return onSplash ? null : '/splash';
      }
      final isLoggedIn = authState.hasValue && authState.value != null;
      if (!isLoggedIn && !onAuthScreens && !onSplash) {
        return '/signin';
      }
      if (isLoggedIn && (onSplash || onAuthScreens)) {
        return '/home';
      }
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(child: Text('Error: ${state.error}')),
    ),
  );
}
