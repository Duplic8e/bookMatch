import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue, // Or your preferred primary color
      // Example: Customize AppBar
      appBarTheme: const AppBarTheme(
        elevation: 1,
        backgroundColor: Colors.white, // Or Colors.blue
        iconTheme: IconThemeData(color: Colors.black), // For icons like back arrow
        titleTextStyle: TextStyle(
          color: Colors.black, // Title text color
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      // Example: Customize ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, // Button background
          foregroundColor: Colors.white, // Button text/icon color
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      // Example: Customize TextFormFields
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.blueGrey),
      ),
      // Add more customizations as needed
    );
  }

  // --- THIS IS THE CRITICAL PART ---
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.teal, // Or your preferred dark theme primary color
      scaffoldBackgroundColor: Colors.grey[900], // Dark background
      // Example: Customize AppBar for dark theme
      appBarTheme: AppBarTheme(
        elevation: 1,
        backgroundColor: Colors.grey[850], // Darker AppBar
        iconTheme: const IconThemeData(color: Colors.white), // Icons
        titleTextStyle: TextStyle(
          color: Colors.white, // Title text
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      // Example: Customize ElevatedButton for dark theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      // Example: Customize TextFormFields for dark theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.teal.shade300, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade400),
        hintStyle: TextStyle(color: Colors.grey.shade500),
        // Ensure text input color is also visible
        fillColor: Colors.grey[800], // Optional: for filled variant
      ),
      // Ensure text colors are legible in dark mode
      textTheme: Typography.whiteMountainView.apply(
        bodyColor: Colors.white70, // Default body text
        displayColor: Colors.white, // Headlines
      ),
      // Add more customizations as needed
    );
  }
  // --- END OF CRITICAL PART ---
}