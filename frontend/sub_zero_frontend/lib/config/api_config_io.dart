import 'dart:io' show Platform;

/// Android-Emulator: 10.0.2.2. Windows/Desktop: localhost.
final String apiBaseUrl =
    Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
