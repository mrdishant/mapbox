import 'dart:async';

import 'package:flutter/services.dart';

export 'navigation_view.dart';

class Mapbox {
  static const MethodChannel _channel = MethodChannel('mapbox');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
