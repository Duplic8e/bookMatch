import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_app_project_bookstore/Core/navigation/app_router.dart';
import 'package:mobile_app_project_bookstore/Core/theme/app_theme.dart';
import 'package:mobile_app_project_bookstore/Core/theme/theme_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ** NEW: Initialize Hive and open our theme box **
  await Hive.initFlutter();
  await Hive.openBox(themeBoxName);

  runApp(
    const ProviderScope(
      child: KetaBookApp(),
    ),
  );
}

class KetaBookApp extends ConsumerWidget {
  const KetaBookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    // ** NEW: Watch our theme provider for the current theme mode **
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      title: 'KetaBook',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // ** CHANGE: Use the state from our provider **
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
