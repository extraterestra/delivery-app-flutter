// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Rabka Delivery';

  @override
  String welcome(String name) {
    return 'Welcome, $name!';
  }

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get fullName => 'Full name';

  @override
  String get phone => 'Phone number';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get driverPanel => 'Driver Panel';

  @override
  String get activeDeliveries => 'Active deliveries';

  @override
  String get noActiveDeliveries => 'No active deliveries';

  @override
  String youHaveActiveDeliveries(int count) {
    return 'You have $count active delivery';
  }

  @override
  String get today => 'Today';

  @override
  String get total => 'Total';

  @override
  String get deliveries => 'deliveries';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get availableOrders => 'Available Orders';

  @override
  String get activeDelivery => 'Active Delivery';

  @override
  String get orderHistory => 'Order History';

  @override
  String historyDescription(int count) {
    return '$count completed';
  }

  @override
  String get driver => 'Driver';

  @override
  String pendingOrders(int count) {
    return '$count pending';
  }

  @override
  String get clickToContinue => 'Click to continue';

  @override
  String get orders => 'Orders';

  @override
  String get noAvailableOrders => 'No available orders';

  @override
  String get tryRefreshingLater => 'Try refreshing in a moment';

  @override
  String get acceptOrder => 'Accept order';

  @override
  String get restaurant => 'Restaurant';

  @override
  String get unknownAddress => 'Unknown address';

  @override
  String get totalEarnings => 'Total earnings';

  @override
  String completedDeliveriesCount(int count) {
    return '$count completed deliveries';
  }

  @override
  String get noCompletedDeliveries => 'No completed deliveries';

  @override
  String get paid => 'Paid';

  @override
  String get pending => 'Pending';

  @override
  String get deliveryStatus => 'Delivery status';

  @override
  String get orderAccepted => 'Order accepted';

  @override
  String get pickedUpFromRestaurant => 'Picked up from restaurant';

  @override
  String get deliveredToCustomer => 'Delivered to customer';

  @override
  String get pickupFrom => 'Pickup from:';

  @override
  String get deliveryTo => 'Delivery to:';

  @override
  String get details => 'Details';

  @override
  String get iHavePickedUpOrder => 'I have picked up the order';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutConfirmation => 'Are you sure you want to sign out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get error => 'Error';

  @override
  String get errorFullName => 'Please enter full name';

  @override
  String get errorEmail => 'Please enter email';

  @override
  String get errorPassword => 'Password must be at least 6 characters';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get useBiometrics => 'Use Biometrics';

  @override
  String get biometricReason => 'Please authenticate to log in';

  @override
  String errorMessage(String error) {
    return 'Error: $error';
  }
}
