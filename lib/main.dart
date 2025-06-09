import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_app_project_bookstore/Core/navigation/app_router.dart';
import 'package:mobile_app_project_bookstore/Core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();

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
    // Watch the new provider for the router instance
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'KetaBook',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      // Use the routerConfig property
      routerConfig: router,
      // No need for routerDelegate or routeInformationParser when using routerConfig
    );
  }
}
