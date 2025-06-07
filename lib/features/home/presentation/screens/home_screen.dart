// lib/features/home/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

import 'package:mobile_app_project_bookstore/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile_app_project_bookstore/features/books/providers/book_providers.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<String> genres = [
    'Fiction',
    'Mystery',
    'Science Fiction',
    'Romance',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    ref.listen<AuthScreenState>(authNotifierProvider, (previous, next) {
      if (next.user == null && previous?.user != null && ModalRoute.of(context)?.isCurrent == true) {
        context.goNamed('signin');
      }
    });

    final topPicksAsync = ref.watch(topPicksProvider);
    final bestsellersAsync = ref.watch(bestsellersProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _Header(asyncBooks: topPicksAsync),
          Padding(
            padding: const EdgeInsets.only(top: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Section(
                    title: 'Bestsellers',
                    asyncBooks: bestsellersAsync,
                  ),
                  for (final genre in genres)
                    _Section(
                      title: genre,
                      asyncBooks: ref.watch(booksByGenreProvider(genre)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AsyncValue<List<Book>> asyncBooks;
  const _Header({required this.asyncBooks});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        height: 450,
        color: const Color(0xFF6FCF97),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    Text(
                      'Our Top Picks',
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _TopPicksCarousel(asyncBooks: asyncBooks),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopPicksCarousel extends StatefulWidget {
  final AsyncValue<List<Book>> asyncBooks;
  const _TopPicksCarousel({required this.asyncBooks});

  @override
  _TopPicksCarouselState createState() => _TopPicksCarouselState();
}

class _TopPicksCarouselState extends State<_TopPicksCarousel> {
  late final PageController _pageController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.65, initialPage: 1)
      ..addListener(() {
        setState(() {
          _currentPage = _pageController.page ?? 0;
        });
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.asyncBooks.when(
      data: (books) => SizedBox(
        height: 280,
        child: PageView.builder(
          controller: _pageController,
          itemCount: books.length,
          itemBuilder: (context, index) {
            final scale = max(0.85, 1 - (_currentPage - index).abs() * 0.3);
            return Transform.scale(
              scale: scale,
              child: _TopPickBookTile(
                book: books[index],
              ),
            );
          },
        ),
      ),
      loading: () => const SizedBox(
        height: 280,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
      error: (e, _) => SizedBox(
        height: 280,
        child: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
      ),
    );
  }
}

class _TopPickBookTile extends StatelessWidget {
  final Book book;
  const _TopPickBookTile({required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/books/${book.id}'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: book.coverImageUrl.isNotEmpty
                  ? Image.network(
                book.coverImageUrl,
                fit: BoxFit.cover,
              )
                  : const Icon(Icons.book, size: 48),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          // UPDATE: Using the real `book.author` field from your Book class.
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final AsyncValue<List<Book>> asyncBooks;

  const _Section({required this.title, required this.asyncBooks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 240,
          child: asyncBooks.when(
            data: (books) => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: books.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _BookTile(book: books[i]),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }
}

class _BookTile extends StatelessWidget {
  final Book book;
  const _BookTile({required this.book});

  @override
  Widget build(BuildContext context) {
    // FIX: Generate a placeholder rating because it's not in the Book class.
    // This prevents the app from crashing.
    final placeholderRating = (book.title.length % 4) + 1.5;

    return GestureDetector(
      onTap: () => context.go('/books/${book.id}'),
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              width: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: book.coverImageUrl.isNotEmpty
                    ? Image.network(book.coverImageUrl, fit: BoxFit.cover)
                    : Container(color: Colors.grey[200], child: const Icon(Icons.book)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            // UPDATE: Using the real `book.author` field from your Book class.
            Text(
              'by ${book.author}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            // Using the placeholder rating to display stars.
            _StarRating(rating: placeholderRating),
          ],
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final double rating;
  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.round() ? Icons.star : Icons.star_border,
          size: 16,
          color: Colors.amber,
        );
      }),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}