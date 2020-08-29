import 'an_error.dart';
import 'qr_math.dart';

class QRPolynomial {
  List<int> _numbers = [];

  QRPolynomial(List<int> nums, {int shift = 0}) {
    if (nums.length <= 0) {
      throw AnError('nums should not be empty.');
    }

    int offset = 0;
    while (offset < nums.length && nums[offset] == 0) {
      offset += 1;
    }
    _numbers =
        List<int>.filled(nums.length - offset + shift, 0, growable: false);
    for (int i = 0; i < nums.length - offset; i++) {
      _numbers[i] = nums[i + offset];
    }
  }

  int get(int index) {
    return _numbers[index];
  }

  int subscript(int index) {
    return get(index);
  }

  int get count {
    return _numbers.length;
  }

  QRPolynomial multiplying(QRPolynomial e) {
    List<int> nums = List<int>.filled(count + e.count - 1, 0, growable: false);
    for (int i = 0; i < count; i++) {
      for (int j = 0; j < e.count; j++) {
        nums[i + j] ^= QRMath.gexp(
            QRMath.glog(this.subscript(i)) + QRMath.glog(e.subscript(j)));
      }
    }
    return QRPolynomial(nums);
  }

  QRPolynomial modedBy(QRPolynomial e) {
    if (count - e.count < 0) {
      return this;
    }
    int ratio = QRMath.glog(this.subscript(0)) - QRMath.glog(e.subscript(0));
    List<int> num = List<int>.filled(count, 0, growable: false);
    for (int i = 0; i < count; ++i) {
      num[i] = this.subscript(i);
    }

    for (int i = 0; i < e.count; ++i) {
      num[i] ^= QRMath.gexp(QRMath.glog(e.subscript(i)) + ratio);
    }
    return QRPolynomial(num).modedBy(e);
  }

  static QRPolynomial errorCorrectPolynomialOfLength(int errorCorrectLength) {
    QRPolynomial a = QRPolynomial([1]);
    for (int i = 0; i < errorCorrectLength; ++i) {
      a = a.multiplying(QRPolynomial([1, QRMath.gexp(i)]));
    }
    return a;
  }
}
