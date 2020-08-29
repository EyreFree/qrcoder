import 'dart:convert' show Encoding, utf8;

import 'an_error.dart';
import 'qr_bit_buffer.dart';
import 'qr_mode.dart';

class QR8bitByte {
  final mode = QRMode.bitByte8;
  List<int> parsedData;

  QR8bitByte(String data, {Encoding encoding = utf8}) {
    final parsed = encoding.encode(data);
    if (parsed == null) {
      throw AnError('String data can not be encoded by input encoding.');
    }
    parsedData = parsed;
  }

  int get count {
    return parsedData.length;
  }

  void writeTo(QRBitBuffer buffer) {
    for (final datium in parsedData) {
      buffer.put(datium, 8);
    }
  }
}
