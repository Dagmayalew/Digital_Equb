import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../notifier/locale_notifier.dart';
import '../theme/theme_notifier.dart';
import 'equb_list_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  final Map<String, dynamic> user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> joinedEqubs = [];

  void addJoinedEqub(Map<String, dynamic> equb) {
    setState(() {
      if (!joinedEqubs.any((e) => e['id'] == equb['id'])) {
        joinedEqubs.add(equb);
      }
    });
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'), // Static title
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(themeNotifier.currentBrightness == Brightness.dark
                ? Icons.wb_sunny
                : Icons.nightlight),
            onPressed: themeNotifier.toggleTheme,
          ),
          // Language toggle button - optional to remove if not needed
          // Remove if you don't want to toggle language
          /*
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Switch Language',
            onPressed: () {
              final currentLocale = Provider.of<LocaleNotifier>(context, listen: false).locale;
              if (currentLocale.languageCode == 'en') {
                Provider.of<LocaleNotifier>(context, listen: false).setLocale(Locale('am'));
              } else {
                Provider.of<LocaleNotifier>(context, listen: false).setLocale(Locale('en'));
              }
            },
          ),
          */
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Static greeting text
            Text(
              "Hello, ${widget.user['name']}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                    context, EqubListScreen.routeName);
                if (result != null) {
                  addJoinedEqub(result as Map<String, dynamic>);
                }
              },
              icon: const Icon(Icons.group_add),
              label: const Text('Join Equb'), // Static label
              style: ElevatedButton.styleFrom(
                minimumSize: Size(MediaQuery.of(context).size.width, 50),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Joined Equbs', // Static header
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: joinedEqubs.isEmpty
                  ? const Center(child: Text('No Equbs joined'))
                  : ListView.builder(
                itemCount: joinedEqubs.length,
                itemBuilder: (context, index) {
                  final equb = joinedEqubs[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(equb['name']),
                      subtitle: Text(
                        "${equb['contributionAmount']} by ${equb['frequency']}",
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}