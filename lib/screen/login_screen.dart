import 'package:flutter/material.dart';
import 'dart:convert'; // Not directly used in this snippet, but often needed for JSON.
import 'package:provider/provider.dart';

import '../notifier/user_notifier.dart';
import '../theme/theme_notifier.dart';
import '../utils/json_loader.dart'; // Assuming this loads your user data
import 'main_screen.dart'; // Your main screen after login

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key}); // Added const constructor for better performance.

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneOrEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;
  bool _obscurePassword = true; // Added for password visibility toggle

  @override
  void dispose() {
    _phoneOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = ''; // Clear previous errors if validation fails
      });
      return;
    }

    final String input = _phoneOrEmailController.text.trim().replaceAll(' ', '');
    final String password = _passwordController.text;

    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    try {
      final List<Map<String, dynamic>> users = await loadUsers();

      final user = users.firstWhere(
            (u) =>
        (u['phone'] == input || u['email'] == input) &&
            u['password'] == password,
        orElse: () => <String, dynamic>{}, // Return an empty map if not found
      );

      if (user.isNotEmpty) { // Check if the user map is not empty
        final userNotifier = Provider.of<UserNotifier>(context, listen: false);
        userNotifier.setUser(user);

        // Use Navigator.pushReplacement for clean navigation stack
        Navigator.pushReplacementNamed(
          context,
          MainScreen.routeName,
          arguments: user,
        );
      } else {
        setState(() {
          _errorMessage = 'Invalid phone/email or password.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed. Please check your connection or try again.';
        _isLoading = false;
      });
      // In a real app, you might want to log the error: print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.currentBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Welcome Back!", // More inviting title
          style: TextStyle(fontWeight: FontWeight.bold), // Bold app bar title
        ),
        centerTitle: true, // Center the app bar title
        elevation: 0, // Flat app bar for a modern look
        actions: [
          IconButton(
            tooltip: "Toggle Theme",
            icon: Icon(
              isDarkMode ? Icons.wb_sunny : Icons.nightlight_round, // Updated icon
              color: isDarkMode ? Colors.amber : Colors.deepPurple, // Themed icon color for light/dark
            ),
            onPressed: themeNotifier.toggleTheme,
          ),
          const SizedBox(width: 8), // Padding for the icon button
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0), // More vertical padding
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons horizontally
              children: [
                // Enhanced Logo-style title
                Text(
                  "Digital Equb",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40, // Larger font size
                    fontWeight: FontWeight.w900, // Heavier weight
                    letterSpacing: 2, // More letter spacing
                    color: Theme.of(context).colorScheme.primary, // Use theme primary color
                    shadows: [ // Subtle shadow for depth
                      Shadow(
                        blurRadius: 6.0, // Slightly more blur
                        color: Colors.black.withOpacity(0.3), // Darker shadow
                        offset: const Offset(3.0, 3.0), // More offset
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60), // Increased spacing for visual breathing room

                TextFormField(
                  controller: _phoneOrEmailController,
                  decoration: InputDecoration(
                    labelText: "Phone Number or Email",
                    hintText: "e.g., +251988280976 or dagmayalew489@gmail.com", // Hint text
                    prefixIcon: const Icon(Icons.person_outline), // Icon for input
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                    enabledBorder: OutlineInputBorder( // Define enabled border
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant, // Use theme outline color
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary, // Themed focused border
                        width: 2,
                      ),
                    ),
                    filled: true, // Fill the background
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[50], // Consistent fill color
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number or email.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20), // Spacing between fields

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword, // Use the state variable
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter your password",
                    prefixIcon: const Icon(Icons.lock_outline), // Icon for input
                    suffixIcon: IconButton( // Toggle password visibility
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                    enabledBorder: OutlineInputBorder( // Define enabled border
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary, // Themed focused border
                        width: 2,
                      ),
                    ),
                    filled: true, // Fill the background
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[50], // Consistent fill color
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24), // Spacing before error message and button

                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error, // Use theme error color
                        fontWeight: FontWeight.w600, // Slightly bolder error text
                        fontSize: 15, // Slightly larger font
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18), // Larger padding for a more prominent button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Match input field borders
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary, // Use theme primary color
                    foregroundColor: Theme.of(context).colorScheme.onPrimary, // Text color contrasting primary
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    elevation: 5, // Add a subtle shadow
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                    width: 28, // Larger loader
                    height: 28,
                    child: CircularProgressIndicator(
                      color: Colors.white, // Ensure white on colored button
                      strokeWidth: 3, // Thicker stroke
                    ),
                  )
                      : const Text("Login"),
                ),
                const SizedBox(height: 20), // Spacing for potential forgotten password or sign up links
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Forgot Password? Feature not yet implemented.")), // Clarified message
                    );
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary, // Themed color
                      fontWeight: FontWeight.w600, // Slightly bolder
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}