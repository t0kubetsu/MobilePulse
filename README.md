# NyanTrack

A Flutter-based mobile application featuring an animated Nyan Cat interface combined with background device telemetry and location tracking capabilities.

The application demonstrates:
* Animated asset rendering using low-level image decoding
* Audio playback integration
* Runtime permission handling
* Background foreground services
* Continuous GPS tracking
* Device information collection
* Remote JSON API communication

## Features

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

All outbound requests:
* Use HTTP POST
* Send JSON-encoded payloads
* Include a timestamp
* Are configured in `app_constants.dart`

Developers can modify server endpoints in:
```
lib/app_constants.dart
```

## Dependencies

Key packages used:
* `flutter_background_service`
* `geolocator`
* `device_info_plus`
* `permission_handler`
* `http`
* `just_audio`

## Building the Application

To build the Android APK:
```bash
flutter clean
flutter pub get
flutter build apk
```

Release build:
```bash
flutter build apk --release
```

Output location:
```
build/app/outputs/flutter-apk/
```
