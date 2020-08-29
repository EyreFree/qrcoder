import 'an_error.dart';

class QRMath {
  static int glog(int n) {
    if (n < 1) {
      throw AnError('glog only works with n > 0, not \(n)');
    }
    return QRMath.instance._LOG_TABLE[n];
  }

  static int gexp(int n) {
    int _n = n;
    while (_n < 0) {
      _n += 255;
    }
    while (_n >= 256) {
      _n -= 255;
    }
    return QRMath.instance._EXP_TABLE[_n];
  }

  List<int> _EXP_TABLE;
  List<int> _LOG_TABLE;

  static final QRMath instance = QRMath._privateConstructor();

  QRMath._privateConstructor() {
    _EXP_TABLE = List<int>.filled(256, 0, growable: false);
    _LOG_TABLE = List<int>.filled(256, 0, growable: false);
    for (int i = 0; i < 8; i++) {
      _EXP_TABLE[i] = 1 << i;
    }
    for (int i = 8; i < 256; i++) {
      _EXP_TABLE[i] = _EXP_TABLE[i - 4] ^
          _EXP_TABLE[i - 5] ^
          _EXP_TABLE[i - 6] ^
          _EXP_TABLE[i - 8];
    }
    for (int i = 0; i < 255; i++) {
      _LOG_TABLE[_EXP_TABLE[i]] = i;
    }
  }
}
