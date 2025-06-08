import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_project_bookstore/features/cart/presentation/providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        // The back button will now appear automatically because of the router changes
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
              ? null // Disable button if cart is empty
              : () async {
            // TODO: Here you would add logic to save books to the user's library
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Purchase Successful!'),
                content: const Text('The books have been added to your library.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            ref.read(cartProvider.notifier).clearCart();
            // Navigate to the library
            context.goNamed('library');
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
