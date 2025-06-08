// lib/features/home/presentation/screens/home_screen.dart

import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

// Assuming these paths are correct for your project structure
import 'package:mobile_app_project_bookstore/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile_app_project_bookstore/features/books/providers/book_providers.dart';
import 'package:mobile_app_project_bookstore/features/books/domain/entities/book.dart';
import 'package:carousel_slider/carousel_slider.dart';

// --- START: Manually added TColor Class ---
class TColor {
  static Color get primary => const Color(0xff5ABD8C);
  static Color get primaryLight => const Color(0xffAFDFC7);
  static Color get text => const Color(0xff212121);
  static Color get subTitle => const Color(0xff212121).withOpacity(0.4);

  static Color get color1 => const Color(0xff1C4A7E);
  static Color get color2 => const Color(0xffC65135);

  static Color get dColor => const Color(0xffF3F3F3);

  static Color get textbox => const Color(0xffEFEFEF).withOpacity(0.6);

  static List<Color> get button => const [Color(0xff5ABD8C), Color(0xff00FF81)];

  static List<Color> get searchBGColor => const [
    Color(0xffB7143C),
    Color(0xffE6A500),
    Color(0xffEF4C45),
    Color(0xffF46217),
    Color(0xff09ADE2),
    Color(0xffD36A43),
  ];
}
// --- END: Manually added TColor Class ---

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
      if (next.user == null &&
          previous?.user != null &&
          ModalRoute.of(context)?.isCurrent == true) {
        context.goNamed('signin');
      }
    });

    final topPicksAsync = ref.watch(topPicksProvider);
    final bestsellersAsync = ref.watch(bestsellersProvider);

    // Placeholder controllers for the newsletter section
    final TextEditingController txtName = TextEditingController();
    final TextEditingController txtEmail = TextEditingController();

    var media = MediaQuery.of(context).size; // Get media size

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Align(
                  child: Transform.scale(
                    scale: 1.5,
                    origin: Offset(0, media.width * 0.8),
                    child: Container(
                      width: media.width,
                      height: media.width,
                      decoration: BoxDecoration(
                        color: TColor.primary, // Using friend's primary color
                        borderRadius: BorderRadius.circular(media.width * 0.5),
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: media.width * 0.1),
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: Row(
                        children: [
                          Text(
                            "Our Top Picks",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      leading: Container(),
                      leadingWidth: 1,
                      actions: [
                        IconButton(
                          onPressed: () {
                            // Assuming sideMenuScaffoldKey is defined elsewhere
                            // sideMenuScaffoldKey.currentState?.openEndDrawer();
                          },
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: media.width,
                      height: 280, // Kept your original height for the carousel
                      child: topPicksAsync.when(
                        data:
                            (books) => CarouselSlider.builder(
                              // Using CarouselSlider
                              itemCount: books.length,
                              itemBuilder: (
                                BuildContext context,
                                int itemIndex,
                                int pageViewIndex,
                              ) {
                                final scale = max(
                                  0.85,
                                  1 - (itemIndex - pageViewIndex).abs() * 0.3,
                                );
                                return Transform.scale(
                                  scale: scale,
                                  child: _TopPickBookTile(
                                    book: books[itemIndex],
                                  ),
                                );
                              },
                              options: CarouselOptions(
                                autoPlay: false,
                                aspectRatio: 1,
                                enlargeCenterPage: true,
                                viewportFraction:
                                    0.65, // Matches your original viewportFraction
                                enlargeFactor: 0.4,
                                enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                              ),
                            ),
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                        error:
                            (e, _) => Center(
                              child: Text(
                                'Error: $e',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _Section(title: 'Bestsellers', asyncBooks: bestsellersAsync),
            for (final genre in genres)
              _Section(
                title: genre,
                asyncBooks: ref.watch(booksByGenreProvider(genre)),
                isGenreSection: true, // Pass a flag for genre-specific styling
              ),
            SizedBox(height: media.width * 0.1),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    "Monthly Newsletter",
                    style: TextStyle(
                      color: TColor.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.maxFinite,
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              decoration: BoxDecoration(
                color: TColor.textbox.withOpacity(0.4),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Receive our monthly newsletter and receive updates on new stock, books and the occasional promotion.",
                    style: TextStyle(color: TColor.subTitle, fontSize: 12),
                  ),
                  const SizedBox(height: 15),
                  RoundTextField(controller: txtName, hintText: "Name"),
                  const SizedBox(height: 15),
                  RoundTextField(
                    controller: txtEmail,
                    hintText: "Email Address",
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MiniRoundButton(
                        title: "Sign Up",
                        onPressed: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => const SignUpView(), // You'll need to define SignUpView or remove this line
                          //   ),
                          // );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: media.width * 0.1),
          ],
        ),
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
              child:
                  book.coverImageUrl.isNotEmpty
                      ? Image.network(book.coverImageUrl, fit: BoxFit.cover)
                      : const Icon(
                        Icons.book,
                        size: 48,
                        color: Colors.grey,
                      ), // Fallback color
            ),
          ),
          const SizedBox(height: 12),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ), // Ensure text color is visible
          ),
          const SizedBox(height: 4),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: TColor.subTitle,
            ), // Using subTitle color
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final AsyncValue<List<Book>> asyncBooks;
  final bool isGenreSection; // New flag for genre section styling

  const _Section({
    required this.title,
    required this.asyncBooks,
    this.isGenreSection = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            24,
            20,
            12,
          ), // Adjusted padding
          child: Text(
            title,
            style: TextStyle(
              color: TColor.text,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          height:
              isGenreSection
                  ? MediaQuery.of(context).size.width * 0.6
                  : 240, // Adjust height for genres if needed
          child: asyncBooks.when(
            data:
                (books) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: books.length,
                  itemBuilder:
                      (_, i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child:
                            isGenreSection
                                ? _GenresCell(
                                  // For genre sections, we're passing a Book as a placeholder for genre data.
                                  // You'll need to adapt this if your genre data is different (e.g., a Genre entity).
                                  genre: books[i],
                                  bgcolor:
                                      i % 2 == 0
                                          ? TColor.color1
                                          : TColor.color2,
                                )
                                : _BookTile(book: books[i]),
                      ),
                ),
            loading:
                () => Center(
                  child: CircularProgressIndicator(color: TColor.primary),
                ), // Using primary color
            error:
                (e, _) => Center(
                  child: Text(
                    'Error: $e',
                    style: TextStyle(color: TColor.text),
                  ),
                ), // Using text color
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
                child:
                    book.coverImageUrl.isNotEmpty
                        ? Image.network(book.coverImageUrl, fit: BoxFit.cover)
                        : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.book, color: Colors.grey),
                        ), // Fallback color
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: TColor.text,
              ), // Using text color
            ),
            const SizedBox(height: 2),
            Text(
              'by ${book.author}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: TColor.subTitle,
              ), // Using subTitle color
            ),
            const SizedBox(height: 4),
            _StarRating(rating: placeholderRating),
          ],
        ),
      ),
    );
  }
}

class _GenresCell extends StatelessWidget {
  // Using Book as a placeholder for genre data.
  // Ideally, you'd have a specific `Genre` entity with `name` and `imageUrl`.
  final Book genre;
  final Color bgcolor;

  const _GenresCell({required this.genre, required this.bgcolor});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: media.width * 0.35,
      height: media.width * 0.5,
      decoration: BoxDecoration(
        color: bgcolor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Assuming you have an image for genres, or a placeholder
          genre.coverImageUrl.isNotEmpty
              ? Image.network(
                genre.coverImageUrl,
                height: 60,
                fit: BoxFit.contain,
              )
              : Icon(
                Icons.category,
                size: 60,
                color: Colors.white.withOpacity(0.8),
              ), // Placeholder icon
          const SizedBox(height: 10),
          Text(
            genre.title, // Using book title as genre name for now
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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

// --- START: Manually added RoundTextField ---
class RoundTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;

  const RoundTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TColor.textbox.withOpacity(0.4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(
            color: TColor.subTitle,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
// --- END: Manually added RoundTextField ---

// --- START: Manually added Round Buttons ---
class MiniRoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final List<Color>? colors;

  const MiniRoundButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors ?? TColor.button),
        borderRadius: BorderRadius.circular(15),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        minWidth: 100,
        height: 40,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class RoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final List<Color>? colors;

  const RoundButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors ?? TColor.button),
        borderRadius: BorderRadius.circular(25),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        minWidth: double.maxFinite,
        height: 50,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
// --- END: Manually added Round Buttons ---