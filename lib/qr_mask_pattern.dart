import 'an_error.dart';

enum QRMaskPattern {
  _000,
  _001,
  _010,
  _011,
  _100,
  _101,
  _110,
  _111,
}

extension QRMaskPatternExtension on QRMaskPattern {
  int get rawValue {
    switch (this) {
      case QRMaskPattern._000:
        return 0;
      case QRMaskPattern._001:
        return 1;
      case QRMaskPattern._010:
        return 2;
      case QRMaskPattern._011:
        return 3;
      case QRMaskPattern._100:
        return 4;
      case QRMaskPattern._101:
        return 5;
      case QRMaskPattern._110:
        return 6;
      case QRMaskPattern._111:
        return 7;
    }
    throw AnError(
        'Should not run into this line, ask author(eyrefree@eyrefree.org) for help.');
  }

  static QRMaskPattern pattern(int rawValue) {
    switch (rawValue) {
      case 0:
        return QRMaskPattern._000;
      case 1:
        return QRMaskPattern._001;
      case 2:
        return QRMaskPattern._010;
      case 3:
        return QRMaskPattern._011;
      case 4:
        return QRMaskPattern._100;
      case 5:
        return QRMaskPattern._101;
      case 6:
        return QRMaskPattern._110;
      case 7:
        return QRMaskPattern._111;
    }
    throw AnError(
        'Should not run into this line, ask author(eyrefree@eyrefree.org) for help.');
  }

  bool getMask(int i, int j) {
    switch (this) {
      case QRMaskPattern._000:
        return (i + j) % 2 == 0;
      case QRMaskPattern._001:
        return i % 2 == 0;
      case QRMaskPattern._010:
        return j % 3 == 0;
      case QRMaskPattern._011:
        return (i + j) % 3 == 0;
      case QRMaskPattern._100:
        return (i / 2 + j / 3) % 2 == 0;
      case QRMaskPattern._101:
        return (i * j) % 2 + (i * j) % 3 == 0;
      case QRMaskPattern._110:
        return ((i * j) % 2 + (i * j) % 3) % 2 == 0;
      case QRMaskPattern._111:
        return ((i * j) % 3 + (i + j) % 2) % 2 == 0;
    }
    throw AnError(
        'Should not run into this line, ask author(eyrefree@eyrefree.org) for help.');
  }
}
