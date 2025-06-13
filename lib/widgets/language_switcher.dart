// lib/widgets/language_switcher.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifier/locale_notifier.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final localeNotifier = Provider.of<LocaleNotifier>(context);

    return DropdownButtonHideUnderline(
      child: DropdownButton<Locale>(
        value: localeNotifier.locale,
        icon: const Icon(Icons.language, color: Colors.white),
        onChanged: (Locale? newLocale) {
          if (newLocale != null) {
            localeNotifier.setLocale(newLocale);
          }
        },
        items: const [
          DropdownMenuItem(
            value: Locale('en'),
            child: Text('English'),
          ),
          DropdownMenuItem(
            value: Locale('am'),
            child: Text('አማርኛ'),
          ),
        ],
      ),
    );
  }
}
