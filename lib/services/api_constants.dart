import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api'; // Android Emulator alias for localhost
    }
    return 'http://localhost:3000/api'; // iOS Simulator or Desktop
  }
}
