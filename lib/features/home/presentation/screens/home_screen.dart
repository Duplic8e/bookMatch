// lib/features/home/presentation/screens/home_screen.dart

import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mobile_app_project_bookstore/common/color_extension.dart';
import 'package:mobile_app_project_bookstore/common_widgets/top_picks_cell.dart';
import 'package:mobile_app_project_bookstore/common_widgets/best_seller_cell.dart';
import 'package:mobile_app_project_bookstore/common_widgets/round_textfield.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController txtName = TextEditingController();
  final TextEditingController txtEmail = TextEditingController();

  final List<Map<String, dynamic>> topPicksArr = [
    {"name": "The Dissapearance of Emila Zola", "author": "Michael Rosen", "img": "assets/img/1.jpg"},
    {"name": "Fatherhood",                      "author": "Marcus Berkmann", "img": "assets/img/2.jpg"},
    {"name": "The Time Travellers Handbook",     "author": "Stride Lottie",   "img": "assets/img/3.jpg"},
  ];

  final List<Map<String, dynamic>> bestArr = [
    {"name": "Fatherhood",              "author": "by Christopher Wilson", "img": "assets/img/4.jpg",  "rating": 5.0},
    {"name": "In A Land Of Paper Gods", "author": "by Rebecca Mackenzie",    "img": "assets/img/5.jpg",  "rating": 4.0},
    {"name": "Tattletale",              "author": "by Sarah J. Noughton",   "img": "assets/img/6.jpg",  "rating": 3.0},
  ];

  final List<String> genres = ["Fiction", "Mystery", "Sci-Fi"];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Green curved header
          ClipPath(
            clipper: _HeaderClipper(),
            child: Container(
              height: media.width * 0.6,
              color: TColor.primary,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reduced top padding
                SizedBox(height: media.width * 0.1),

                // Top Picks title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Our Top Picks",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                // Top Picks carousel
                SizedBox(
                  height: media.width * 0.5,
                  child: CarouselSlider.builder(
                    itemCount: topPicksArr.length,
                    itemBuilder: (context, index, _) => TopPicksCell(iObj: topPicksArr[index]),
                    options: CarouselOptions(
                      autoPlay: false,
                      aspectRatio: 1,
                      enlargeCenterPage: true,
                      viewportFraction: 0.45,
                      enlargeFactor: 0.4,
                      enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                      height: media.width * 0.5,
                    ),
                  ),
                ),

                // Smaller gap before next section
                const SizedBox(height: 8),

                // Global Bestsellers
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Bestsellers",
                    style: TextStyle(
                      color: TColor.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  height: media.width * 0.9,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    itemCount: bestArr.length,
                    itemBuilder: (context, index) => BestSellerCell(bObj: bestArr[index]),
                  ),
                ),

                // Even smaller spacing between genre rows
                for (var genre in genres) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      genre,
                      style: TextStyle(
                        color: TColor.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: media.width * 0.9,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      itemCount: bestArr.length, // swap with genre-specific list
                      itemBuilder: (context, index) => BestSellerCell(bObj: bestArr[index]),
                    ),
                  ),
                ],

                // Reduced bottom padding before newsletter
                const SizedBox(height: 16),

                // Monthly Newsletter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Monthly Newsletter",
                    style: TextStyle(
                      color: TColor.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  padding: const EdgeInsets.all(15),
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
                      const SizedBox(height: 10),
                      RoundTextField(controller: txtName, hintText: "Name"),
                      const SizedBox(height: 10),
                      RoundTextField(controller: txtEmail, hintText: "Email Address"),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.lineTo(0, size.height - 40);
    p.quadraticBezierTo(
      size.width * 0.5, size.height,
      size.width, size.height - 40,
    );
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> old) => false;
}
