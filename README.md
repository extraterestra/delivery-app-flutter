# Rabka Dostawa - Flutter Mobile Migration

This project is a mobile migration of the **Rabka Dostawa** delivery application, originally developed for the Web. The migration focuses on providing a native Android experience using Flutter.

## 🚀 Current Progress: Phase 1 (Login Migration)

We have successfully migrated the core Authentication workflow from the Web project to Flutter.

### Features Implemented:
- **Native UI/UX**: Recreated the web interface using Flutter Material 3, maintaining brand consistency (colors, logos, and icons).
- **Authentication Service**: Complete integration with the existing backend APIs.
- **State Management**: Implemented using `Provider` to manage user sessions and profiles.
- **Remember Me & Persistence**: Implemented secure session persistence. Users can choose to stay logged in, and the app securely remembers credentials (email/password) using `flutter_secure_storage`.
- **Biometric Authentication**: Added support for Fingerprint and FaceID (Android) using `local_auth`. Users can securely unlock their saved credentials for a faster login experience.
- **Localization**: Multi-language support (EN/PL) for the entire authentication flow.
- **Form Validation**: Native mobile form validation for Login and Registration.
- **Active Delivery Tracking**: Real-time map view with driver, restaurant, and customer locations. Integrated live GPS tracking to monitor driver movement and calculate dynamic distances.
- **Native Navigation**: One-tap access to Google Maps for precise delivery routing.
- **Communication Tools**: Integrated quick-call buttons for both restaurants and customers based on the delivery stage.
- **Visual Progress**: A dedicated delivery timeline showing the order status (Accepted -> Picked Up -> Delivered).

## 📍 Phase 2: Maps & GPS Integration (SCRUM-126)

Successfully integrated mapping and location services for real-time delivery tracking.

### Features Implemented:
- **Interactive OpenStreetMap**: Integrated `flutter_map` for high-performance, interactive map views without the need for proprietary SDKs.
- **Real-time GPS Tracking**: Implemented location services to track driver position during active deliveries.
- **Delivery Timeline**: Added a visual status timeline (Accepted -> Picked Up -> Delivered) to keep drivers informed of their progress.
- **Live Navigation**: Visual representation of the route between the restaurant and the customer.

## 💰 Phase 3: Payouts & Earnings (SCRUM-141)

Implemented delivery payout displays across all driver screens to ensure earnings transparency.

### Features Implemented:
- **Payout Visibility**: The specific earning amount is now displayed on every order card in "Available Orders" and "Active Deliveries".
- **Active Delivery Details**: Added a dedicated Payout & Payment Status card within the active delivery screen.
- **Earnings Dashboard**: Real-time calculation of "Today's Earnings" and "Total Earnings" on the main dashboard.
- **Detailed History**: Enhanced the order history screen with precise payout figures and payment status (Paid/Pending) for each past delivery.
- **Multi-language Support**: Full translation of payout-related terms in English and Polish.

## 📦 Phase 4: Detailed Order Information (SCRUM-162)

Enhanced the delivery flow by providing comprehensive order details to drivers, ensuring they know exactly what they are carrying.

### Features Implemented:
- **Order Summary in Lists**: Both available and active order cards now display the total number of items and the total weight of the delivery.
- **Detailed Order Screen**: A new dedicated screen that breaks down the order into individual items, showing quantities, unit weights, and specific customer notes.
- **Ubiquitous Access (SCRUM-66)**: Order details are now accessible at every stage of the delivery process (Pending, Accepted, Picked Up) and in the delivery history.
- **Real-time Weight Calculation**: Automatic calculation of the total delivery weight based on individual item metrics.
- **Improved UI for Items**: Integrated package and weight icons for better scannability in lists.
- **Multi-language Support**: Full translation of order details and metrics into English and Polish.

### Technical Stack:
- **Framework**: Flutter
- **Icons**: Lucide Icons
- **State Management**: Provider
- **Networking**: Http with JWT interceptor logic
- **Storage**: Flutter Secure Storage
- **Maps & Geolocation**: Flutter Map (OpenStreetMap) & Geolocator
- **Communication**: URL Launcher (for Phone and Maps navigation)

## 🛠 Setup and Installation

### Prerequisites:
- Flutter SDK (latest version)
- Android Studio / VS Code
- Android Emulator or Physical Device

### Configuration:
The app is currently configured to connect to a local backend.
- **Emulator**: It uses `http://10.0.2.2:3000` to reach your machine's localhost.
- **Physical Device**: Update `lib/services/api_service.dart` with your machine's local IP address.

### Running the App:
1. Clone the repository.
2. Run `flutter clean` to remove any previous build artifacts.
2. Run `flutter pub get` to install dependencies.
3. Launch your emulator or connect a device.
4. Run the app using flavors (see below).

### Environment Configuration (Flavors)

The application uses **Flutter Flavors** to manage different environments. This allows having both Staging and Production versions installed on the same device simultaneously.

#### 1. Running the App with Flavors
- **Staging (App Name: Rabka STG):**
  ```powershell
  flutter run --flavor staging
  ```
- **Production (App Name: Rabka Dostawa):**
  ```powershell
  flutter run --flavor production
  ```

#### 2. Building the App (APK)
- **Staging APK:**
  ```powershell
  flutter build apk --flavor staging
  ```
- **Production APK (Release):**
  ```powershell
  flutter build apk --flavor production
  ```
- **Staging Debug APK (For testing):**
  ```powershell
  flutter build apk --debug --flavor staging
  ```

#### 3. Automatic Environment Detection
The app automatically detects the flavor it was built with. It uses `MethodChannel('flutter/platform').invokeMethod('getFlavor')` to determine whether to use the Staging or Production backend URL.

| Environment | Flavor Name | Package ID | Backend URL |
|-------------|-------------|------------|-------------|
| Staging | `staging` | `com.rabka.dostawa.staging` | `delivery-app-staging-backend` |
| Production | `production` | `com.rabka.dostawa` | `delivery-app-prod-backend` |

---

## 🧪 UI & Layout Testing (SCRUM-161)

To ensure the application looks great on all devices (including those with notches and different aspect ratios), we use **Device Preview**.

### How to use Device Preview:
1. **Enable it**: In `lib/main.dart`, the `DevicePreview` widget is integrated but can be toggled via the `enabled` parameter.
2. **Launch**: Run the app using `flutter run --flavor staging`.
3. **Tools**: Use the side menu to switch between iOS/Android devices, change orientation, and test "Safe Area" constraints.

### Debug Bypass (UI Testing):
For rapid UI iteration without navigating the full login flow, a "Debug Bypass" pattern is documented in our Confluence. This involves injecting a `mockOrder` into the `ActiveOrderScreen` to test specific layout scenarios like button overlaps.

---

## 📁 Project Structure
- `lib/models/`: Data structures for Auth and User Profiles.
- `lib/providers/`: Business logic and state management.
- `lib/screens/`: UI Screens (Auth, Dashboard).
- `lib/services/`: API communication layer.
- `lib/config/env_config.dart`: Environment-specific URLs.

## 🔧 Bug Fixes & Maintenance

### Timezone Consistency (SCRUM-179)
- Fixed an issue where order creation and delivery times were displayed in UTC instead of the user's local timezone.
- Applied `.toLocal()` conversion across all timestamp displays in `OrdersScreen` and `OrderHistoryScreen`.

### Order Synchronization & Detail Robustness (SCRUM-192)
- Fixed a critical bug where orders in intermediate states like `in_delivery` or `picked_up` would result in "Order not found" errors due to missing status mapping in the provider.
- Enhanced the `Order` model to be more resilient by parsing IDs from both `id` and `_id` fields and normalizing status strings to lowercase.
- Implemented lazy-loading for order items in `OrderDetailsScreen` to ensure weights and item lists are always available, even if the initial list payload was partial.

---
*This project is part of a migration study from Web to Flutter for the Rabka Dostawa team.*
