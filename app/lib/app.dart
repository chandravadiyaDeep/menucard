import 'package:flutter/material.dart';

import 'data/menu_repository.dart';
import 'features/home/home_screen.dart';

class MenuCardApp extends StatelessWidget {
  const MenuCardApp({super.key, required this.repository});

  final MenuRepository repository;

  @override
  Widget build(BuildContext context) {
    const forest = Color(0xFF173F33);
    const paper = Color(0xFFF5F4EF);
    return MaterialApp(
      title: 'MenuCard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: forest,
          primary: forest,
          surface: const Color(0xFFFFFEFA),
        ),
        scaffoldBackgroundColor: paper,
        appBarTheme: const AppBarTheme(
          backgroundColor: paper,
          foregroundColor: Color(0xFF17231D),
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFFEFA),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xFFE7E5DC)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFFEFA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE7E5DC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE7E5DC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: forest, width: 1.5),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: forest,
            foregroundColor: Colors.white,
            minimumSize: const Size(48, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xFFFFFEFA),
          indicatorColor: Color(0xFFDCE9E1),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),
      home: HomeScreen(repository: repository),
    );
  }
}

class MenuCardStartupError extends StatelessWidget {
  const MenuCardStartupError({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFFF5F4EF),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 54, color: Color(0xFF9B4A36)),
                  const SizedBox(height: 18),
                  const Text('Your menu needs recovery', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  const Text('MenuCard could not safely read its saved JSON file. Your data has not been reset. Keep the app data intact and contact support.'),
                  const SizedBox(height: 12),
                  Text(error.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              ),
            ),
          ),
        ),
      );
}
