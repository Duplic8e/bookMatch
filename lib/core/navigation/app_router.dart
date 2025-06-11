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
import 'package:mobile_app_project_bookstore/features/community/screens/community_screen.dart';
import 'package:mobile_app_project_bookstore/features/community/screens/create_post_screen.dart';
import 'package:mobile_app_project_bookstore/features/community/screens/post_details_screen.dart';
import 'package:mobile_app_project_bookstore/features/home/presentation/screens/home_screen.dart';
import 'package:mobile_app_project_bookstore/features/home/presentation/screens/scaffold_with_nested_navigation.dart';
import 'package:mobile_app_project_bookstore/features/library/presentation/screens/library_screen.dart';
import 'package:mobile_app_project_bookstore/core/navigation/go_router_refresh_stream.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authStateStream = ref.watch(authStateChangesProvider.stream);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: GoRouterRefreshStream(authStateStream),
    redirect: (BuildContext context, GoRouterState state) {
      final loggedIn = ref.read(authRepositoryProvider).currentUser != null;
      final onAuthRoute = state.matchedLocation == '/signin' || state.matchedLocation == '/signup';

      if (!loggedIn && !onAuthRoute) return '/signin';
      if (loggedIn && onAuthRoute) return '/home';

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ScaffoldWithNestedNavigation(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(path: '/home', name: 'home', pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen())),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCommunityKey,
            routes: [
              GoRoute(
                  path: '/community', name: 'community',
                  pageBuilder: (context, state) => const NoTransitionPage(child: CommunityScreen()),
                  routes: [
                    GoRoute(
                      path: 'post/:postId', name: 'postDetails',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) => PostDetailsScreen(postId: state.pathParameters['postId']!),
                    )
                  ]
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorLibraryKey,
            routes: [
              GoRoute(path: '/library', name: 'library', pageBuilder: (context, state) => const NoTransitionPage(child: LibraryScreen())),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(path: '/profile', name: 'profile', pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen())),
            ],
          ),
        ],
      ),
      GoRoute(path: '/signin', name: 'signin', builder: (context, state) => const SignInScreen()),
      GoRoute(path: '/signup', name: 'signup', builder: (context, state) => const SignUpScreen()),
      GoRoute(path: '/cart', name: 'cart', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const CartScreen()),
      GoRoute(path: '/book/:id', name: 'bookDetails', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => BookDetailScreen(bookId: state.pathParameters['id']!)),
      GoRoute(
        path: '/book/:id/preview', name: 'bookPreview',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final bookId = state.pathParameters['id']!;
          final args = state.extra as Map<String, dynamic>? ?? {};
          return BookPreviewScreen(
            bookId: bookId,
            pdfUrl: args['url'] ?? '',
            bookTitle: args['title'] ?? 'PDF',
            initialPage: args['initialPage'] ?? 1,
            isFromLibrary: args['isFromLibrary'] ?? false,
          );
        },
      ),
      GoRoute(
        path: '/create-post', name: 'createPost',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final bookCitation = state.extra as Map<String, dynamic>?;
          return CreatePostScreen(bookCitation: bookCitation);
        },
      ),
    ],
  );
});

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorCommunityKey = GlobalKey<NavigatorState>(debugLabel: 'shellCommunity');
final _shellNavigatorLibraryKey = GlobalKey<NavigatorState>(debugLabel: 'shellLibrary');
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

