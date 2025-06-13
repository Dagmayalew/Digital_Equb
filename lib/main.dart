import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screen/login_screen.dart';
import 'screen/home_screen.dart';
import 'screen/main_screen.dart';
import 'theme/theme_notifier.dart';
import 'notifier/user_notifier.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => UserNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Equb App',
      theme: themeNotifier.currentTheme,
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        HomeScreen.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map<String, dynamic>) {
            // Set the user in UserNotifier upon successful login
            final userNotifier = Provider.of<UserNotifier>(context, listen: false);
            userNotifier.setUser(args);
            return const HomeScreen();
          } else {
            return const LoginScreen(); // Fallback if no user data is passed
          }
        },
        // MainScreen now directly accesses user data from UserNotifier
        MainScreen.routeName: (context) => const MainScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}