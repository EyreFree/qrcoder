import 'dart:async';

import 'package:flutter/services.dart';

class Qrcoder {
  static const MethodChannel _channel =
      const MethodChannel('qrcoder');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
