import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app_project_bookstore/features/cart/presentation/providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Cart (${cartItems.length})',
          style: theme.textTheme.titleMedium,
        ),
      ),
      body: cartItems.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'Your cart is empty.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                item.book.coverImageUrl,
                width: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.book, size: 50),
              ),
            ),
            title: Text(
              item.book.title,
              style: GoogleFonts.merriweather(textStyle: theme.textTheme.titleMedium),
            ),
            subtitle: Text(
              item.book.authors.join(', '),
              style: GoogleFonts.merriweather(textStyle: theme.textTheme.bodySmall!),
            ),
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
              : () => context.pushNamed('checkout'), // ✅ Navigate to checkout screen
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: theme.textTheme.titleMedium,
          ),
          child: const Text('Checkout (Free)'),
        ),
      ),
    );
  }
}
