import 'package:flutter/material.dart';
import 'package:habit_tracker/providers/theme_provider.dart';
import 'package:habit_tracker/ui/main_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data/database/database.dart';
import 'data/providers/database_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeProviderState = ref.watch(themeProvider);
    final themeProviderNotifier = ref.read(themeProvider.notifier);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker',
      theme: themeProviderNotifier.lightTheme,
      darkTheme: themeProviderNotifier.darkTheme,
      themeMode: themeProviderState,
      home: const MainPage(),
    );
  }
}
