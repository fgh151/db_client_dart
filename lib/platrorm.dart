import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'application.dart';

class DbPlatform extends Platform {
  static String get operatingSystem  {
    return DbPlatform.isWeb ? 'web' : Platform.operatingSystem;
  }

  static bool get isWeb => kIsWeb;

  static String getDeviceId(SharedPreferences prefs) {
    var deviceId = prefs.getString(Application.uuidKey);

    if (deviceId == null) {
      var uuid = const Uuid();
      deviceId = uuid.v4();
    }

    return deviceId;
  }

}