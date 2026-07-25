// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Rabka Dostawa';

  @override
  String welcome(String name) {
    return 'Witaj, $name!';
  }

  @override
  String get login => 'Logowanie';

  @override
  String get register => 'Rejestracja';

  @override
  String get fullName => 'Imię i nazwisko';

  @override
  String get phone => 'Numer telefonu';

  @override
  String get email => 'Email';

  @override
  String get password => 'Hasło';

  @override
  String get signIn => 'Zaloguj się';

  @override
  String get signUp => 'Zarejestruj się';

  @override
  String get forgotPassword => 'Zapomniałeś hasła?';

  @override
  String get driverPanel => 'Panel kierowcy';

  @override
  String get activeDeliveries => 'Aktywne dostawy';

  @override
  String get noActiveDeliveries => 'Brak aktywnych dostaw';

  @override
  String youHaveActiveDeliveries(int count) {
    return 'Masz $count aktywną dostawę';
  }

  @override
  String get today => 'Dzisiaj';

  @override
  String get total => 'Łącznie';

  @override
  String get deliveries => 'dostaw';

  @override
  String get quickActions => 'Szybkie działania';

  @override
  String get availableOrders => 'Dostępne zamówienia';

  @override
  String get activeDelivery => 'Aktywna dostawa';

  @override
  String get orderHistory => 'Historia dostaw';

  @override
  String historyDescription(int count) {
    return '$count ukończonych';
  }

  @override
  String get driver => 'Kierowco';

  @override
  String pendingOrders(int count) {
    return '$count oczekujących';
  }

  @override
  String get clickToContinue => 'Kliknij, aby kontynuować';

  @override
  String get orders => 'Zamówienia';

  @override
  String get noAvailableOrders => 'Brak dostępnych zamówień';

  @override
  String get tryRefreshingLater => 'Spróbuj odświeżyć za chwilę';

  @override
  String get acceptOrder => 'Przyjmij zamówienie';

  @override
  String get payout => 'Wypłata';

  @override
  String get restaurant => 'Restauracja';

  @override
  String get unknownAddress => 'Adres nieznany';

  @override
  String get totalEarnings => 'Łączne zarobki';

  @override
  String completedDeliveriesCount(int count) {
    return '$count ukończonych dostaw';
  }

  @override
  String get noCompletedDeliveries => 'Brak ukończonych dostaw';

  @override
  String get paid => 'Zapłacono';

  @override
  String get pending => 'Oczekuje';

  @override
  String get deliveryStatus => 'Status dostawy';

  @override
  String get orderAccepted => 'Zamówienie przyjęte';

  @override
  String get pickedUpFromRestaurant => 'Odebrane z restauracji';

  @override
  String get deliveredToCustomer => 'Dostarczone klientowi';

  @override
  String get pickupFrom => 'Odbiór z:';

  @override
  String get deliveryTo => 'Dostawa do:';

  @override
  String get details => 'Szczegóły';

  @override
  String get iHavePickedUpOrder => 'Odebrałem zamówienie';

  @override
  String get signOut => 'Wyloguj się';

  @override
  String get signOutConfirmation => 'Czy na pewno chcesz się wylogować?';

  @override
  String get cancel => 'Anuluj';

  @override
  String get error => 'Błąd';

  @override
  String get errorFullName => 'Podaj imię i nazwisko';

  @override
  String get errorEmail => 'Podaj email';

  @override
  String get errorPassword => 'Hasło musi mieć min. 6 znaków';

  @override
  String get rememberMe => 'Zapamiętaj mnie';

  @override
  String get useBiometrics => 'Użyj biometrii';

  @override
  String get biometricReason => 'Zaloguj się za pomocą biometrii';

  @override
  String distance(String value) {
    return '$value km';
  }

  @override
  String get restaurantToClient => 'Restauracja do Klienta';

  @override
  String get driverToRestaurant => 'Kierowca do Restauracji';

  @override
  String get driverToClient => 'Kierowca do Klienta';

  @override
  String estimatedTime(String value) {
    return '~$value min';
  }

  @override
  String get navigate => 'Nawiguj';

  @override
  String get call => 'Zadzwoń';

  @override
  String errorMessage(String error) {
    return 'Błąd: $error';
  }

  @override
  String itemsCount(int count) {
    return '$count produkty';
  }

  @override
  String weight(String value) {
    return '$value kg';
  }

  @override
  String totalWeight(String value) {
    return 'Waga całkowita: $value kg';
  }

  @override
  String get orderDetailsTitle => 'Szczegóły zamówienia';

  @override
  String get product => 'Produkt';

  @override
  String get quantity => 'Ilość';

  @override
  String get unitWeight => 'Waga jedn.';
}
