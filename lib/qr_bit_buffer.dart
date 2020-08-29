import 'int_extension.dart';

class QRBitBuffer {
  /// UInt
  List<int> buffer = [];
  int bitCount = 0;

  bool get(int index) {
    final bufIndex = index ~/ 8;
    return ((buffer[bufIndex].zeroFillRightShift(7 - index % 8)) & 1) == 1;
  }

  bool subscript(int index) {
    return get(index);
  }

  /// num: UInt
  void put(int num, int length) {
    for (int i = 0; i < length; i++) {
      putBit(((num.zeroFillRightShift(length - i - 1)) & 1) == 1);
    }
  }

  void putBit(bool bit) {
    final bufIndex = bitCount ~/ 8;
    if (buffer.length <= bufIndex) {
      buffer.add(0);
    }
    if (bit) {
      // 0x80: UInt
      buffer[bufIndex] |= (0x80.zeroFillRightShift(bitCount % 8));
    }
    bitCount += 1;
  }
}
