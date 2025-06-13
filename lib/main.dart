import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Optional, later
import 'package:updated_digital_equb_new/screen/equb_list_screen.dart';

import 'screen/login_screen.dart';
import 'screen/home_screen.dart';
import 'theme/theme_notifier.dart';
import 'notifier/user_notifier.dart'; // 👈 Import added here

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => UserNotifier()), // ✅ Add UserNotifier
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) {
        return MaterialApp(
          title: 'Equb App',
          theme: themeNotifier.currentTheme,
          initialRoute: LoginScreen.routeName,
          routes: {
            LoginScreen.routeName: (context) =>  LoginScreen(),
            HomeScreen.routeName: (context) {
              final args = ModalRoute.of(context)?.settings.arguments;

              if (args is Map<String, dynamic>) {
                final userNotifier = Provider.of<UserNotifier>(context, listen: false);
                userNotifier.setUser(args); // ✅ Set user globally
                return HomeScreen(user: args);
              } else {
                return  LoginScreen(); // Fallback
              }
            },
            EqubListScreen.routeName: (context) => const EqubListScreen(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}