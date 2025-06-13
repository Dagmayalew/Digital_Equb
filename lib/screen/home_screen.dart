import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
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
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.home),
        actions: [
          IconButton(
            icon: Icon(themeNotifier.currentBrightness == Brightness.dark
                ? Icons.wb_sunny
                : Icons.nightlight),
            onPressed: themeNotifier.toggleTheme,
          ),
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
            Text(
              "${locale.greeting}, ${widget.user['name']}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.pushNamed(context, EqubListScreen.routeName);
                if (result != null) {
                  addJoinedEqub(result as Map<String, dynamic>);
                }
              },
              icon: const Icon(Icons.group_add),
              label: Text(locale.joinEqub),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(MediaQuery.of(context).size.width, 50),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              locale.joinedEqubs,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: joinedEqubs.isEmpty
                  ? Center(child: Text(locale.noEqubsJoined))
                  : ListView.builder(
                itemCount: joinedEqubs.length,
                itemBuilder: (context, index) {
                  final equb = joinedEqubs[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(equb['name']),
                      subtitle: Text(
                        "${equb['contributionAmount']} ${locale.by} ${equb['frequency']}",
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
