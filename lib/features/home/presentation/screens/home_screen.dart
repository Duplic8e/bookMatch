import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app_project_bookstore/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile_app_project_bookstore/features/books/presentation/providers/book_providers.dart';
import 'package:mobile_app_project_bookstore/features/search/screens/search_overlay.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  double _scrollOffset = 0;
  int _selectedCategoryIndex = 0;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  static const _assetPath = 'lib/features/home/assets/';
  final _categories = const [
    {'asset': '${_assetPath}all.png',       'label': 'All'},
    {'asset': '${_assetPath}001-wizard.png','label': 'Fantasy'},
    {'asset': '${_assetPath}002-book.png',  'label': 'Fiction'},
    {'asset': '${_assetPath}003-new.png',   'label': 'New'},
    {'asset': '${_assetPath}004-girl.png',  'label': 'Manga'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onCategoryTap(int idx) {
    setState(() => _selectedCategoryIndex = idx);
  }

  bool _onScrollNotification(ScrollNotification n) {
    if (n.metrics.axis == Axis.vertical) {
      setState(() => _scrollOffset = n.metrics.pixels);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme           = Theme.of(context);
    final booksAsyncValue = ref.watch(allBooksProvider);
    final userName        = ref.watch(authRepositoryProvider).currentUser?.displayName ?? 'there';

    final sections = <Widget>[];
    if (_selectedCategoryIndex == 0) {
      for (var cat in _categories) {
        sections.add(_SectionCarousel(
          title: cat['label']!,
          booksAsync: booksAsyncValue,
        ));
      }
    } else {
      final cat = _categories[_selectedCategoryIndex];
      sections.add(_SectionCarousel(
        title: cat['label']!,
        booksAsync: booksAsyncValue,
      ));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: Stack(
          children: [
            Positioned(
              top: -100 + _scrollOffset * 0.5,
              left: -80 + _scrollOffset * 0.3,
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withOpacity(0.30),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -120 + _scrollOffset * 0.25,
              right: -60 + _scrollOffset * 0.15,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.secondary.withOpacity(0.30),
                ),
              ),
            ),
            Positioned(
              top: 50 - _scrollOffset * 0.35,
              right: -50 + _scrollOffset * 0.2,
              child: Transform.rotate(
                angle: math.pi / 4,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 300 - _scrollOffset * 0.45,
              left: -40 + _scrollOffset * 0.25,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.25),
                ),
              ),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => context.pushNamed('profile'),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundImage: const AssetImage('${_assetPath}avatar.png'),
                          ),
                        ),
                        IconButton(
                          icon: Image.asset('${_assetPath}006-cart.png', width: 28, height: 28),
                          onPressed: () => context.pushNamed('cart'),
                          tooltip: 'Cart',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hi, $userName!',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      readOnly: true,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => const SearchOverlay(),
                        );
                      },
                      decoration: InputDecoration(
                        hintText: 'Search for books',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Image.asset('${_assetPath}005-search.png', width: 24, height: 24),
                        ),
                        fillColor: theme.colorScheme.surface,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      height: 88,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final cat = _categories[i];
                          final selected = i == _selectedCategoryIndex;
                          return GestureDetector(
                            onTap: () => _onCategoryTap(i),
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(selected ? 16 : 12),
                                  ),
                                  child: Image.asset(cat['asset']!, width: 28, height: 28),
                                ),
                                const SizedBox(height: 8),
                                Text(cat['label']!, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...sections,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCarousel extends StatelessWidget {
  final String title;
  final AsyncValue<List<dynamic>> booksAsync;

  const _SectionCarousel({
    required this.title,
    required this.booksAsync,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ← Title row (All, Fantasy, Fiction, etc.)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.merriweather(
                  textStyle: theme.textTheme.titleMedium!,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: implement “View All” behavior if needed
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.merriweather(
                    textStyle: theme.textTheme.bodyMedium!,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ← The horizontal book carousel
        SizedBox(
          height: 260,
          child: booksAsync.when(
            data: (books) => ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: books.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, idx) {
                final book = books[idx];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.pushNamed(
                      'bookDetails',
                      pathParameters: {'bookId': book.id},
                    ),
                    child: _BookCard(book: book),
                  ),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(
              child: Text(
                'Failed to load books.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.error),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

class _BookCard extends StatelessWidget {
  final dynamic book;
  const _BookCard({required this.book, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'book-cover-${book.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: book.coverImageUrl.isNotEmpty
                  ? Image.network(
                      book.coverImageUrl,
                      height: 180,
                      width: 140,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 180,
                      width: 140,
                      color: Colors.grey[200],
                      child: const Icon(Icons.book,
                          size: 50, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.title,
            style: GoogleFonts.merriweather(
              textStyle: theme.textTheme.bodyMedium!,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            (book.authors as List<dynamic>).join(', '),
            style: GoogleFonts.merriweather(
              textStyle: theme.textTheme.bodySmall!,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
