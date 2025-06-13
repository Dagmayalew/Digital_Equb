// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get login => 'Login';

  @override
  String get phoneOrEmail => 'Phone or Email';

  @override
  String get password => 'Password';

  @override
  String get enterPhoneOrEmail => 'Please enter your phone or email';

  @override
  String get enterPassword => 'Please enter your password';

  @override
  String get invalidCredentials => 'Invalid phone/email or password';

  @override
  String get tryAgain => 'Please try again';

  @override
  String get home => 'ዋና ገጽ';

  @override
  String get greeting => 'ሰላም';

  @override
  String get joinEqub => 'እቁብ አገባ';

  @override
  String get joinedEqubs => 'የተቀላቀሉት እቁቦች';

  @override
  String get noEqubsJoined => 'ምንም እቁብ አልተቀላቀለህም';

  @override
  String get by => 'በ';
}
