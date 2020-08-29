import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'qr_error_correct_level.dart';
import 'qrcode.dart';

class Qrcoder {
  static const MethodChannel _channel = const MethodChannel('qrcoder');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<List<List<int>>> generateQRCodeMatrix(String text,
      {Encoding encoding = utf8,
      QRErrorCorrectLevel errorCorrectLevel = QRErrorCorrectLevel.H,
      bool hasBorder = true}) async {
    QRCode generator = QRCode(text,
        encoding: encoding,
        errorCorrectLevel: errorCorrectLevel,
        hasBorder: hasBorder);
    return generator.imageCodes();
  }

  static Future<String> generateQRCodeMatrixStringFilledAndPatchedWith(
      String text,
      {Encoding encoding = utf8,
      QRErrorCorrectLevel errorCorrectLevel = QRErrorCorrectLevel.H,
      bool hasBorder = true,
      String black = '1',
      String white = '0'}) async {
    QRCode generator = QRCode(text,
        encoding: encoding,
        errorCorrectLevel: errorCorrectLevel,
        hasBorder: hasBorder);
    return generator.toStringFilledAndPatchedWith(black: black, white: white);
  }
}
