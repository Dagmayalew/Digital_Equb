import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Added for currency formatting
import '../notifier/user_notifier.dart';
import '../utils/json_loader.dart';
import 'equb_detail_screen.dart'; // Make sure this screen expects Map<String, dynamic> or Equb consistently

class EqubListScreen extends StatefulWidget {
  const EqubListScreen({super.key});

  @override
  State<EqubListScreen> createState() => _EqubListScreenState();
}

class _EqubListScreenState extends State<EqubListScreen> {
  late Future<List<Map<String, dynamic>>> equbGroups;

  @override
  void initState() {
    super.initState();
    _loadEqubs(); // Call a dedicated method to load
  }

  // Method to load Equb list
  void _loadEqubs() {
    setState(() {
      equbGroups = loadEqubGroups();
    });
  }

  // Method to refresh the Equb list
  void _refreshEqubList() {
    _loadEqubs(); // Simply call loadEqubs to refresh
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Equb list refreshed!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userNotifier = Provider.of<UserNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Discover Equbs", // More inviting title
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
          const SizedBox(width: 8), // Add some spacing
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
                      'Failed to load Equb groups. Please try again.', // Simplified error message
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Rounded button
                      ),
                    ),
                  ],
                ));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Updated Empty State (No Equbs found in JSON)
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
                      "No Equb groups available at the moment.",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "New opportunities are coming soon!",
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ));
          } else {
            final equbList = snapshot.data!;
            final joinedEqubs = userNotifier.joinedEqubs;

            final availableEqubs = equbList.where((e) =>
            !joinedEqubs.any((joined) => joined.id == e['id'])
            ).toList();

            if (availableEqubs.isEmpty) {
              // Updated Empty State (All Equbs joined)
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
                        "Great! You've joined all available Equbs.",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Stay tuned for new Equb opportunities!",
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
                        label: const Text("Check for New Equbs"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary, // Different color for distinction
                          foregroundColor: Theme.of(context).colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: availableEqubs.length,
              itemBuilder: (context, index) {
                final equb = availableEqubs[index];
                // Format contribution amount
                final String formattedAmount = NumberFormat.currency(locale: 'en_US', symbol: 'Birr').format(equb['contributionAmount']);

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
                          builder: (context) => EqubDetailScreen(equbData: equb),
                        ),
                      ).then((_) {
                        // Refresh the list when returning from detail screen
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
                              Icons.handshake_outlined, // More relevant icon for joining Equbs
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
                                  "$formattedAmount • ${equb['frequency']}", // Use formatted amount
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(Icons.people_alt_outlined, size: 16, color: Colors.grey[500]), // Updated icon
                                    const SizedBox(width: 4),
                                    Text(
                                      "${equb['numberOfMembers'] ?? '?' } Members",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(Icons.calendar_month, size: 16, color: Colors.grey[500]), // Duration icon
                                    const SizedBox(width: 4),
                                    Text(
                                      "${equb['durationInMonths'] ?? '?' } Months",
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
                            Icons.chevron_right, // More standard 'go to details' icon
                            size: 24, // Slightly larger icon
                            color: Theme.of(context).colorScheme.secondary, // Themed color
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