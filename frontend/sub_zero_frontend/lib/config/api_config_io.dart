import 'dart:io' show Platform;

final String apiBaseUrl =
    Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
