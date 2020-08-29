import 'int_extension.dart';

class BCHUtil {
  static const int _g15 = 1335; // 0b10100110111
  static const int _g18 = 7973; // 0b1111100100101
  static const int _g15Mask = 21522; // 0b101010000010010
  static final int _g15BCHDigit = bchDigitOf(_g15);
  static final int _g18BCHDigit = bchDigitOf(_g18);

  static int bchTypeInfoOf(int data) {
    int d = data << 10;
    while (bchDigitOf(d) - _g15BCHDigit >= 0) {
      d ^= (_g15 << (bchDigitOf(d) - _g15BCHDigit));
    }
    return ((data << 10) | d) ^ _g15Mask;
  }

  static int bchTypeNumberOf(int data) {
    int d = data << 12;
    while (bchDigitOf(d) - _g18BCHDigit >= 0) {
      d ^= (_g18 << (bchDigitOf(d) - _g18BCHDigit));
    }
    return (data << 12) | d;
  }

  static int bchDigitOf(int data) {
    int digit = 0;
    while (data != 0) {
      digit += 1;
      data = data.zeroFillRightShift(1);
    }
    return digit;
  }
}
