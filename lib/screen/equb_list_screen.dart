import 'package:flutter/material.dart';
import '../utils/json_loader.dart';

class EqubListScreen extends StatefulWidget {
  static const routeName = '/equb-list';

  const EqubListScreen({super.key});

  @override
  _EqubListScreenState createState() => _EqubListScreenState();
}

class _EqubListScreenState extends State<EqubListScreen> {
  late Future<List<Map<String, dynamic>>> equbGroups;

  @override
  void initState() {
    super.initState();
    equbGroups = loadEqubGroups(); // This function should be defined in json_loader.dart
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("የእቁብ ዝርዝር"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: equbGroups,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final equbList = snapshot.data!;
            return ListView.builder(
              itemCount: equbList.length,
              itemBuilder: (context, index) {
                final equb = equbList[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                    title: Text(equb['name']),
                    subtitle: Text("${equb['contributionAmount']} በ ${equb['frequency']}"),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Return selected equb back to home screen
                        Navigator.pop(context, equb);
                      },
                      child: const Text("አገባ"),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error loading Equb groups: ${snapshot.error}');
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}