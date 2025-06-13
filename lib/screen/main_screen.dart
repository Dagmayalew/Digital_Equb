import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Keep this import for Provider

import '../notifier/user_notifier.dart'; // Important to access the global UserNotifier
import 'home_screen.dart';
import 'equb_list_screen.dart';
import 'profile.dart'; // ProfileScreen will also read from UserNotifier

class MainScreen extends StatefulWidget {
  static const String routeName = '/main';
  // Removed 'final Map<String, dynamic> user;' - user data is now accessed globally
  const MainScreen({super.key}); // Updated constructor

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
    // User data is now set in main.dart upon login,
    // so no need to set it here again.
    // Screens will read from UserNotifier directly.

    _screens = [
      const HomeScreen(),
      const EqubListScreen(),
      const ProfileScreen(), // ProfileScreen no longer requires a 'user' argument
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
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        // Prevents manual swiping if you only want tab clicks.
        // Change to AlwaysScrollableScrollPhysics() or BouncingScrollPhysics() to enable swiping.
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: "Equbs",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        showUnselectedLabels: true,
      ),
    );
  }
}