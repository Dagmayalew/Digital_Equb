import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:updated_digital_equb_new/models/equb.dart'; // Ensure this import is correct
import '../notifier/user_notifier.dart';
import '../utils/json_loader.dart';
import 'equb_detail_screen.dart'; // Make sure this screen expects Map<String, dynamic> or Equb consistently

class EqubListScreen extends StatefulWidget {
  const EqubListScreen({super.key});

  @override
  State<EqubListScreen> createState() => _EqubListScreenState();
}

class _EqubListScreenState extends State<EqubListScreen> {
  // This still holds data from JSON, which is Map<String, dynamic>
  late Future<List<Map<String, dynamic>>> equbGroups;

  @override
  void initState() {
    super.initState();
    equbGroups = loadEqubGroups();
  }

  // Method to refresh the Equb list
  void _refreshEqubList() {
    setState(() {
      equbGroups = loadEqubGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userNotifier = Provider.of<UserNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Available Equbs",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Equbs",
            onPressed: _refreshEqubList,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: equbGroups,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 10),
                    Text(
                      'Failed to load Equb groups: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _refreshEqubList,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Try Again"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.group_off,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "No Equb groups found.",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Check back later for new opportunities!",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _refreshEqubList,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Refresh List"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ));
          } else {
            final equbList = snapshot.data!;
            // joinedEqubs is now List<Equb> from UserNotifier
            final joinedEqubs = userNotifier.joinedEqubs;

            final availableEqubs = equbList.where((e) =>
            // FIX: Access 'id' of 'joined' Equb object using dot notation
            !joinedEqubs.any((joined) => joined.id == e['id'])
            ).toList();

            if (availableEqubs.isEmpty) {
              return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: Colors.green[400],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "You've joined all available Equbs!",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Keep an eye out for new ones.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: availableEqubs.length,
              itemBuilder: (context, index) {
                final equb = availableEqubs[index]; // 'equb' here is still a Map<String, dynamic> from loadEqubGroups
                return Card(
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // Pass the raw map data to EqubDetailScreen
                          // Ensure EqubDetailScreen's constructor expects Map<String, dynamic>
                          // If EqubDetailScreen has been refactored to take Equb, you'd convert here.
                          // For now, assuming it still takes Map.
                          builder: (context) => EqubDetailScreen(equbData: equb),
                        ),
                      ).then((_) {
                        _refreshEqubList();
                      });
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 30,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  equb['name'] ?? 'Unnamed Equb',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "${equb['contributionAmount']} Birr by ${equb['frequency']}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(Icons.group, size: 16, color: Colors.grey[500]),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${equb['numberOfMembers'] ?? '?' } Members",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}