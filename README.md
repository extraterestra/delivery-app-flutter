# Rabka Dostawa - Flutter Mobile Migration

This project is a mobile migration of the **Rabka Dostawa** delivery application, originally developed for the Web. The migration focuses on providing a native Android experience using Flutter.

## 🚀 Current Progress: Phase 1 (Login Migration)

We have successfully migrated the core Authentication workflow from the Web project to Flutter.

### Features Implemented:
- **Native UI/UX**: Recreated the web interface using Flutter Material 3, maintaining brand consistency (colors, logos, and icons).
- **Authentication Service**: Complete integration with the existing backend APIs.
- **State Management**: Implemented using `Provider` to manage user sessions and profiles.
- **Secure Storage**: JWT tokens are securely stored locally for persistent login.
- **Form Validation**: Native mobile form validation for Login and Registration.

### Technical Stack:
- **Framework**: Flutter
- **Icons**: Lucide Icons (matching the web project)
- **State Management**: Provider
- **Networking**: Http with interceptor-like logic for JWT
- **Storage**: Flutter Secure Storage

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
2. Run `flutter pub get` to install dependencies.
3. Launch your emulator or connect a device.
4. Run `flutter run`.

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
- **Production APK:**
  ```powershell
  flutter build apk --flavor production
  ```

#### 3. Automatic Environment Detection
The app automatically detects the flavor it was built with. It uses `MethodChannel('flutter/platform').invokeMethod('getFlavor')` to determine whether to use the Staging or Production backend URL.

| Environment | Flavor Name | Package ID | Backend URL |
|-------------|-------------|------------|-------------|
| Staging | `staging` | `com.rabka.dostawa.staging` | `delivery-app-staging-backend` |
| Production | `production` | `com.rabka.dostawa` | `delivery-app-prod-backend` |

---

## 📁 Project Structure
- `lib/models/`: Data structures for Auth and User Profiles.
- `lib/providers/`: Business logic and state management.
- `lib/screens/`: UI Screens (Auth, Dashboard).
- `lib/services/`: API communication layer.
- `lib/config/env_config.dart`: Environment-specific URLs.

---
*This project is part of a migration study from Web to Flutter for the Rabka Dostawa team.*
