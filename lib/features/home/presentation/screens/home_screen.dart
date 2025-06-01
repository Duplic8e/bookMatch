import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:bookmatch/features/auth/presentation/providers/auth_providers.dart'; // Assuming this path

// CORRECTED import path for book_providers.dart
import 'package:bookmatch/features/books/providers/book_providers.dart'; // CORRECTED import path for Book entity
import 'package:bookmatch/features/books/domain/entities/book.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for user state changes from AuthNotifier to react to sign-out
    final authNotifier = ref.read(authNotifierProvider.notifier);
    ref.listen<AuthScreenState>(authNotifierProvider, (previous, next) {
      // If the user becomes null (signed out) and we are on the home screen, navigate to signin
      if (next.user == null &&
          previous?.user != null &&
          ModalRoute.of(context)?.isCurrent == true) {
        context.goNamed('signin');
      }
    });

    final booksAsyncValue = ref.watch(
      allBooksProvider,
    ); // Uses allBooksProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text('KetaBook Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Placeholder for profile navigation or action
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Make it async
              // Show a confirmation dialog (optional but good UX)
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
                          Navigator.of(context).pop(false); // Return false
                        },
                      ),
                      TextButton(
                        child: const Text('Sign Out'),
                        onPressed: () {
                          Navigator.of(context).pop(true); // Return true
                        },
                      ),
                    ],
                  );
                },
              );

              if (confirmed == true) {
                await authNotifier.signOutUser();
                // Navigation to 'signin' is now handled by the ref.listen above
                // For robustness, you could add it here as a fallback if the listener doesn't fire as expected
                // if (ref.read(authNotifierProvider).user == null) {
                //   context.goNamed('signin');
                // }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'You are signed in as: ${ref.watch(authNotifierProvider).user?.email ?? "Loading..."}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: booksAsyncValue.when(
              data: (books) {
                if (books.isEmpty) {
                  return const Center(child: Text('No books available.'));
                }
                return ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book =
                        books[index]; // book is of type Book from domain/entities
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Hero(
                          tag: 'bookCover-${book.id}',
                          child:
                              book.coverImageUrl.isNotEmpty
                                  ? Image.network(
                                    book.coverImageUrl,
                                    fit: BoxFit.cover,
                                    width: 50,
                                    height: 70,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 50,
                                            ),
                                  )
                                  : const Icon(Icons.book, size: 50),
                        ),
                        title: Text(book.title),
                        subtitle: Text(book.author),
                        trailing: Text('\$${book.price.toStringAsFixed(2)}'),
                        onTap: () {
                          // Navigation path remains the same, GoRouter handles resolution
                          context.go('/books/${book.id}');
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stackTrace) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
