import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../notifier/user_notifier.dart';
import 'home_screen.dart';
import 'equb_list_screen.dart';
import 'profile.dart';

class MainScreen extends StatefulWidget {
  static const String routeName = '/main';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    _screens = [
      const HomeScreen(),
      const EqubListScreen(),
      const ProfileScreen(),
    ];

    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Animate to the selected page when a BottomNavigationBar item is tapped
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Listener for PageView page changes to update BottomNavigationBar
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access UserNotifier to potentially display user-specific greetings or info later
    // final userNotifier = Provider.of<UserNotifier>(context); // Not directly used in UI here, but good for context

    return Scaffold(
      // The AppBar is intentionally omitted here as each screen might have its own AppBar
      // if you choose to include it in the individual screen widgets.
      // If a consistent AppBar is desired across all main screens, it should be here.

      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        // Using NeverScrollableScrollPhysics to disable swiping between tabs,
        // forcing users to use the bottom navigation.
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined), // Changed to a more dashboard-like icon
            activeIcon: Icon(Icons.dashboard),
            label: "Dashboard", // Renamed to Dashboard
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined), // Changed to a more group-focused icon
            activeIcon: Icon(Icons.people_alt),
            label: "Equbs",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined), // Changed to a more personal profile icon
            activeIcon: Icon(Icons.account_circle),
            label: "Profile",
          ),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed, // Ensures all items are visible and evenly spaced
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 10, // Adds a shadow to the bottom nav bar
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), // Slightly larger and bolder
        unselectedLabelStyle: const TextStyle(fontSize: 12), // Slightly larger for better readability
        showUnselectedLabels: true, // Ensures all labels are always shown
      ),
    );
  }
}