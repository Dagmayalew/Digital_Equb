import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';
import '../utils/json_loader.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneOrEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final String input = _phoneOrEmailController.text.trim().replaceAll(' ', '');
    final String password = _passwordController.text;

    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    FocusScope.of(context).unfocus();

    try {
      final List<Map<String, dynamic>> users = await loadUsers();

      final user = users.cast<Map<String, dynamic>?>().firstWhere(
            (u) =>
        u != null &&
            (u['phone'] == input || u['email'] == input) &&
            u['password'] == password,
        orElse: () => null,
      );

      if (user != null) {
        // ✅ Navigate to HomeScreen with user data
        Navigator.pushReplacementNamed(
          context,
          HomeScreen.routeName,
          arguments: user, // 👈 This is the key fix
        );
      } else {
        setState(() {
          _errorMessage = 'የተሳሳተ ፋይሉ ወይም ፒን ኮድ';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'እባክዎ እንደገና ይሞክሩ';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("ግባ"),
        actions: [
          IconButton(
            icon: Icon(themeNotifier.currentBrightness == Brightness.dark
                ? Icons.wb_sunny
                : Icons.nightlight),
            onPressed: themeNotifier.toggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _phoneOrEmailController,
                decoration: const InputDecoration(labelText: "ስልክ ቁጥር ወይም ኢሜል"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'እባክዎ ያስገቡ ፋይሉ ወይም ስልክ ቁጥር';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "ፓስወርድ"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'እባክዎ ያስገቡ ፒን ኮድ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(MediaQuery.of(context).size.width, 50),
                ),
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text("ግባ"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}