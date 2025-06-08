// lib/common_widgets/genres_cell.dart

import 'package:flutter/material.dart';
import 'package:mobile_app_project_bookstore/common/color_extension.dart';

/// A simple cell for displaying a genre with its image and name
class GenresCell extends StatelessWidget {
  final Map<String, dynamic> iObj;
  final Color? bgcolor;

  const GenresCell({
    Key? key,
    required this.iObj,
    this.bgcolor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: media.width * 0.32,
      decoration: BoxDecoration(
        color: bgcolor ?? Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.asset(
              iObj['img'].toString(),
              width: double.infinity,
              height: media.width * 0.20,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              iObj['name'].toString(),
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.text,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
