import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Bootstrap app (initialize services)
    await bootstrap();
    runApp(const ProviderScope(child: MyApp()));
  } catch (e) {
    // If bootstrap fails, show error
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error initializing app: $e'), // Pre-i18n: context not available here
          ),
        ),
      ),
    );
  }
}
