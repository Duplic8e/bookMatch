import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_project_bookstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:mobile_app_project_bookstore/features/library/presentation/providers/library_providers.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isProcessing = false;

  Future<void> _confirmPurchase() async {
    if (!_formKey.currentState!.validate()) return;

    final cartItems = ref.read(cartProvider);
    if (cartItems.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      await ref.read(addBooksToLibraryProvider(cartItems).future);

      if (!context.mounted) return;

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
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
      if (!context.mounted) return;
      context.goNamed('library');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter your full name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter your email';
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  return emailRegex.hasMatch(v.trim()) ? null : 'Enter a valid email';
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter your address' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter your city' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(labelText: 'Postal Code'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter postal code' : null,
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text("Card Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Card Number'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter card number';
                  if (v.trim().length != 16 || !RegExp(r'^\d+$').hasMatch(v)) return 'Enter a valid 16-digit number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _expiryController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(labelText: 'Expiry (MM/YY)'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter expiry date';
                  final regex = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
                  return regex.hasMatch(v.trim()) ? null : 'Use MM/YY format';
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cvvController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'CVV'),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter CVV';
                  if (v.trim().length != 3 || !RegExp(r'^\d{3}$').hasMatch(v)) return 'Enter 3-digit CVV';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : const Text('Confirm Purchase'),
                onPressed: _isProcessing ? null : _confirmPurchase,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
