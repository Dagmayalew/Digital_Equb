import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../notifier/locale_notifier.dart';
import '../theme/theme_notifier.dart';
import '../utils/json_loader.dart';
import '../widgets/language_switcher.dart'; // 👈 Add this import
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

    final input = _phoneOrEmailController.text.trim().replaceAll(' ', '');
    final password = _passwordController.text;

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
        Navigator.pushReplacementNamed(
          context,
          HomeScreen.routeName,
          arguments: user,
        );
      } else {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.invalidCredentials;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.tryAgain;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.login),
        actions: const [
          LanguageSwitcher(), // 🌐 Only appears on login screen
        ],
        leading: IconButton(
          icon: Icon(
            themeNotifier.currentBrightness == Brightness.dark
                ? Icons.wb_sunny
                : Icons.nightlight,
          ),
          onPressed: themeNotifier.toggleTheme,
        ),
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
                decoration:
                InputDecoration(labelText: localizations.phoneOrEmail),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.enterPhoneOrEmail;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: localizations.password),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.enterPassword;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(MediaQuery.of(context).size.width, 50),
                ),
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(localizations.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
