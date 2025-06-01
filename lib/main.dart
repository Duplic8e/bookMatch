import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookmatch/core/navigation/app_router.dart';
import 'package:bookmatch/core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: KetaBookApp()));
}

class KetaBookApp extends ConsumerWidget {
  const KetaBookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = createRouter(ref);

    return MaterialApp.router(
      title: 'KetaBook',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
