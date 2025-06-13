import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:updated_digital_equb_new/main.dart';
import 'package:updated_digital_equb_new/theme/theme_notifier.dart';
import 'package:updated_digital_equb_new/notifier/user_notifier.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeNotifier()),
          ChangeNotifierProvider(create: (_) => UserNotifier()),
        ],
        child: const MyApp(),
      ),
    );

    // Example test: Check if LoginScreen is shown
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
