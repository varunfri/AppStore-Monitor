# App Store Connect Monitor

A clean-architecture, production-ready Flutter application for Android that allows developers to monitor their Apple App Store Connect account.

Authentication and token signing occur entirely on-device, utilizing local ES256 (Elliptic Curve Digital Signature Algorithm with SHA-256) cryptography. **No third-party backend is involved**, meaning your sensitive Apple Developer private keys never leave your device.

---

## Key Features

1. **Local Cryptography (ES256 JWT Generation)**: Signs standard App Store Connect JWT tokens locally on the device using `dart_jsonwebtoken` and the `pointycastle` ECDSA provider.
2. **Secure Credentials Storage**: Protects your API secrets (`Issuer ID`, `Key ID`, and the `.p8` private key contents) inside the Android system KeyStore using `flutter_secure_storage` with EncryptedSharedPreferences enabled.
3. **App Details & Status Monitor**:
   * Lists all apps configured under your account (displays App Name, Bundle ID, and SKU).
   * Monitors build history, including real-time processing statuses, validity, and expiration states.
   * Tracks TestFlight / Pre-release versions.
4. **Developer Console Overlay**: 
   * A floating developer overlay that records all API requests and errors in real-time.
   * Highlights `401 Unauthorized` and `403 Forbidden` credentials issues with custom troubleshooting advice.
   * Features a **Local JWT Claims Decoder** to inspect signed headers and payloads directly.

---

## Directory & Clean Architecture Layout

The codebase is built using Clean Architecture guidelines to isolate concerns across data, domain, and presentation layers:

```text
lib/
├── core/
│   ├── error/
│   │   └── error_logger.dart       # Holds logs for network/auth errors shown in UI overlay
│   ├── network/
│   │   ├── dio_client.dart         # Configures Dio, base options, and interceptors
│   │   └── jwt_interceptor.dart    # Appends fresh Authorization: Bearer <JWT> to requests
│   ├── security/
│   │   ├── jwt_service.dart        # Dynamically generates and signs ES256 JWT using .p8 key
│   │   └── secure_storage.dart     # Secure wrapper around flutter_secure_storage
│   └── theme/
│       └── app_theme.dart          # Sleek premium dark/glassmorphic styling
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── auth_repository.dart
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart
│   │   │   └── screens/
│   │   │       ├── config_screen.dart # Enter credentials & private key
│   │   │       └── auth_gate.dart     # Redirects to Config or AppList based on state
│   ├── dashboard/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── app_model.dart     # App Name, Bundle ID, SKU
│   │   │   │   ├── build_model.dart   # Build version, upload date, processing state, expired
│   │   │   │   └── prerelease_model.dart # TestFlight / Prerelease version info
│   │   │   └── repositories/
│   │   │       └── app_store_repository.dart # Hits /v1/apps, /v1/apps/{id}/builds, etc.
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── dashboard_provider.dart
│   │       └── screens/
│   │           ├── app_list_screen.dart   # Dashboard view of all apps
│   │           └── app_detail_screen.dart # Detailed TestFlight and build history
│   └── error_overlay/
│       └── presentation/
│           └── widgets/
│               └── error_logger_overlay.dart # Floating debug/log console for auth/network issues
└── main.dart
```

---

## Dependencies

The app uses the following core dependencies, defined in `pubspec.yaml`:
*   [`dio`](https://pub.dev/packages/dio): HTTP client configured with interceptors for auth headers and global loggers.
*   [`dart_jsonwebtoken`](https://pub.dev/packages/dart_jsonwebtoken): For creating, header customisation, and signing the ES256 JSON Web Tokens.
*   [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage): Safe, hardware-backed credential storage on Android.
*   [`provider`](https://pub.dev/packages/provider): Lightweight and clean state management solution.
*   [`google_fonts`](https://pub.dev/packages/google_fonts): For modern premium typography.

---

## How to Get Your Credentials from Apple

To configure the application, you need to gather three values from the [Apple Developer Portal (App Store Connect)](https://appstoreconnect.apple.com/):

### Step 1: Access Users and Access
1. Log in to your [App Store Connect Account](https://appstoreconnect.apple.com/).
2. Click on the **Users and Access** icon on the home screen.
3. Select the **Integrations** tab at the top (formerly labeled **Keys**).

### Step 2: Request Access to Keys (First-time setup only)
If you haven't used API keys in this account before, you will see a request access page:
1. Click **Request Access**.
2. Accept the agreement terms to enable key generation.

### Step 3: Generate a New API Key
1. Under the **Active Keys** or **App Store Connect API** section, click the **Add (+)** button.
2. In the modal:
   * **Name**: Enter a descriptive name for the key (e.g., `Android Dashboard Monitor`).
   * **Access / Role**: Choose a role that determines the key's permissions. For viewing apps, TestFlight versions, and builds, the **Developer** or **App Manager** role is sufficient. (For full access, choose **Admin**).
3. Click **Generate**.

### Step 4: Collect Key Credentials
Once generated, the page will reload showing your new key:
1. **Issuer ID**: Copy the **Issuer ID** GUID string displayed at the top of the keys table.
2. **Key ID**: Copy the 10-character alphanumeric **Key ID** shown next to your newly created key.
3. **Private Key (.p8 file)**: 
   * Click **Download API Key** next to the key. 
   * > [!WARNING]
     > Apple only allows you to download this private key file **once**. If you navigate away or refresh, you will not be able to download it again. Save the downloaded `.p8` file securely.
   * Open the downloaded `.p8` file in any text editor (like VS Code, Notepad, or TextEdit). 
   * Copy the entire multiline text including the headers:
     ```text
     -----BEGIN PRIVATE KEY-----
     MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQg...
     -----END PRIVATE KEY-----
     ```

---

## How to Run & Verify

1.  **Clone or Open Project**:
    ```bash
    cd app_store_monitor
    ```
2.  **Fetch Packages**:
    ```bash
    flutter pub get
    ```
3.  **Run Android App** (make sure a device/emulator is connected):
    ```bash
    flutter run
    ```
4.  **Run Code Quality Checks**:
    ```bash
    flutter analyze
    ```

---

## Security & Verification Checklist

*   [x] **Local Crypto**: The private key is never transmitted over the internet or sent to external servers. It stays in the device's process space to run the ECDSA signing operation.
*   [x] **Encrypted Preferences**: App Store Connect API keys are stored securely using Android's EncryptedSharedPreferences (AES-256 GCM authenticated cryptography).
*   [x] **Verification Screen**: The configuration screen performs a live verification by fetching the application list. If it succeeds, the credentials are saved; otherwise, the credentials are automatically cleared from the memory to prevent invalid configurations.
