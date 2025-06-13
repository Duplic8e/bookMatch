import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_project_bookstore/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile_app_project_bookstore/features/auth/presentation/screens/profile_screen.dart';
import 'package:mobile_app_project_bookstore/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:mobile_app_project_bookstore/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/screens/book_details_screen.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/screens/book_preview_screen.dart';
import 'package:mobile_app_project_bookstore/features/home/presentation/screens/home_screen.dart';
import 'package:mobile_app_project_bookstore/features/home/presentation/screens/scaffold_with_nested_navigation.dart';
import 'package:mobile_app_project_bookstore/features/library/presentation/screens/library_screen.dart';
import 'package:mobile_app_project_bookstore/features/cart/presentation/screens/cart_screen.dart';
import 'package:mobile_app_project_bookstore/core/navigation/go_router_refresh_stream.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  // ** FIX: Use the new raw stream provider **
  final authStream = ref.watch(authStateStreamProvider);

  return GoRouter(
    initialLocation: '/home',
    navigatorKey: _rootNavigatorKey,
    refreshListenable: GoRouterRefreshStream(authStream),
    routes: [
      GoRoute(
        name: 'signin',
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        name: 'signup',
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
          name: 'bookDetails',
          path: '/books/:bookId',
          builder: (context, state) {
            final bookId = state.pathParameters['bookId']!;
            final extras = state.extra as Map<String, dynamic>?;
            return BookDetailScreen(bookId: bookId, extras: extras);
          },
          routes: [
            GoRoute(
              path: 'preview',
              name: 'bookPreview',
              builder: (context, state) {
                final bookId = state.pathParameters['bookId']!;
                final args = state.extra as Map<String, dynamic>?;
                final url = args?['url'] as String?;
                final title = args?['title'] as String?;
                final initialPage = args?['initialPage'] as int? ?? 1;
                final isFromLibrary = args?['isFromLibrary'] as bool? ?? false;
                return BookPreviewScreen(
                  bookId: bookId,
                  pdfUrl: url ?? '',
                  bookTitle: title ?? 'PDF',
                  initialPage: initialPage,
                  isFromLibrary: isFromLibrary,
                );
              },
            ),
          ]
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
                      name: 'cart',
                      path: 'cart',
                      builder: (context, state) => const CartScreen(),
                    ),
                  ]
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
      final isLoggedIn = ref.read(currentUserProvider) != null;
      final onAuthScreens = state.matchedLocation == '/signin' || state.matchedLocation == '/signup';

      if (!isLoggedIn && !onAuthScreens) {
        return '/signin';
      }
      if (isLoggedIn && onAuthScreens) {
        return '/home';
      }
      return null;
    },
  );
});

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorAKey = GlobalKey<NavigatorState>(debugLabel: 'shellA');
final _shellNavigatorBKey = GlobalKey<NavigatorState>(debugLabel: 'shellB');
final _shellNavigatorCKey = GlobalKey<NavigatorState>(debugLabel: 'shellC');
