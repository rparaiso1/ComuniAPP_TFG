// Basic smoke test for the app shell.
// Full integration tests require Hive/backend — run via `flutter test integration_test/`.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MaterialApp can be constructed', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('ComuniApp'))),
    );
    expect(find.text('ComuniApp'), findsOneWidget);
  });
}
