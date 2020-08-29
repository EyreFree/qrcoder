import 'dart:convert' show utf8;

import 'an_error.dart';
import 'qr_error_correct_level.dart';

class QRCodeType {
  static const List<List<int>> QRCodeLimitLength = [
    [17, 14, 11, 7],
    [32, 26, 20, 14],
    [53, 42, 32, 24],
    [78, 62, 46, 34],
    [106, 84, 60, 44],
    [134, 106, 74, 58],
    [154, 122, 86, 64],
    [192, 152, 108, 84],
    [230, 180, 130, 98],
    [271, 213, 151, 119],
    [321, 251, 177, 137],
    [367, 287, 203, 155],
    [425, 331, 241, 177],
    [458, 362, 258, 194],
    [520, 412, 292, 220],
    [586, 450, 322, 250],
    [644, 504, 364, 280],
    [718, 560, 394, 310],
    [792, 624, 442, 338],
    [858, 666, 482, 382],
    [929, 711, 509, 403],
    [1003, 779, 565, 439],
    [1091, 857, 611, 461],
    [1171, 911, 661, 511],
    [1273, 997, 715, 535],
    [1367, 1059, 751, 593],
    [1465, 1125, 805, 625],
    [1528, 1190, 868, 658],
    [1628, 1264, 908, 698],
    [1732, 1370, 982, 742],
    [1840, 1452, 1030, 790],
    [1952, 1538, 1112, 842],
    [2068, 1628, 1168, 898],
    [2188, 1722, 1228, 958],
    [2303, 1809, 1283, 983],
    [2431, 1911, 1351, 1051],
    [2563, 1989, 1423, 1093],
    [2699, 2099, 1499, 1139],
    [2809, 2213, 1579, 1219],
    [2953, 2331, 1663, 1273]
  ];
}

extension QRCodeTypeExtension on QRCodeType {
  /// Get the type by string length
  static int typeNumberOf(String text, QRErrorCorrectLevel errorCorrectLevel) {
    final textLength = utf8.encode(text).length;
    final maxTypeNumber = QRCodeType.QRCodeLimitLength.length;

    int type = 1;
    for (int i = 0; i < maxTypeNumber; i++) {
      int limit;
      switch (errorCorrectLevel) {
        case QRErrorCorrectLevel.L:
          limit = QRCodeType.QRCodeLimitLength[i][0];
          break;
        case QRErrorCorrectLevel.M:
          limit = QRCodeType.QRCodeLimitLength[i][1];
          break;
        case QRErrorCorrectLevel.Q:
          limit = QRCodeType.QRCodeLimitLength[i][2];
          break;
        case QRErrorCorrectLevel.H:
          limit = QRCodeType.QRCodeLimitLength[i][3];
          break;
      }

      if (textLength <= limit) {
        return type;
      } else {
        type += 1;
      }
    }
    throw AnError('Data length exceeds maximum.');
  }
}
