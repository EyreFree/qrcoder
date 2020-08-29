import 'an_error.dart';

enum QRMode {
  /// 1 << 0
  number, // 0b0001, 1
  /// 1 << 1
  alphaNumber, // 0b0010, 2
  /// 1 << 2
  bitByte8, // 0b0100, 4
  /// 1 << 3
  kanji, // 0b1000, 8
}

extension QRModeExtension on QRMode {
  int get rawValue {
    switch (this) {
      case QRMode.number:
        return 1;
      case QRMode.alphaNumber:
        return 2;
      case QRMode.bitByte8:
        return 4;
      case QRMode.kanji:
        return 8;
    }
    throw AnError(
        'Should not run into this line, ask author(eyrefree@eyrefree.org) for help.');
  }

  int bitCountOfType(int type) {
    if (1 <= type && type < 10) {
      switch (this) {
        case QRMode.number:
          return 10;
        case QRMode.alphaNumber:
          return 9;
        case QRMode.bitByte8:
        case QRMode.kanji:
          return 8;
      }
    } else if (type < 27) {
      switch (this) {
        case QRMode.number:
          return 12;
        case QRMode.alphaNumber:
          return 11;
        case QRMode.bitByte8:
          return 16;
        case QRMode.kanji:
          return 10;
      }
    } else if (type < 41) {
      switch (this) {
        case QRMode.number:
          return 14;
        case QRMode.alphaNumber:
          return 13;
        case QRMode.bitByte8:
          return 16;
        case QRMode.kanji:
          return 12;
      }
    }
    throw AnError('Can\'t determine length.');
  }
}
