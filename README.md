# Smart Helmet Monitoring Mobile Application

This Flutter application monitors real-time sensor data from a smart helmet system via Blynk Cloud.

## Features

- Real-time dashboard displaying sensor data (Gas, Alcohol, MPU6050 angles, Temperature)
- Color-coded indicators for safe/danger levels
- Automatic alerts for gas and alcohol detection
- Error handling for connection issues

## Setup Instructions

1. **Install Flutter**: Ensure Flutter SDK is installed on your system. Follow the official Flutter installation guide: https://flutter.dev/docs/get-started/install

2. **Clone or Download**: Place the project files in your desired directory.

3. **Install Dependencies**:
   ```
   flutter pub get
   ```

4. **Configure Blynk Token**:
   - Open `lib/services/blynk_service.dart`
   - Replace `'YOUR_BLYNK_TOKEN_HERE'` with your actual Blynk authentication token.

5. **Run the Application**:
   - Connect a device or start an emulator
   - Run: `flutter run`

## Blynk Cloud Integration

The app connects to Blynk Cloud using HTTP GET requests to fetch sensor data from virtual pins:

- Gas: V0
- Alcohol: V1
- MPU6050 X: V6
- MPU6050 Y: V7
- MPU6050 Z: V8
- Temperature: V9

Data is fetched every 2 seconds and the UI updates automatically.

## Architecture

- **Models**: Data structures for sensor readings
- **Services**: API communication with Blynk
- **Providers**: State management using Provider
- **Screens**: UI components
- **Widgets**: Reusable UI elements

## Dependencies

- `http`: For API requests
- `provider`: State management
- `flutter_local_notifications`: Local notifications for alerts