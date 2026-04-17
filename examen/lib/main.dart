import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'presentation/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _configureDesktopDatabase();
  runApp(const ProviderScope(child: MyApp()));
}

void _configureDesktopDatabase() {
  if (kIsWeb) {
    return;
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      break;
    case TargetPlatform.android:
    case TargetPlatform.iOS:
    case TargetPlatform.fuchsia:
      break;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Academia App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F4),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
