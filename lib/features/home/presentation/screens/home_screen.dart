// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_project_bookstore/features/auth/presentation/providers/auth_providers.dart';
// Make sure this import is correct and points to where allBooksProvider is defined
import 'package:mobile_app_project_bookstore/features/books/presentation/providers/book_providers.dart';
// For using the Book type

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for user state changes from AuthNotifier to react to sign-out
    final authNotifier = ref.read(authNotifierProvider.notifier);
    // Use watch to rebuild if authState changes, e.g. user logs out
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AuthScreenState>(authNotifierProvider, (previous, next) {
      // If the user becomes null (signed out) and we are on the home screen, navigate to signin
      // Check if the current route is the home screen to prevent navigation if already navigating away
      final currentRoute = ModalRoute.of(context);
      if (next.user == null &&
          previous?.user != null &&
          currentRoute != null &&
          currentRoute.isCurrent) {
        // Ensure we are on a route that can be popped or replaced by goNamed
        // and not in the middle of a transition.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ModalRoute.of(context)?.isCurrent == true) {
            context.goNamed('signin');
          }
        });
      }
    });

    // Watch the allBooksProvider
    final booksAsyncValue = ref.watch(allBooksProvider);
    final userEmail = authState.user?.email ?? "Loading...";

    return Scaffold(
      appBar: AppBar(
        title: const Text('KetaBook Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to profile screen
              // Ensure you have a 'profile' route defined in GoRouter
              context.goNamed('profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      TextButton(
                        child: const Text('Sign Out'),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  );
                },
              );

              if (confirmed == true) {
                await authNotifier.signOutUser();
                // Navigation to 'signin' is handled by the ref.listen above.
                // No need for explicit navigation here if the listener is robust.
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0), // Increased padding a bit
            child: Text(
              'You are signed in as: $userEmail',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: booksAsyncValue.when(
              data: (books) {
                if (books.isEmpty) {
                  return const Center(child: Text('No books available right now.'));
                }
                // Using GridView for a more bookstore-like feel, similar to previous example
                return GridView.builder(
                  padding: const EdgeInsets.all(12.0), // Added padding around the grid
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    childAspectRatio: 0.65, // Adjust for better item proportions (width / height)
                    crossAxisSpacing: 12.0, // Spacing between items horizontally
                    mainAxisSpacing: 12.0,  // Spacing between items vertically
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return Card(
                      elevation: 2.0, // Subtle shadow
                      clipBehavior: Clip.antiAlias, // Ensures content respects card boundaries
                      child: InkWell(
                        onTap: () {
                          // Navigate to book detail screen
                          // Ensure book.id is a non-empty string
                          if (book.id.isNotEmpty) {
                            context.go('/books/${book.id}');
                          } else {
                            // Handle case where book ID might be missing, though unlikely
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Error: Book ID is missing.'))
                            );
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch, // Make children fill width
                          children: [
                            Expanded(
                              flex: 3, // Give more space to image
                              child: Hero(
                                tag: 'bookCover-${book.id}', // Unique tag for Hero animation
                                child: book.imageUrl.isNotEmpty
                                    ? Image.network(
                                  book.imageUrl,
                                  fit: BoxFit.cover,
                                  // Loading builder for smoother image loading
                                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: Colors.grey[200],
                                        child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                                      ),
                                )
                                    : Container( // Placeholder if no image
                                  color: Colors.grey[200],
                                  child: const Center(child: Icon(Icons.book, size: 50, color: Colors.grey)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0), // Adjusted padding
                              child: Text(
                                book.title,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 2, // Allow for slightly longer titles
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                book.author,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0), // Adjusted padding
                              child: Text(
                                '\$${book.price.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) {
                // You might want to log the stackTrace as well for debugging
                print('Error loading books: $error');
                print(stackTrace);
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Failed to load books. Please try again later.\nError: $error', textAlign: TextAlign.center),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}