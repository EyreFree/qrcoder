import 'an_error.dart';

enum QRErrorCorrectLevel {
  /// Error resilience level:  7%.
  L, // 1
  /// Error resilience level: 15%.
  M, // 0
  /// Error resilience level: 25%.
  Q, // 3
  /// Error resilience level: 30%.
  H, // 2
}

extension QRErrorCorrectLevelExtension on QRErrorCorrectLevel {
  int get rawValue {
    switch (this) {
      case QRErrorCorrectLevel.L:
        return 1;
      case QRErrorCorrectLevel.M:
        return 0;
      case QRErrorCorrectLevel.Q:
        return 3;
      case QRErrorCorrectLevel.H:
        return 2;
    }
    throw AnError(
        'Should not run into this line, ask author(eyrefree@eyrefree.org) for help.');
  }
}
