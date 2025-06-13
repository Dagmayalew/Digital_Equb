import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';
import 'notifier/locale_notifier.dart';
import 'screen/login_screen.dart';
import 'screen/home_screen.dart';
import 'screen/equb_list_screen.dart';
import 'theme/theme_notifier.dart';
import 'notifier/user_notifier.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => UserNotifier()),
        ChangeNotifierProvider(create: (_) => LocaleNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeNotifier = Provider.of<LocaleNotifier>(context);

    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) {
        return MaterialApp(
          title: 'Equb App',
          theme: themeNotifier.currentTheme,
          locale: localeNotifier.locale,  // <-- set current locale here
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          initialRoute: LoginScreen.routeName,
          routes: {
            LoginScreen.routeName: (context) => LoginScreen(),
            HomeScreen.routeName: (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              if (args is Map<String, dynamic>) {
                final userNotifier = Provider.of<UserNotifier>(context, listen: false);
                userNotifier.setUser(args);
                return HomeScreen(user: args);
              } else {
                return LoginScreen();
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
