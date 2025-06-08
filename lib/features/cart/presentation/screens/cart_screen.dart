import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_project_bookstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:mobile_app_project_bookstore/features/library/presentation/providers/library_providers.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart (${cartItems.length})'),
      ),
      body: cartItems.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Your cart is empty.', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return ListTile(
            leading: Image.network(item.book.coverImageUrl, width: 50, fit: BoxFit.cover),
            title: Text(item.book.title),
            subtitle: Text(item.book.authors.join(', ')),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () {
                ref.read(cartProvider.notifier).removeFromCart(item.book.id);
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: cartItems.isEmpty
              ? null
              : () async {
            try {
              // Call the provider to add books to the library
              await ref.read(addBooksToLibraryProvider(cartItems).future);

              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Purchase Successful!'),
                  content: const Text('The books have been added to your library.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );

              ref.read(cartProvider.notifier).clearCart();
              context.goNamed('library');

            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}'))
              );
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Checkout (Free)'),
        ),
      ),
    );
  }
}
